const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require('axios');
admin.initializeApp();
const cors = require('cors')({origin: true});

exports.deletePrivateChatOnLastLeft = functions.firestore
  .document('/privateChats/{documentId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const users = afterData.users;
    console.log("Array size: " + users.length);

    if (users.length < 2) {
      console.log("Last person left private chat, deleting");
      return change.after.ref.delete();
    } else {
      // Check if the last message has changed
      if (beforeData.lastMessage !== afterData.lastMessage) {
        console.log("New message detected, sending a push notification");

        const userRef = admin.firestore().collection("users").doc(afterData.sendPushToUserId);

        try {
          const userSnapshot = await userRef.get();

          if (userSnapshot.exists) {
            const userData = userSnapshot.data();
            console.log("User data:", userData);

            const token = userData.fcmToken;
            const payload = {
              notification: {
                title: afterData.lastMessageByName,
                body: afterData.lastMessage,
                badge: "1",
              }
            };

            const recipientTokens = [token];

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
      } else {
        console.log("No new message, skipping push notification");
      }

      return null;
    }
  });

  exports.onUserStatusChange = functions.database.ref("/{uid}/presence").onUpdate(async (change, context) => {
    try {
      const isOnline = change.after.val();

      const userStatusFirestoreRef = admin.firestore().doc(`users/${context.params.uid}`);

      console.log(`status: ${isOnline}`);

      // Update Firestore document
      await userStatusFirestoreRef.update({
        presence: isOnline,
        last_seen: Date.now(),
      });


    } catch (error) {
      functions.logger.error("Error in onUserStatusChange:", error);
    }

    return null;
  });
