import 'dart:async';

import 'package:chat/model/message.dart';
import 'package:chat/model/private_chat.dart' as app;
import 'package:chat/model/room_chat.dart' as app;
import 'package:chat/model/user_location.dart';
import 'package:chat/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:kvitter_client/kvitter_client.dart' as srv;

import '../model/chat_user.dart' as app;
import '../utils/auth_util.dart';
import '../utils/log.dart';
import '../utils/online_users_processor.dart';

class ServerpodRepository {
  final OnlineUserProcessor _processor;
  final srv.Client _client = serverpodClient;

  ServerpodRepository(this._processor);

  // =============================================
  // MODEL CONVERTERS
  // =============================================

  app.ChatUser _toAppUser(srv.ChatUser u) {
    return app.ChatUser(
      id: u.id?.toString() ?? '',
      displayName: u.displayName,
      gender: u.gender,
      pictureData: u.pictureData,
      approvedImage: u.approvedImage,
      onboardingCompleted: u.onboardingCompleted,
      isAdmin: u.isAdmin,
      created: DateTime.now(), // server model doesn't store created separately
      lastActive: u.lastActive.millisecondsSinceEpoch,
      city: u.city,
      countryCode: u.countryCode,
      country: u.country,
      regionName: u.regionName,
      presence: u.presence,
      showAge: u.showAge,
      currentRoomChatId: u.currentRoomChatId?.toString() ?? '',
      fcmToken: u.fcmToken,
      birthDate: u.birthDate,
      blockedBy: u.blockedBy,
      imageReports: u.imageReports,
      botReports: u.botReports,
      languageReports: u.languageReports,
      kvitterCredits: u.kvitterCredits,
      isPremiumUser: u.isPremiumUser,
    );
  }

  app.RoomChat _toAppRoomChat(srv.RoomChat r) {
    return app.RoomChat(
      id: r.id?.toString() ?? '',
      countryCode: r.countryCode,
      chatName: r.chatName,
      chatColor: r.chatColor,
      imageUrl: r.imageUrl,
      imageOverflow: r.imageOverflow,
      imageTranslationX: r.imageTranslationX,
      lastMessageReadByUser: false,
      enabled: r.enabled,
      infoKey: r.infoKey,
      lastMessage: r.lastMessage,
      lastMessageIsGiphy: r.lastMessageIsGiphy,
      lastMessageByName: r.lastMessageByName,
      lastMessageTimestamp: r.lastMessageTimestamp,
      lastMessageUserId: r.lastMessageUserId?.toString() ?? '',
    );
  }

  app.PrivateChat _toAppPrivateChat(srv.PrivateChat p) {
    return app.PrivateChat(
      id: p.id?.toString() ?? '',
      users: p.users,
      created: p.created,
      initiatedBy: p.initiatedBy,
      initiatedByUserName: p.initiatedByUserName,
      initiatedByUserGender: p.initiatedByUserGender,
      initiatedByPictureData: p.initiatedByPictureData,
      otherUserId: p.otherUserId,
      otherUserName: p.otherUserName,
      otherUserGender: p.otherUserGender,
      otherUserPictureData: p.otherUserPictureData,
      lastMessage: p.lastMessage,
      lastMessageIsGiphy: p.lastMessageIsGiphy,
      lastMessageByName: p.lastMessageByName,
      lastMessageTimestamp: p.lastMessageTimestamp,
      lastMessageUserId: p.lastMessageUserId ?? '',
      lastMessageReadBy: p.lastMessageReadBy,
    );
  }

  Message _toAppMessage(srv.ChatMessage m) {
    return Message(
      id: m.id?.toString() ?? '',
      text: m.text,
      createdById: m.createdById,
      createdByName: m.createdByName,
      createdByGender: m.createdByGender,
      createdByCountryCode: m.createdByCountryCode,
      createdByImageUrl: m.createdByImageUrl,
      chatType: ChatType.values[m.chatType],
      approvedImage: m.approvedImage,
      created: m.created,
      birthDate: m.birthDate,
      showAge: m.showAge,
      translation: null,
      marked: false,
      imageReports: m.imageReports,
      replyId: m.replyId ?? '',
      replyText: m.replyText,
      replyCreatedById: m.replyCreatedById ?? '',
      replyCreatedByName: m.replyCreatedByName,
      replyCreatedByGender: m.replyCreatedByGender,
      replyCreatedByCountryCode: m.replyCreatedByCountryCode,
      replyCreatedByImageUrl: m.replyCreatedByImageUrl,
      replyChatType: ChatType.values[m.replyChatType],
      replyApprovedImage: m.replyApprovedImage,
      replyCreated: m.replyCreated,
      replyBirthDate: m.replyBirthDate,
      replyShowAge: m.replyShowAge,
      replyImageReports: m.replyImageReports,
    );
  }

