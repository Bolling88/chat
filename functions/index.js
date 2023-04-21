const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const firestore = admin.firestore();

exports.onUserStatusChange = functions.database
  .ref("/{uid}/presence")
  .onUpdate(async (change, context) => {
    // Get the data written to Realtime Database
    const isOnline = change.after.val();

    // Get a reference to the Firestore document
    const userStatusFirestoreRef = firestore.doc(`users/${context.params.uid}`);

    console.log(`status: ${isOnline}`);

    if(isOnline === false) {
     const partiesQuery = admin.firestore().collection("privateChats").where('users', 'array-contains',
                                                                                  context.params.uid);
      partiesQuery.get().then(querySnapshot => {
        if (!querySnapshot.empty) {
          // Get just the one customer/user document
          for (const snapshot of querySnapshot.docs) {
                      // Reference of customer/user doc
                      const documentRef = snapshot.ref
                      documentRef.delete();
                      functions.logger.log("Private chat Document deleted:", documentRef);
          }
        }
        else {
          functions.logger.log("User Document Does Not Exist");
        }
        return null;
      }).catch(error => {
        functions.logger.log(error);
      }
        );
    }

    // Update the values on Firestore
    return userStatusFirestoreRef.update({
      presence: isOnline,
      last_seen: Date.now(),
    });
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