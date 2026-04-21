const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

/**
 * Triggered when a membership document is created at:
 *   socs/{socId}/members/{userId}
 *
 * Behavior:
 * - Ensure the SOC exists.
 * - Ensure a group chat document exists at groupChats/{socId} with the same name as the SOC.
 * - Add the userId to the chat's participants (arrayUnion).
 */
exports.onSocMemberAdded = functions
  .region('us-central1') // Choose region as needed
  .firestore.document('socs/{socId}/members/{userId}')
  .onCreate(async (snap, context) => {
    const { socId, userId } = context.params;
    if (!socId || !userId) {
      console.error('Missing socId or userId in context.params', context.params);
      return null;
    }

    try {
      const socRef = db.collection('socs').doc(socId);
      const socSnap = await socRef.get();
      if (!socSnap.exists) {
        console.error(`SOC ${socId} not found for member ${userId}`);
        return null;
      }
      const socData = socSnap.data() || {};

      // Ensure the group chat exists
      const chatRef = db.collection('groupChats').doc(socId);
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
            name: socData.name || `SOC ${socId}`,
            participants: [userId],
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            lastMessageAt: null,
          });
        }
      });

      console.log(`User ${userId} added to chat ${socId} (soc ${socId})`);
      return null;
    } catch (err) {
      console.error('Error in onSocMemberAdded:', err);
      return null;
    }
  });