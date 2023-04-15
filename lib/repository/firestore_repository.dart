import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/chat.dart';
import '../model/chat_user.dart';
import '../utils/log.dart';

enum Gender {
  female(0),
  male(1),
  nonBinary(2);

  const Gender(this.value);

  final num value;
}

getUserId() => FirebaseAuth.instance.currentUser!.uid;

class FirestoreRepository {
  FirestoreRepository();

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference chats =
      FirebaseFirestore.instance.collection('chats');
  final CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');

  Future<ChatUser?> getUser({String? userId}) async {
    return users
        .doc((userId != null) ? userId : FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) => value.exists
            ? ChatUser.fromJson(value.id, value.data() as Map<String, dynamic>)
            : null)
        .catchError((error) {
      Log.e("Failed to add user: $error");
      return null;
    });
  }

  Future<void> setInitialUserData(
      String name, String email, String userId) async {
    return users
        .doc(userId)
        .set({
          'name': name,
          'email': email,
          'created': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .then((value) => Log.d("User updated"))
        .catchError((error) => Log.e("Failed to add user: $error"));
  }

  Future<void> updateUserGender(Gender gender) async {
    return users
        .doc(getUserId())
        .set({'gender': gender.value}, SetOptions(merge: true))
        .then((value) => Log.d("User gender updated"))
        .catchError((error) => Log.e("Failed to update user gender: $error"));
  }

  Future<void> updateUserDisplayName(
      String fullName, List<String> searchArray) async {
    return users
        .doc(getUserId())
        .set({
          'displayName': fullName,
          'searchArray': searchArray,
        }, SetOptions(merge: true))
        .then((value) => Log.d("User displayName updated"))
        .catchError(
            (error) => Log.e("Failed to update user displayName: $error"));
  }

  Future<void> updateUserProfileImage(String profileImageUrl) async {
    return users
        .doc(getUserId())
        .set({'pictureData': profileImageUrl}, SetOptions(merge: true))
        .then((value) => Log.d("User profile image updated"))
        .catchError((error) => Log.e("Failed to update user image: $error"));
  }

  Future<Chat?> getChat(String chatId) async {
    return chats
        .doc(chatId)
        .get()
        .then((value) => value.exists
            ? Chat.fromJson(value.id, value.data() as Map<String, dynamic>)
            : null)
        .catchError((error) {
      Log.e("Failed to get chat: $error");
      return null;
    });
  }

  Future<QuerySnapshot> getMessages(String chatId) async {
    return await chats
        .doc(chatId)
        .collection("messages")
        .orderBy("created", descending: true)
        .limit(20)
        .get();
  }

  Future<void> postMessage(String documentId, ChatUser user, String message,
      {isGiphy = false, isInfoMessage = false}) async {
    await chats.doc(documentId).collection('messages').add({
      'text': message,
      'isGiphy': isGiphy,
      'isInfoMessage': isInfoMessage,
      'createdById': getUserId(),
      'createdByName': user.displayName,
      'createdByImageUrl': user.pictureData,
      'created': FieldValue.serverTimestamp()
    });
    await chats.doc(documentId).set({
      'lastMessage': message,
      'lastMessageIsGiphy': isGiphy,
      'lastMessageIsInfo': isInfoMessage,
      'lastMessageReadBy': [getUserId()],
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'lastMessageUserId': getUserId()
    }, SetOptions(merge: true));
  }

  Future<QuerySnapshot> getMoreMessages(
      String chatId, DocumentSnapshot snapshot) async {
    return chats
        .doc(chatId)
        .collection("messages")
        .orderBy("created", descending: true)
        .limit(20)
        .startAfterDocument(snapshot)
        .get();
  }

  Future<List<ChatUser>> getUsers(List<String> userIds) async {
    final fetchedUsers = <ChatUser>[];
    for (var i = 0; i < userIds.length; i++) {
      final startValue = i * 10;
      final endValue = i * 10 + 10;
      if (startValue >= userIds.length) break;
      final List<String> userSection = userIds
          .getRange(startValue,
              (endValue >= userIds.length) ? userIds.length : endValue)
          .toList();
      final querySnapshot =
          await users.where(FieldPath.documentId, whereIn: userSection).get();
      final userList = querySnapshot.docs
          .where((it) => it.exists)
          .map((it) =>
              ChatUser.fromJson(it.id, it.data() as Map<String, dynamic>))
          .toList();
      fetchedUsers.addAll(userList);
    }
    return fetchedUsers;
  }

  Stream<QuerySnapshot> streamMessages(String chatId, int limit) {
    return chats
        .doc(chatId)
        .collection("messages")
        .orderBy("created", descending: true)
        .limit(limit)
        .snapshots(includeMetadataChanges: true);
  }

  Stream<QuerySnapshot> streamChat(String chatId) {
    return chats.where(FieldPath.documentId, isEqualTo: chatId).snapshots();
  }

  Future<void> setLastMessageRead(String chatId) async {
    if (chatId.isNotEmpty) {
      try {
        await chats.doc(chatId).set({
          'lastMessageReadBy': FieldValue.arrayUnion([getUserId()]),
        }, SetOptions(merge: true));
      } catch (e) {
        Log.e(e);
      }
    } else {
      Log.e("setLastMessageRead: Chat is was empty");
    }
  }

  Stream<QuerySnapshot> streamChats() {
    return chats.snapshots();
  }

  Future<Chat?> createChat({required String chatName}) async {
    try {
      final reference = await chats.add({
        'created': FieldValue.serverTimestamp(),
        'lastMessageReadBy': [getUserId()],
        'users': [FirebaseAuth.instance.currentUser!.uid],
        'chatName': chatName,
      });
      final querySnapshot = await chats.doc(reference.id).get()
        ..data();
      final data = querySnapshot.data();
      if (data != null) {
        return Chat.fromJson(querySnapshot.id, data as Map<String, dynamic>);
      }
    } catch (e) {
      Log.e(e);
    }
    return null;
  }
}
