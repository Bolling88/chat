const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const firestore = admin.firestore();

exports.onUserStatusChange = functions.database.ref("/{uid}/presence").onUpdate(async (change, context) => {
  try {
    const isOnline = change.after.val();

    const userStatusFirestoreRef = firestore.doc(`users/${context.params.uid}`);

    console.log(`status: ${isOnline}`);

    // Update Firestore document
    await userStatusFirestoreRef.update({
      presence: isOnline,
      last_seen: Date.now(),
    });

    if (!isOnline) {
      // Delete private chat documents
      const partiesQuery = admin.firestore().collection("privateChats").where('users', 'array-contains', context.params.uid);
      const partiesSnapshot = await partiesQuery.get();

      for (const partyDoc of partiesSnapshot.docs) {
        await partyDoc.ref.delete();
        functions.logger.log("Private chat Document deleted:", partyDoc.id);
      }

      // Remove the user from chat documents
      const chatQuery = admin.firestore().collection("chats").where('users', 'array-contains', context.params.uid);
      const chatSnapshot = await chatQuery.get();

     const userRef = admin.firestore().collection("users").doc(messageData.sendPushToUserId);

     try {
       const userSnapshot = await userRef.get();
       if (userSnapshot.exists) {
         const userData = userSnapshot.data();
         // Now userData contains the data of the user document
         console.log(userData);
         const token = userData.fcmToken;
const payload = {
  notification: {
    title: messageData.lastMessageByName,
    body: messageData.lastMessage,
  }
};

      // Get the device tokens for the users you want to send the notification to
      const recipientTokens = [messageData.lastMessageFcmToken]; // Wrap the token in an array

      // Send the FCM notification
      try {
        const response = await admin.messaging().sendToDevice(recipientTokens, payload);
        console.log("Notification sent successfully:", response);
      } catch (error) {
        console.error("Error sending notification:", error);
      }

       } else {
         console.log("User not found");
       }
     } catch (error) {
       console.error("Error getting user data:", error);
     }

      for (const chatDoc of chatSnapshot.docs) {
        const chatData = chatDoc.data();
        const updatedUsers = chatData.users.filter(uid => uid !== context.params.uid);
        await chatDoc.ref.update({ users: updatedUsers });
        functions.logger.log(`User ${context.params.uid} removed from chat ${chatDoc.id}`);
      }
    }
  } catch (error) {
    functions.logger.error("Error in onUserStatusChange:", error);
  }

  return null;
});

exports.deletePrivateChatOnLastLeft = functions.firestore.document('/privateChats/{documentId}')
  .onUpdate((change, context) => {
    // Get an object representing the document
    const newValue = change.after.data();
    // ...or the previous value before this update
    const previousValue = change.before.data();

    // access a particular field as you would any JS property
    const users = newValue.users;
    console.log("Array size: " + users.length);
    //If no person, delete document
    if (users.length === 1) {
      console.log("Last person left private chat, deleting");
      return change.after.ref.delete()
    }
    else {
      console.log("People are still chatting");
      return null;
    }
  });