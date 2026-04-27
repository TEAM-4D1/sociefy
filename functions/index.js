const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

/**
 * Triggered when a membership document is created at:
 *   memberships/{membershipId}
 *
 * Behavior:
 * - Ensure the society exists.
 * - Ensure a group chat document exists at groupChats/{societyId} with the same name as the society.
 * - Add the userId to the chat's participants (arrayUnion).
 */
exports.onSocMemberAdded = functions
  .region('us-central1') // Choose region as needed
  .firestore.document('memberships/{membershipId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const { societyId, userId } = data;
    if (!societyId || !userId) {
      console.error('Missing societyId or userId in membership document', data);
      return null;
    }

    try {
      const societyRef = db.collection('societies').doc(societyId);
      const societySnap = await societyRef.get();
      if (!societySnap.exists) {
        console.error(`Society ${societyId} not found for member ${userId}`);
        return null;
      }
      const societyData = societySnap.data() || {};

      // Ensure the group chat exists
      const chatRef = db.collection('groupChats').doc(societyId);
      await db.runTransaction(async (tx) => {
        const chatDoc = await tx.get(chatRef);
        if (chatDoc.exists) {
          // Chat exists -> add participant idempotently
          tx.update(chatRef, {
            participants: admin.firestore.FieldValue.arrayUnion(userId),
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          // Chat doesn't exist -> create it with this user as the first participant
          tx.set(chatRef, {
            name: societyData.name || `Society ${societyId}`,
            participants: [userId],
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            lastMessageAt: null,
          });
        }
      });

      console.log(`User ${userId} added to chat ${societyId} (society ${societyId})`);
      return null;
    } catch (err) {
      console.error('Error in onSocMemberAdded:', err);
      return null;
    }
  });