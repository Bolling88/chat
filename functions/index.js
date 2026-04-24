const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const SUPABASE_URL = "https://YOUR_MAC_MINI_DOMAIN";
const SUPABASE_SERVICE_KEY = "YOUR_SUPABASE_SERVICE_ROLE_KEY";

exports.sendPushNotification = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  try {
    const {record} = req.body;

    if (!record || !record.send_push_to_user_id) {
      res.status(200).send("No push needed");
      return;
    }

    const recipientId = record.send_push_to_user_id;
    const senderName = record.last_message_by_name || "Someone";
    const messageText = record.last_message || "";

    // Fetch recipient's FCM token from Supabase
    const response = await fetch(
        `${SUPABASE_URL}/rest/v1/users?id=eq.${recipientId}&select=fcm_token`,
        {
          headers: {
            "apikey": SUPABASE_SERVICE_KEY,
            "Authorization": `Bearer ${SUPABASE_SERVICE_KEY}`,
          },
        },
    );

    const users = await response.json();
    if (!users || users.length === 0 || !users[0].fcm_token) {
      res.status(200).send("No FCM token found");
      return;
    }

    const fcmToken = users[0].fcm_token;

    const payload = {
      notification: {
        title: senderName,
        body: messageText,
      },
    };

    await admin.messaging().send({
      token: fcmToken,
      notification: payload.notification,
    });

    res.status(200).send("Push sent");
  } catch (error) {
    console.error("Error sending push:", error);
    res.status(500).send("Error");
  }
});