  srv.ChatMessage _toServerMessage({
    required String chatId,
    required app.ChatUser user,
    required String message,
    required ChatType chatType,
    required bool isPrivateChat,
    Message? replyMessage,
  }) {
    return srv.ChatMessage(
      chatId: chatId,
      isPrivate: isPrivateChat,
      text: message,
      chatType: chatType.value.toInt(),
      createdById: getUserId(),
      createdByName: user.displayName,
      createdByGender: user.gender,
      createdByCountryCode: user.countryCode,
      createdByImageUrl: user.pictureData,
      approvedImage: user.approvedImage,
      created: DateTime.now(),
      birthDate: user.birthDate,
      showAge: user.showAge,
      imageReports: user.imageReports,
      replyId: replyMessage?.id,
      replyText: replyMessage?.text ?? '',
      replyChatType: replyMessage?.chatType.value.toInt() ?? ChatType.message.value.toInt(),
      replyCreatedById: replyMessage?.createdById,
      replyCreatedByName: replyMessage?.createdByName ?? '',
      replyCreatedByGender: replyMessage?.createdByGender ?? 0,
      replyCreatedByCountryCode: replyMessage?.createdByCountryCode ?? '',
      replyCreatedByImageUrl: replyMessage?.createdByImageUrl ?? '',
      replyApprovedImage: replyMessage?.approvedImage ?? ApprovedImage.notSet.value,
      replyCreated: replyMessage?.created,
      replyBirthDate: replyMessage?.birthDate,
      replyShowAge: replyMessage?.showAge ?? false,
      replyImageReports: replyMessage?.imageReports ?? [],
    );
  }

  // =============================================
  // USER OPERATIONS
  // =============================================

  Future<app.ChatUser?> getUser({String? userId}) async {
    try {
      final srvUser = await _client.user.getUser(userId: userId);
      if (srvUser == null) return null;
      return _toAppUser(srvUser);
    } catch (e) {
      Log.e("Failed to fetch user: $e");
      return null;
    }
  }

  Future<void> setInitialUserData(String email, String userId) async {
    try {
      await _client.user.ensureUserExists(email);
    } catch (e) {
      Log.e("Failed to add user: $e");
    }
  }

  Future<void> updateUserGender(Gender gender) async {
    try {
      await _client.user.updateGender(gender.value);
    } catch (e) {
      Log.e("Failed to update user gender: $e");
    }
  }

  Future<void> updateUserBirthday(DateTime birthDate) async {
    try {
      await _client.user.updateBirthday(birthDate);
    } catch (e) {
      Log.e("Failed to update user birthdate: $e");
    }
  }

  Future<void> updateUserShowAge(bool showAge) async {
    try {
      await _client.user.updateShowAge(showAge);
    } catch (e) {
      Log.e("Failed to update user show age: $e");
    }
  }

  Future<void> updateUserDisplayName(String fullName, List<String> searchArray) async {
    try {
      await _client.user.updateDisplayName(fullName, searchArray);
    } catch (e) {
      Log.e("Failed to update user displayName: $e");
    }
  }

  Future<void> updateUserProfileImage({
    required String profileImageUrl,
    required app.ChatUser user,
    required bool hasNudity,
  }) async {
    try {
      await _client.user.updateProfileImage(profileImageUrl, hasNudity);
    } catch (e) {
      Log.e("Failed to update user image: $e");
    }
  }

  Future<bool> getIsNameAvailable(String displayName) async {
    try {
      return await _client.user.isNameAvailable(displayName);
    } catch (e) {
      Log.e("Failed to check name: $e");
      return false;
    }
  }

