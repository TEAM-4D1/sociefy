const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

/**
 * Triggered when a membership document is created in the 'memberships'
 * collection. The app writes flat documents with id '{userId}_{societyId}'
 * and fields: userId, societyId, joinedAt.
 *
 * Behaviour:
 * - Read societyId and userId from the document data.
 * - Ensure a group chat document exists at groupChats/{societyId}.
 * - Add the userId to the chat's participants array (idempotent arrayUnion).
 */
exports.onMembershipCreated = functions
  .region('us-central1')
  .firestore.document('memberships/{membershipId}')
  .onCreate(async (snap) => {
    const data = snap.data();
    const societyId = data && data.societyId;
    const userId = data && data.userId;

    if (!societyId || !userId) {
      console.error('Missing societyId or userId in membership document', data);
      return null;
    }

    try {
      // Look up the society name from the 'societies' collection
      const socRef = db.collection('societies').doc(societyId);
      const socSnap = await socRef.get();
      const socData = socSnap.exists ? (socSnap.data() || {}) : {};
      const societyName = socData.name || `Society ${societyId}`;

      // Ensure the group chat document exists and add the user as a participant
      const chatRef = db.collection('groupChats').doc(societyId);
      await db.runTransaction(async (tx) => {
        const chatDoc = await tx.get(chatRef);
        if (chatDoc.exists) {
          // Chat already exists — add participant idempotently
          tx.update(chatRef, {
            participants: admin.firestore.FieldValue.arrayUnion(userId),
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          // First member — create the chat document
          tx.set(chatRef, {
            name: societyName,
            participants: [userId],
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            lastMessageAt: null,
          });
        }
      });

      console.log(`User ${userId} added to groupChat ${societyId}`);
      return null;
    } catch (err) {
      console.error('Error in onMembershipCreated:', err);
      return null;
    }
  });