const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.onNewChatMessage = functions.database
  .ref("/messages/{chatId}/{messageId}")
  .onCreate(async (snapshot, context) => {
    const chatId = context.params.chatId;
    const messageData = snapshot.val();
    const senderId = messageData.senderId;
    const textOrImage = messageData.isImage ? "[📷 Image]" : messageData.text || "";

    console.log(`📥 New message received in chat ${chatId} from ${senderId}`);
    console.log("Message data:", messageData);

    try {
      // 1. Fetch chat document from Firestore
      const chatDoc = await admin.firestore().collection("chats").doc(chatId).get();
      if (!chatDoc.exists) {
        console.warn(`⚠️ Chat document not found for chatId: ${chatId}`);
        return null;
      }

      const data = chatDoc.data();
      const participants = data.participants;
      const otherUid = participants.find((uid) => uid !== senderId);

      if (!otherUid) {
        console.warn(`⚠️ No other UID found in participants for chatId: ${chatId}`);
        return null;
      }

      // 2. Get FCM token of the other user
      const userDoc = await admin.firestore().collection("users").doc(otherUid).get();
      if (!userDoc.exists) {
        console.warn(`⚠️ Recipient user doc not found for uid: ${otherUid}`);
        return null;
      }

      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        console.warn(`⚠️ No FCM token found for user: ${otherUid}`);
        return null;
      }

      // 3. Prepare payload
      const senderName = data.participantData?.[senderId]?.name || "Someone";
      const senderAvatar = data.participantData?.[senderId]?.avatar || "";

      const payload = {
        notification: {
          title: `New message from ${senderName}`,
          body: textOrImage,
        },
        data: {
          chatId: chatId,
          senderId: senderId,
          senderName: senderName,
          senderAvatar: senderAvatar,
          click_action: "FLUTTER_NOTIFICATION_CLICK", // Required for foreground + background
        },
      };

      // 4. Send notification
      const response = await admin.messaging().sendToDevice(fcmToken, payload);
      console.log("✅ Notification sent to:", otherUid);
      console.log("📦 Payload:", payload);
      console.log("📬 FCM Response:", JSON.stringify(response));

      return response;
    } catch (error) {
      console.error("🔥 Error sending FCM message:", error);
      return null;
    }
  });