  Future<void> updateUserOnLogout() async {
    try {
      await _client.user.logout();
    } catch (e) {
      Log.e("Failed to update user on logout: $e");
    }
  }

  void updateUserLocation(UserLocation userLocation) {
    _client.user
        .updateLocation(
          userLocation.city,
          userLocation.countryCode,
          userLocation.countryName,
          userLocation.state,
        )
        .catchError((e) => Log.e("Failed to update user location: $e"));
  }

  void setUserAsActive() {
    _client.user
        .setActive()
        .catchError((e) => Log.e("Failed to set user active: $e"));
  }

  void updateCurrentUsersCurrentChatRoom({required String chatId}) {
    _client.user
        .setCurrentChatRoom(chatId)
        .catchError((e) => Log.e("Failed to set current chat room: $e"));
  }

  void saveFcmTokenOnUser(String fcmToken) {
    _client.user
        .saveFcmToken(fcmToken)
        .catchError((e) => Log.e("Failed to save FCM token: $e"));
  }

  void updateImageNotReviewedStatus() {
    _client.user
        .updateImageNotReviewedStatus()
        .catchError((e) => Log.e("Failed to update image not reviewed status: $e"));
  }

  Future<void> deleteUserPhoto() async {
    try {
      await _client.user.deletePhoto();
    } catch (e) {
      Log.e("Failed to delete user photo: $e");
    }
  }

  Future<void> deleteUserAndFiles() async {
    try {
      await _client.user.deleteAccount();
    } catch (e) {
      Log.e("Error deleting user: $e");
    }
  }

  Future<void> setUserAsPremium(bool isPremiumUser) async {
    try {
      await _client.user.setPremium(isPremiumUser);
    } catch (e) {
      Log.e("Failed to set user as premium: $e");
    }
  }

  // =============================================
  // BLOCK / REPORT OPERATIONS
  // =============================================

  Future<void> blockUser(String id) async {
    try {
      await _client.moderation.blockUser(id);
    } catch (e) {
      Log.e("Failed to block user: $e");
    }
  }

  Future<void> unblockUser(String id) async {
    try {
      await _client.moderation.unblockUser(id);
    } catch (e) {
      Log.e("Failed to unblock user: $e");
    }
  }

  void reportMessage(Message message) async {
    try {
      await _client.moderation.reportMessage(
        message.id,
        message.text,
        message.created,
        message.createdById,
        message.createdByGender,
        message.createdByCountryCode,
        message.createdByImageUrl,
        message.createdByName,
      );
    } catch (e) {
      Log.e("Failed to report message: $e");
    }
  }

  Future<void> postInappropriateImageReport(String reportedUserId) async {
    try {
      await _client.moderation.reportInappropriateImage(reportedUserId);
    } catch (e) {
      Log.e("Failed to report inappropriate image: $e");
    }
  }

  Future<void> postBotReport(String reportedUserId) async {
    try {
      await _client.moderation.reportBot(reportedUserId);
    } catch (e) {
      Log.e("Failed to report bot: $e");
    }
  }

  Future<void> postHatefulLanguageReport(String reportedUserId) async {
    try {
      await _client.moderation.reportHatefulLanguage(reportedUserId);
    } catch (e) {
      Log.e("Failed to report hateful language: $e");
    }
  }

  // =============================================
  // ADMIN / MODERATION
  // =============================================

  Future<void> approveImage(String id) async {
    try {
      await _client.moderation.approveImage(id);
    } catch (e) {
      Log.e("Failed to approve image: $e");
    }
  }

  Future<void> rejectImage(String id) async {
    try {
      await _client.moderation.rejectImage(id);
    } catch (e) {
      Log.e("Failed to reject image: $e");
    }
  }

  // =============================================
  // CREDITS
  // =============================================

  Future<void> reduceUserCredits(String id, int i) async {
    try {
      await _client.chat.reduceCredits(id, i);
    } catch (e) {
      Log.e("Failed to reduce user credits: $e");
    }
  }

  Future<void> increaseUserCredits(String id, int i) async {
    try {
      await _client.chat.increaseCredits(id, i);
    } catch (e) {
      Log.e("Failed to increase user credits: $e");
    }
  }

  // =============================================
  // FEEDBACK
  // =============================================

