import 'package:chat/model/message.dart';
import 'package:chat/model/private_chat.dart';
import 'package:chat/model/user_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/room_chat.dart';
import '../model/chat_user.dart';
import '../utils/log.dart';

enum Gender {
  female(0),
  male(1),
  nonBinary(2),
  secret(3);

  const Gender(this.value);

  static Gender fromValue(num i) {
    return Gender.values.firstWhere((x) => x.value == i);
  }

  final int value;
}

enum ChatType {
  message(0),
  joined(1),
  left(2),
  giphy(3),
  date(4);

  const ChatType(this.value);

  final num value;
}

getUserId() => FirebaseAuth.instance.currentUser!.uid;

class FirestoreRepository {
  FirestoreRepository();

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference chats =
      FirebaseFirestore.instance.collection('chats');
  final CollectionReference privateChats =
      FirebaseFirestore.instance.collection('privateChats');
  final CollectionReference messages =
      FirebaseFirestore.instance.collection('messages');
  final CollectionReference reports =
  FirebaseFirestore.instance.collection('reports');

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

  Future<void> setInitialUserData(String email, String userId) async {
    return users
        .doc(userId)
        .set({
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

  Future<RoomChat?> getChat(String chatId, bool isPrivateChat) async {
    return getChatType(isPrivateChat: isPrivateChat)
        .doc(chatId)
        .get()
        .then((value) => value.exists
            ? RoomChat.fromJson(value.id, value.data() as Map<String, dynamic>)
            : null)
        .catchError((error) {
      Log.e("Failed to get chat: $error");
      return null;
    });
  }

  Future<QuerySnapshot> getMessages(String chatId, bool isPrivateChat) async {
    return await getChatType(isPrivateChat: isPrivateChat)
        .doc(chatId)
        .collection("messages")
        .orderBy("created", descending: true)
        .limit(20)
        .get();
  }

  Future<void> postMessage(
      {required String chatId,
      required ChatUser user,
      required String message,
      required bool isPrivateChat,
      required ChatType chatType,
      bool isGiphy = false}) async {
    if (isPrivateChat) {
      //Do not post joined and left messages in private chats
      if (chatType == ChatType.message || chatType == ChatType.giphy) {
        await privateChats.doc(chatId).collection('messages').add({
          'text': message,
          'chatType': chatType.value,
          'createdById': getUserId(),
          'createdByName': user.displayName,
          'createdByGender': user.gender,
          'createdByCountryCode': user.countryCode,
          'createdByImageUrl': user.pictureData,
          'created': FieldValue.serverTimestamp()
        });
      }
    } else {
      //Post message in regular chat
      await chats.doc(chatId).collection('messages').add({
        'text': message,
        'chatType': chatType.value,
        'createdById': getUserId(),
        'createdByName': user.displayName,
        'createdByGender': user.gender,
        'createdByCountryCode': user.countryCode,
        'createdByImageUrl': user.pictureData,
        'created': FieldValue.serverTimestamp()
      });
    }

    //Update the chat object
    if (chatType == ChatType.message || chatType == ChatType.giphy) {
      if (isPrivateChat) {
        await privateChats.doc(chatId).set({
          'lastMessage': message,
          'lastMessageByName': user.displayName,
          'lastMessageByGender': user.gender,
          'lastMessageReadBy': [getUserId()],
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'lastMessageUserId': getUserId()
        }, SetOptions(merge: true));
      } else {
        await chats.doc(chatId).set({
          'lastMessage': message,
          'lastMessageByName': user.displayName,
          'lastMessageByGender': user.gender,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'lastMessageUserId': getUserId()
        }, SetOptions(merge: true));
      }
    } else if (chatType == ChatType.joined && !isPrivateChat) {
      await chats.doc(chatId).set({
        'users': FieldValue.arrayUnion([getUserId()]),
      }, SetOptions(merge: true));
    } else if (chatType == ChatType.left && !isPrivateChat) {
      await chats.doc(chatId).set({
        'users': FieldValue.arrayRemove([getUserId()]),
      }, SetOptions(merge: true));
    }
  }

  CollectionReference getChatType({required bool isPrivateChat}) {
    return isPrivateChat ? privateChats : chats;
  }

  Future<QuerySnapshot> getMoreMessages(
      String chatId, bool isPrivateChat, DocumentSnapshot snapshot) async {
    return getChatType(isPrivateChat: isPrivateChat)
        .doc(chatId)
        .collection("messages")
        .orderBy("created", descending: true)
        .limit(20)
        .startAfterDocument(snapshot)
        .get();
  }

  Stream<QuerySnapshot> streamMessages(
      String chatId, bool isPrivateChat, int limit) {
    return getChatType(isPrivateChat: isPrivateChat)
        .doc(chatId)
        .collection("messages")
        .orderBy("created", descending: true)
        .limit(limit)
        .snapshots(includeMetadataChanges: true);
  }

  Stream<QuerySnapshot> streamChat(String chatId, bool isPrivateChat) {
    return getChatType(isPrivateChat: isPrivateChat)
        .where(FieldPath.documentId, isEqualTo: chatId)
        .snapshots();
  }

  Stream<QuerySnapshot> streamUser() {
    return users
        .where(FieldPath.documentId, isEqualTo: getUserId())
        .snapshots();
  }

  Future<void> setLastMessageRead({required String chatId}) async {
    try {
      await getChatType(isPrivateChat: true).doc(chatId).set({
        'lastMessageReadBy': FieldValue.arrayUnion([getUserId()]),
      }, SetOptions(merge: true));
    } catch (e) {
      Log.e(e);
    }
  }

  Stream<QuerySnapshot> streamChats() {
    return chats.snapshots().handleError((error) {
      Log.e("Failed to get chats: $error");
    });
  }

  Stream<QuerySnapshot> streamPrivateChats() {
    return privateChats.where('users', arrayContains: getUserId()).snapshots();
  }

  void exitAllChats({required String chatId}) async {
    leaveChat(chatId);
    final chats =
        await privateChats.where('users', arrayContains: getUserId()).get();
    for (var element in chats.docs) {
      element.reference.delete();
    }
  }

  Future<void> leaveChat(String chatId) async {
    if (chatId.isNotEmpty) {
      try {
        await chats.doc(chatId).set({
          'users': FieldValue.arrayRemove([getUserId()]),
        }, SetOptions(merge: true));
      } catch (e) {
        Log.e(e);
      }
    } else {
      Log.e("leaveChat: Chat is was empty");
    }
  }

  Future<RoomChat?> createPrivateChat({
    required ChatUser myUser,
    required ChatUser otherUser,
    required String initialMessage,
  }) async {
    try {
      final reference = await privateChats.add({
        'created': FieldValue.serverTimestamp(),
        'lastMessageReadBy': [getUserId()],
        'users': [myUser.id, otherUser.id],
        'initiatedBy': getUserId(),
        'initiatedByUserName': myUser.displayName,
        'initiatedByUserGender': myUser.gender,
        'initiatedByPictureData': myUser.pictureData,
        'chatName': '${otherUser.displayName} ${myUser.displayName}',
        'otherUserId': otherUser.id,
        'otherUserName': otherUser.displayName,
        'otherUserGender': otherUser.gender,
        'otherUserPictureData': otherUser.pictureData,
      });
      final querySnapshot = await privateChats.doc(reference.id).get()
        ..data();
      final data = querySnapshot.data();
      if (data != null) {
        final chat =
            RoomChat.fromJson(querySnapshot.id, data as Map<String, dynamic>);
        postMessage(
            chatId: chat.id,
            user: myUser,
            message: initialMessage,
            isPrivateChat: true,
            chatType: ChatType.message);
        return chat;
      }
    } catch (e) {
      Log.e(e);
    }
    return null;
  }

  Future<bool> isPrivateChatAvailable(String userId) async {
    return await privateChats
        .where('users', arrayContains: getUserId())
        .get()
        .then((value) => value.docs
            .map((e) =>
                PrivateChat.fromJson(e.id, e.data() as Map<String, dynamic>))
            .where((element) => element.users.contains(userId))
            .isEmpty)
        .catchError((error) {
      Log.e("Failed to get chat: $error");
      return false;
    });
  }

  Future<List<ChatUser>> getUsersInChat(RoomChat chat) {
    return users
        .where(FieldPath.documentId, whereIn: chat.users)
        .get()
        .then((value) => value.docs
            .map((e) =>
                ChatUser.fromJson(e.id, e.data() as Map<String, dynamic>))
            .toList())
        .catchError((error) {
      Log.e("Failed to get chat: $error");
      return [];
    });
  }

  Future<void> leavePrivateChat(PrivateChat selectedChat) {
    return privateChats.doc(selectedChat.id).set({
      'users': FieldValue.arrayRemove([getUserId()]),
    }).catchError((error) {
      Log.e("Failed to leave private chat: $error");
    });
  }

  Future<PrivateChat?> getPrivateChat(String userId) {
    return privateChats
        .where('users', arrayContains: getUserId())
        .get()
        .then((value) => value.docs
            .map((e) =>
                PrivateChat.fromJson(e.id, e.data() as Map<String, dynamic>))
            .where((element) => element.users.contains(userId))
            .firstOrNull)
        .catchError((error) {
      Log.e("Failed to delete private chat: $error");
      return null;
    });
  }

  Future<void> _deleteAllUserFiles(String userId) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference userFolderRef = storage.ref().child('images/$userId');

    try {
      // List all items (files and sub-folders) in the user's folder
      ListResult result = await userFolderRef.listAll();

      // Delete each file in the folder
      for (Reference ref in result.items) {
        await ref.delete();
        Log.d("File deleted: ${ref.fullPath}");
      }

      Log.d("All user files deleted successfully");
    } catch (e) {
      Log.d("Error deleting user files: $e");
    }
  }

  Future<void> deleteUserAndFiles() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await _deleteAllUserFiles(user.uid);
        Log.d("Files deleted successfully");
      } catch (e) {
        Log.d("Error deleting files: $e");
      }

      try {
        await users.doc(user.uid).delete();
        Log.d("User deleted in Firestore successfully");
      } catch (e) {
        Log.d("Error deleting user: $e");
      }

      try {
        await user.delete();
        Log.d("User account deleted successfully");
      } catch (e) {
        Log.d("Error deleting user account: $e");
      }
    } else {
      Log.d("No user is currently signed in.");
    }
  }

  getIsNameAvailable(String displayName) {
    return users
        .where('displayName', isEqualTo: displayName)
        .get()
        .then((value) => value.docs.isEmpty)
        .catchError((error) {
      Log.e("Failed to get chat: $error");
      return false;
    });
  }

  void updateUserPresence(int lastSeen, bool presence) {
    users.doc(getUserId()).set({
      'presence': presence,
      'last_seen': lastSeen,
    }, SetOptions(merge: true));
  }

  void updateUserLocation(UserLocation userLocation) {
    users.doc(getUserId()).set({
      'city': userLocation.city,
      'countryCode': userLocation.countryCode,
      'country': userLocation.country,
      'regionName': userLocation.regionName,
    }, SetOptions(merge: true));
  }

  void blockUser(String id) {
    users.doc(id).set({
      'blockedBy': FieldValue.arrayUnion([getUserId()]),
    }, SetOptions(merge: true));
  }

  void unblockUser(String id) {
    users.doc(id).set({
      'blockedBy': FieldValue.arrayRemove([getUserId()]),
    }, SetOptions(merge: true));
  }

  void reportMessage(Message message) {
    reports.add({
      'messageId': message.id,
      'messageText': message.text,
      'messageCreated': message.created,
      'messageCreatedBy': message.createdById,
      'messageCreatedByGender': message.createdByGender,
      'messageCreatedByCountryCode': message.createdByCountryCode,
      'messageCreatedByImageUrl': message.createdByImageUrl,
      'messageCreatedByDisplayName': message.createdByName,
      'reportedBy': getUserId(),
      'reportedAt': FieldValue.serverTimestamp(),
    });
  }
}
