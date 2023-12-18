import 'dart:async';

import 'package:chat/model/message.dart';
import 'package:chat/model/private_chat.dart';
import 'package:chat/model/user_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
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
    if (i < 0 || i > 3) {
      i = 3;
    }
    return Gender.values.firstWhere((x) => x.value == i);
  }

  //Get all genders in list
  static List<Gender> getAsList() {
    return Gender.values;
  }

  final int value;
}

enum ApprovedImage {
  notReviewed(0),
  notApproved(1),
  approved(2),
  notSet(3);

  const ApprovedImage(this.value);

  static ApprovedImage fromValue(num i) {
    if (i < 0 || i > 3) {
      i = 0;
    }
    return ApprovedImage.values.firstWhere((x) => x.value == i);
  }

  //Get all genders in list
  static List<ApprovedImage> getAsList() {
    return ApprovedImage.values;
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
      Log.e("Failed to fetch user: $error");
      return null;
    });
  }

  Future<void> setInitialUserData(String email, String userId) async {
    return users
        .doc(userId)
        .set({
          'email': email,
          'created': FieldValue.serverTimestamp(),
          'approvedImage': ApprovedImage.notReviewed.value,
        }, SetOptions(merge: true))
        .then((value) => Log.d("User updated"))
        .catchError((error) => Log.e("Failed to add user: $error"));
  }

  Future<void> updateUserGender(Gender gender) async {
    return users
        .doc(getUserId())
        .set({
          'gender': gender.value,
        }, SetOptions(merge: true))
        .then((value) => Log.d("User gender updated"))
        .catchError((error) => Log.e("Failed to update user gender: $error"));
  }

  Future<void> updateUserBirthday(DateTime birthDate) async {
    return users
        .doc(getUserId())
        .set({
      'birthDate': Timestamp.fromDate(birthDate),
    }, SetOptions(merge: true))
        .then((value) => Log.d("User birthday updated"))
        .catchError((error) => Log.e("Failed to update user birthdate: $error"));
  }

  Future<void> updateUserShowAge(bool showAge) async {
    return users
        .doc(getUserId())
        .set({
      'showAge': showAge,
    }, SetOptions(merge: true))
        .then((value) => Log.d("User show age updated"))
        .catchError((error) => Log.e("Failed to update user show age: $error"));
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
        .set({
          'pictureData': profileImageUrl,
          'approvedImage': ApprovedImage.notReviewed.value,
        }, SetOptions(merge: true))
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

  Future<QuerySnapshot> getInitialMessages(
      String chatId, bool isPrivateChat) async {
    return await getChatType(isPrivateChat: isPrivateChat)
        .doc(chatId)
        .collection("messages")
        .orderBy("created", descending: true)
        .limit(20)
        .get();
  }

  Future<void> postMessage({
    required String chatId,
    required ChatUser user,
    required String message,
    required ChatType chatType,
    required bool isPrivateChat,
    bool isGiphy = false,
    String? sendPushToUserId,
  }) async {
    if (isPrivateChat) {
      if (chatType == ChatType.message || chatType == ChatType.giphy) {
        await privateChats.doc(chatId).collection('messages').add({
          'text': message,
          'chatType': chatType.value,
          'createdById': getUserId(),
          'createdByName': user.displayName,
          'createdByGender': user.gender,
          'createdByCountryCode': user.countryCode,
          'createdByImageUrl': user.pictureData,
          'approvedImage': user.approvedImage,
          'created': FieldValue.serverTimestamp(),
          'birthDate': user.birthDate,
          'showAge': user.showAge,
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
        'approvedImage': user.approvedImage,
        'created': FieldValue.serverTimestamp(),
        'birthDate': user.birthDate,
        'showAge': user.showAge,
      });
    }

    //Update the chat object
    if (chatType == ChatType.message || chatType == ChatType.giphy) {
      if (isPrivateChat) {
        await privateChats.doc(chatId).set({
          'lastMessage': message,
          'lastMessageIsGiphy': chatType == ChatType.giphy,
          'lastMessageByName': user.displayName,
          'lastMessageByGender': user.gender,
          'lastMessageReadBy': [getUserId()],
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'lastMessageUserId': getUserId(),
          'sendPushToUserId': sendPushToUserId,
        }, SetOptions(merge: true));
      }
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

  Stream<QuerySnapshot> streamUser() {
    return users
        .where(FieldPath.documentId, isEqualTo: getUserId())
        .limit(1)
        .snapshots();
  }

  Stream<QuerySnapshot> streamUnapprovedImages() {
    return users
        .where('approvedImage', isEqualTo: 0)
        .where('pictureData', isNotEqualTo: '')
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

  Future<PrivateChat?> createPrivateChat({
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
        'sendPushToUserId': otherUser.id,
      });

      postMessage(
          chatId: reference.id,
          user: myUser,
          message: initialMessage,
          isPrivateChat: true,
          chatType: ChatType.message,
          sendPushToUserId: otherUser.id);
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
      Log.e("Failed to fetch private chat: $error");
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

  void updateUserPresence({required bool present}) {
    users.doc(getUserId()).set({
      'presence': present,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void leaveAllPrivateChats() {
    privateChats
        .where('users', arrayContains: getUserId())
        .get()
        .then((value) => value.docs.forEach((element) {
              leavePrivateChat(PrivateChat.fromJson(
                  element.id, element.data() as Map<String, dynamic>));
            }));
  }

  void updateUserLocation(UserLocation userLocation) {
    users.doc(getUserId()).set({
      'city': userLocation.city,
      'countryCode': userLocation.countryCode,
      'country': userLocation.countryName,
      'regionName': userLocation.state,
      'lastActive': FieldValue.serverTimestamp(),
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

  void reportMessage(Message message) async {
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

  Stream<QuerySnapshot> streamOpenChats(ChatUser user) {
    if (kDebugMode) {
      return chats.snapshots().handleError((error) {
        Log.e("Failed to get chats: $error");
      });
    } else {
      return chats
          .where('countryCode', whereIn: ['all', user.countryCode])
          .snapshots()
          .handleError((error) {
            Log.e("Failed to get chats: $error");
          });
    }
  }

  final StreamController<QuerySnapshot> _privateChatsStreamController =
      StreamController<QuerySnapshot>.broadcast();
  StreamSubscription<QuerySnapshot>? _privateChatsStream;

  Stream<QuerySnapshot> getPrivateChatsStream() =>
      _privateChatsStreamController.stream;

  void startPrivateChatsStream(String userId) {
    if (_privateChatsStream != null) {
      _privateChatsStream?.cancel();
    }

    _privateChatsStream = privateChats
        .where('users', arrayContains: userId)
        .snapshots()
        .handleError((error) {
      Log.e("Failed to get private chats: $error");
    }).listen((event) {
      if (!_privateChatsStreamController.isClosed) {
        _privateChatsStreamController.sink.add(event);
      }
    });
  }

  void closePrivateChatStream() {
    _privateChatsStream?.cancel();
    _privateChatsStreamController.close();
  }

  Stream<QuerySnapshot> streamUserById(String userId) {
    return users
        .where(FieldPath.documentId, isEqualTo: userId)
        .limit(1)
        .snapshots()
        .handleError((error) {
      Log.e("Failed to get user: $error");
    });
  }

  final onlineDuration = const Duration(hours: 6);

  final StreamController<QuerySnapshot> _onlineUsersStreamController =
      StreamController<QuerySnapshot>.broadcast();
  StreamSubscription<QuerySnapshot>? _onlineUsersStream;

  Stream<QuerySnapshot> get onlineUsersStream =>
      _onlineUsersStreamController.stream;

  void startOnlineUsersStream() {
    if (_onlineUsersStream != null) {
      _onlineUsersStream?.cancel();
    }

    DateTime onlineDurationDate = DateTime.now().subtract(onlineDuration);

    _onlineUsersStream = users
        .where('lastActive',
            isGreaterThan: Timestamp.fromDate(onlineDurationDate))
        .snapshots()
        .handleError((error) {
      Log.e("Failed to get online users: $error");
    }).listen((event) {
      if (!_onlineUsersStreamController.isClosed) {
        _onlineUsersStreamController.sink.add(event);
      }
    });
  }

  void closeOnlineUsersStream() {
    _onlineUsersStream?.cancel();
    _onlineUsersStreamController.close();
  }

  void updateCurrentUsersCurrentChatRoom({required String chatId}) {
    users.doc(getUserId()).set({
      'currentRoomChatId': chatId,
      'presence': true,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void updateImageNotReviewedStatus() {
    users.doc(getUserId()).set({
      'approvedImage': ApprovedImage.notReviewed.value,
    }, SetOptions(merge: true));
  }

  void saveFcmTokenOnUser(fcmToken) {
    users.doc(getUserId()).set({
      'fcmToken': fcmToken,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void postFeedback(String feedback, ChatUser user) {
    FirebaseFirestore.instance.collection('feedback').add({
      'feedback': feedback,
      'createdById': getUserId(),
      'createdByName': user.displayName,
      'createdByCountryCode': user.countryCode,
      'createdByCountryName': user.country,
      'created': FieldValue.serverTimestamp(),
    });
  }

  approveImage(String id) async {
    await users.doc(id).set({
      'approvedImage': ApprovedImage.approved.value,
    }, SetOptions(merge: true));
  }

  rejectImage(String id) async {
    await users.doc(id).set({
      'approvedImage': ApprovedImage.notApproved.value,
      'pictureData': '',
    }, SetOptions(merge: true));

    //Also delete the image from all messages
    await messages
        .where('createdById', isEqualTo: id)
        .get()
        .then((value) => value.docs.forEach((element) {
              messages.doc(element.id).set({
                'createdByImageUrl': '',
              }, SetOptions(merge: true));
            }));

    try {
      await _deleteAllUserFiles(id);
      Log.d("Files deleted successfully");
    } catch (e) {
      Log.d("Error deleting files: $e");
    }
  }
}