  void postFeedback(String feedback, app.ChatUser user) {
    _client.chat
        .postFeedback(feedback, user.displayName, user.countryCode, user.country)
        .catchError((e) => Log.e("Failed to post feedback: $e"));
  }

  // =============================================
  // CHAT OPERATIONS
  // =============================================

  Future<app.RoomChat?> getChat(String chatId, bool isPrivateChat) async {
    try {
      if (isPrivateChat) {
        // Private chats don't use the chat endpoint — return null; caller
        // should use getPrivateChat instead.
        return null;
      }
      final srvChat = await _client.chat.getChat(chatId);
      if (srvChat == null) return null;
      return _toAppRoomChat(srvChat);
    } catch (e) {
      Log.e("Failed to get chat: $e");
      return null;
    }
  }

  // =============================================
  // MESSAGE OPERATIONS
  // =============================================

  Future<List<Message>> getInitialMessages(String chatId, bool isPrivateChat) async {
    try {
      final msgs = await _client.chat.getInitialMessages(chatId, isPrivateChat);
      return msgs.map(_toAppMessage).toList();
    } catch (e) {
      Log.e("Failed to get initial messages: $e");
      return [];
    }
  }

  Future<List<Message>> getMoreMessages(
      String chatId, bool isPrivateChat, DateTime before) async {
    try {
      final msgs = await _client.chat.getMoreMessages(chatId, isPrivateChat, before);
      return msgs.map(_toAppMessage).toList();
    } catch (e) {
      Log.e("Failed to get more messages: $e");
      return [];
    }
  }

  Future<void> postMessage({
    required String chatId,
    required app.ChatUser user,
    required String message,
    required ChatType chatType,
    required bool isPrivateChat,
    bool isGiphy = false,
    String? sendPushToUserId,
    Message? replyMessage,
  }) async {
    try {
      final serverMessage = _toServerMessage(
        chatId: chatId,
        user: user,
        message: message,
        chatType: chatType,
        isPrivateChat: isPrivateChat,
        replyMessage: replyMessage,
      );
      await _client.chat.postMessage(serverMessage);
    } catch (e) {
      Log.e("Failed to post message: $e");
    }
  }

  // =============================================
  // PRIVATE CHAT OPERATIONS
  // =============================================

  Future<app.PrivateChat?> createPrivateChat({
    required app.ChatUser myUser,
    required app.ChatUser otherUser,
    required String initialMessage,
  }) async {
    final trimmedMessage = initialMessage.trim();
    if (trimmedMessage.isEmpty || trimmedMessage.length > 1000) return null;
    try {
      final srvChat = await _client.privateChat.createPrivateChat(
        otherUser.id,
        trimmedMessage,
        myUser.displayName,
        myUser.gender,
        myUser.pictureData,
        otherUser.displayName,
        otherUser.gender,
        otherUser.pictureData,
      );
      if (srvChat == null) return null;
      return _toAppPrivateChat(srvChat);
    } catch (e) {
      Log.e("Failed to create private chat: $e");
      return null;
    }
  }

  Future<bool> isPrivateChatAvailable(String userId) async {
    try {
      return await _client.privateChat.isPrivateChatAvailable(userId);
    } catch (e) {
      Log.e("Failed to check if private chat is available: $e");
      return false;
    }
  }

  Future<void> leavePrivateChat(app.PrivateChat selectedChat) async {
    try {
      await _client.privateChat.leavePrivateChat(selectedChat.id);
    } catch (e) {
      Log.e("Failed to leave private chat: $e");
    }
  }

  Future<app.PrivateChat?> getPrivateChat(String userId) async {
    try {
      final srvChat = await _client.privateChat.getPrivateChatWithUser(userId);
      if (srvChat == null) return null;
      return _toAppPrivateChat(srvChat);
    } catch (e) {
      Log.e("Failed to fetch private chat: $e");
      return null;
    }
  }

  Future<void> setLastMessageRead({required String chatId}) async {
    try {
      await _client.privateChat.setLastMessageRead(chatId);
    } catch (e) {
      Log.e("Failed to set last message read: $e");
    }
  }

  Future<void> leaveAllPrivateChats() async {
    try {
      await _client.privateChat.leaveAllPrivateChats();
    } catch (e) {
      Log.e("Failed to leave all private chats: $e");
    }
  }

