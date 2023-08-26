const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const firestore = admin.firestore();

exports.observeTriggeredStatus = functions.database.ref("/{mainNode}/{subNode}/triggered")
  .onUpdate(async (change, context) => {
    const triggeredAfter = change.after.val();
    const triggeredBefore = change.before.val();

    // Check if the 'triggered' field was changed to true
    if (triggeredAfter === true && triggeredAfter !== triggeredBefore) {
      const mainNode = context.params.mainNode;
      const subNode = context.params.subNode;
      const eventTime = new Date().toLocaleString('en-IN', {
        timeZone: 'Asia/Kolkata', // Use IST timezone
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
      });

      try {
        const assetRef = admin.database().ref(`/${mainNode}/${subNode}`);
        const snapshot = await assetRef.once('value');
        const { name } = snapshot.val();

        const notificationPayload = {
          notification: {
            title: 'Asset Triggered',
            body: `Asset '${name}' has been triggered at ${eventTime}.`
          }
        };

        // Send notification to the topic using FCM
        const topic = 'asset_triggered';
        const message = {
          topic: topic,
          notification: notificationPayload.notification
        };

        await admin.messaging().send(message);

        // Store the notification in Firestore
        const notificationData = {
          // title: notificationPayload.notification.title,
          body: notificationPayload.notification.body,
          // timestamp: admin.firestore.FieldValue.serverTimestamp() // Store the server timestamp when the notification is stored
        };

        await firestore.collection('notifications').add(notificationData);
      } catch (error) {
        console.error('Error sending notifications:', error);
      }
    }
  });

  

  

  





  exports.observeBatteryStatus = functions.database.ref("/{mainNode}/{subNode}/battery")
  .onUpdate(async (change, context) => {
    const batteryLevel = change.after.val();

    // Check if the battery level falls below 10
    if (batteryLevel < 10) {
      const mainNode = context.params.mainNode;
      const subNode = context.params.subNode;
      

      try {
        const assetRef = admin.database().ref(`/${mainNode}/${subNode}`);
        const snapshot = await assetRef.once('value');
        const { name } = snapshot.val();

        const notificationPayload = {
          notification: {
            title: 'Battery Low',
            body: `Battery of asset '${name}' is low.Please charge immediately.`
          }
        };

        // Send notification to the topic using FCM
        const topic = 'battery_low';
        const message = {
          topic: topic,
          notification: notificationPayload.notification
        };

        await admin.messaging().send(message);

        // Store the notification in Firestore
        // const notificationData = {
        //   body: notificationPayload.notification.body,
        // };

        // await firestore.collection('notifications').add(notificationData);
      } catch (error) {
        console.error('Error sending notifications:', error);
      }
    }
  });



  

  

  
  // Cloud Function to send FCM notification when active value changes to true
  exports.sendNotificationOnActiveChange = functions.database.ref('/{mainNode}/{subNode}/active').onUpdate(async (change, context) => {
    const mainNode = context.params.mainNode;
    const subNode = context.params.subNode;
    
    // Get the node data before and after the update
    const beforeData = change.before.val();
    const afterData = change.after.val();
  
    // Check if the 'active' value changed to true
    if (beforeData.active === false && afterData.active === true) {
      try {
        // Fetch the main node's name (assuming it's stored as a property in the node)
        const mainNodeSnapshot = await admin.database().ref(`/${mainNode}`).once('value');
        const mainNodeData = mainNodeSnapshot.val();
        const mainNodeName = mainNodeData.name;
  
        // Fetch all subnodes under the same main node
        const snapshot = await admin.database().ref(`/${mainNode}`).once('value');
        const subnodes = snapshot.val();
  
        // Filter subnodes that have 'active' set to true (excluding the triggering subnode)
        const activeSubnodes = Object.entries(subnodes).filter(([key, node]) => key !== subNode && node.active === true);
  
        // Send notification if there is exactly one active subnode with the same name as the main node
        if (activeSubnodes.length === 1) {
          // Prepare the FCM notification payload
          const payload = {
            notification: {
              title: 'Asset Moved',
              body: `An asset with the same name as ${mainNodeName} has been moved!`,
            },
            topic: 'asset_moved', // Send to the 'asset_moved' topic
          };
  
          // Send the FCM notification
          await admin.messaging().send(payload);
        }
  
        return null;
      } catch (error) {
        console.error('Error sending FCM notification:', error);
        return null;
      }
    }
  
    return null;
  });
  
  
  
  