  // =============================================
  // STREAM OPERATIONS (POLLING-BASED)
  // =============================================

  // --- Messages stream ---

  final Map<String, StreamController<List<Message>>> _messageStreamControllers = {};
  final Map<String, Timer> _messageTimers = {};

  Stream<List<Message>> streamMessages(String chatId, bool isPrivateChat, int limit) {
    final key = '$chatId-$isPrivateChat';
    _messageStreamControllers[key]?.close();
    final controller = StreamController<List<Message>>.broadcast(
      onCancel: () => _cancelMessageStream(key),
    );
    _messageStreamControllers[key] = controller;

    Future<void> fetch() async {
      if (controller.isClosed) return;
      try {
        final msgs = await _client.chat.getInitialMessages(chatId, isPrivateChat);
        final appMsgs = msgs.map(_toAppMessage).toList();
        if (!controller.isClosed) controller.sink.add(appMsgs);
      } catch (e) {
        Log.e("Failed to stream messages: $e");
      }
    }

    fetch();
    _messageTimers[key]?.cancel();
    _messageTimers[key] = Timer.periodic(const Duration(seconds: 3), (_) => fetch());

    return controller.stream;
  }

  void _cancelMessageStream(String key) {
    _messageTimers[key]?.cancel();
    _messageTimers.remove(key);
    _messageStreamControllers.remove(key);
  }

  // --- User stream ---

  StreamController<app.ChatUser?>? _userStreamController;
  Timer? _userStreamTimer;

  Stream<app.ChatUser?> streamUser() {
    _userStreamController?.close();
    _userStreamTimer?.cancel();
    final controller = StreamController<app.ChatUser?>.broadcast(
      onCancel: () {
        _userStreamTimer?.cancel();
        _userStreamTimer = null;
        _userStreamController = null;
      },
    );
    _userStreamController = controller;

    Future<void> fetch() async {
      if (controller.isClosed) return;
      try {
        final srvUser = await _client.user.getUser();
        if (!controller.isClosed) {
          controller.sink.add(srvUser != null ? _toAppUser(srvUser) : null);
        }
      } catch (e) {
        Log.e("Failed to stream user: $e");
      }
    }

    fetch();
    _userStreamTimer = Timer.periodic(const Duration(seconds: 5), (_) => fetch());

    return controller.stream;
  }

  Stream<app.ChatUser?> streamUserById(String userId) {
    final controller = StreamController<app.ChatUser?>.broadcast();
    Timer? timer;

    Future<void> fetch() async {
      if (controller.isClosed) return;
      try {
        final srvUser = await _client.user.getUser(userId: userId);
        if (!controller.isClosed) {
          controller.sink.add(srvUser != null ? _toAppUser(srvUser) : null);
        }
      } catch (e) {
        Log.e("Failed to stream user by id: $e");
      }
    }

    controller.onCancel = () {
      timer?.cancel();
    };

    fetch();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => fetch());

    return controller.stream;
  }

  Stream<List<app.ChatUser>> streamUnapprovedImages() {
    final controller = StreamController<List<app.ChatUser>>.broadcast();
    Timer? timer;

    Future<void> fetch() async {
      if (controller.isClosed) return;
      try {
        final users = await _client.moderation.getUnapprovedImages();
        if (!controller.isClosed) {
          controller.sink.add(users.map(_toAppUser).toList());
        }
      } catch (e) {
        Log.e("Failed to stream unapproved images: $e");
      }
    }

    controller.onCancel = () {
      timer?.cancel();
    };

    fetch();
    timer = Timer.periodic(const Duration(seconds: 10), (_) => fetch());

    return controller.stream;
  }

  Stream<List<app.RoomChat>> streamOpenChats(app.ChatUser user) {
    final controller = StreamController<List<app.RoomChat>>.broadcast();
    Timer? timer;

    Future<void> fetch() async {
      if (controller.isClosed) return;
      try {
        final chats = await _client.chat.getOpenChats(user.countryCode, kDebugMode);
        if (!controller.isClosed) {
          controller.sink.add(chats.map(_toAppRoomChat).toList());
        }
      } catch (e) {
        Log.e("Failed to stream open chats: $e");
      }
    }

    controller.onCancel = () {
      timer?.cancel();
    };

    fetch();
    timer = Timer.periodic(const Duration(seconds: 10), (_) => fetch());

    return controller.stream;
  }

  // --- Private chats stream ---

  final StreamController<List<app.PrivateChat>> _privateChatsStreamController =
      StreamController<List<app.PrivateChat>>.broadcast();
  Timer? _privateChatsTimer;

  Stream<List<app.PrivateChat>> getPrivateChatsStream() =>
      _privateChatsStreamController.stream;

  void startPrivateChatsStream(String userId) {
    _privateChatsTimer?.cancel();
    _fetchAndEmitPrivateChats();
    _privateChatsTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchAndEmitPrivateChats(),
    );
  }

  Future<void> _fetchAndEmitPrivateChats() async {
    try {
      final chats = await _client.privateChat.getPrivateChats();
      if (!_privateChatsStreamController.isClosed) {
        _privateChatsStreamController.sink
            .add(chats.map(_toAppPrivateChat).toList());
      }
    } catch (e) {
      Log.e("Failed to get private chats: $e");
    }
  }

  void closePrivateChatStream() {
    _privateChatsTimer?.cancel();
    _privateChatsTimer = null;
    _privateChatsStreamController.close();
  }

  // --- Online users stream ---

  final StreamController<List<app.ChatUser>> _onlineUsersStreamController =
      StreamController<List<app.ChatUser>>.broadcast();
  Timer? _onlineUsersTimer;

  Stream<List<app.ChatUser>> get onlineUsersStream =>
      _onlineUsersStreamController.stream;

  Future<void> startOnlineUsersStream(String countryCode) async {
    _onlineUsersTimer?.cancel();
    _onlineUsersStreamController.sink.add([]);
    await _processor.start();

    await _fetchAndEmitOnlineUsers(countryCode);

    _onlineUsersTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchAndEmitOnlineUsers(countryCode),
    );
  }

  Future<void> _fetchAndEmitOnlineUsers(String countryCode) async {
    try {
      final users = await _client.messaging.getOnlineUsers(
        countryCode: countryCode.isEmpty ? null : countryCode,
      );

      final userData = users
          .map((u) => {
                'id': u.id?.toString() ?? '',
                'data': <String, dynamic>{
                  'last_active': u.lastActive.toIso8601String(),
                  'country_code': u.countryCode,
                  // Pass extra fields needed by processor/fromJson
                  'display_name': u.displayName,
                  'gender': u.gender,
                  'picture_data': u.pictureData,
                  'approved_image': u.approvedImage,
                  'onboarding_completed': u.onboardingCompleted,
                  'is_admin': u.isAdmin,
                  'city': u.city,
                  'country': u.country,
                  'region_name': u.regionName,
                  'presence': u.presence,
                  'show_age': u.showAge,
                  'current_room_chat_id': u.currentRoomChatId?.toString() ?? '',
                  'fcm_token': u.fcmToken,
                  'birth_date': u.birthDate?.toIso8601String(),
                  'blocked_by': u.blockedBy,
                  'image_reports': u.imageReports,
                  'bot_reports': u.botReports,
                  'language_reports': u.languageReports,
                  'kvitter_credits': u.kvitterCredits,
                  'is_premium_user': u.isPremiumUser,
                  'created': DateTime.now().toIso8601String(),
                },
              })
          .toList();

      final processedUsers = await _processor.process(
          userData, getUserId(), countryCode, onlineDuration);

      if (!_onlineUsersStreamController.isClosed) {
        _onlineUsersStreamController.sink.add(processedUsers);
      }
    } catch (e) {
      Log.e("Failed to get online users: $e");
    }
  }

  void closeOnlineUsersStream() {
    _onlineUsersTimer?.cancel();
    _onlineUsersTimer = null;
    _onlineUsersStreamController.close();
    _processor.stop();
  }

  void closeAllStreams() {
    _privateChatsTimer?.cancel();
    _onlineUsersTimer?.cancel();
    _privateChatsStreamController.close();
    _onlineUsersStreamController.close();
    for (final key in _messageTimers.keys.toList()) {
      _messageTimers[key]?.cancel();
    }
    _messageTimers.clear();
    for (final c in _messageStreamControllers.values) {
      c.close();
    }
    _messageStreamControllers.clear();
  }
}
