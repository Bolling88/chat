import 'dart:async';

import 'package:chat/model/message.dart';
import 'package:chat/model/private_chat.dart';
import 'package:chat/model/room_chat.dart';
import 'package:chat/model/user_location.dart';
import 'package:chat/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/chat_user.dart';
import '../utils/auth_util.dart';
import '../utils/log.dart';
import '../utils/online_users_processor.dart';

class SupabaseRepository {
  final OnlineUserProcessor _processor;
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseRepository(this._processor);

  // =============================================
  // USER OPERATIONS
  // =============================================

  Future<ChatUser?> getUser({String? userId}) async {
    try {
      final uid = userId ?? _client.auth.currentUser?.id;
      if (uid == null) return null;
      final data = await _client.from('users').select().eq('id', uid).maybeSingle();
      if (data == null) return null;
      return ChatUser.fromJson(data['id'] as String, data);
    } catch (e) {
      Log.e("Failed to fetch user: $e");
      return null;
    }
  }

  Future<void> setInitialUserData(String email, String userId) async {
    try {
      await _client.from('users').upsert({
        'id': userId,
        'email': email,
        'approved_image': ApprovedImage.notReviewed.value,
        'created': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Log.e("Failed to add user: $e");
    }
  }

  Future<void> updateUserGender(Gender gender) async {
    try {
      await _client.from('users').update({
        'gender': gender.value,
        'last_active': DateTime.now().toIso8601String(),
      }).eq('id', getUserId());
    } catch (e) {
      Log.e("Failed to update user gender: $e");
    }
  }

  Future<void> updateUserBirthday(DateTime birthDate) async {
    try {
      await _client.from('users').update({
        'birth_date': birthDate.toIso8601String(),
        'last_active': DateTime.now().toIso8601String(),
      }).eq('id', getUserId());
    } catch (e) {
      Log.e("Failed to update user birthdate: $e");
    }
  }

  Future<void> updateUserShowAge(bool showAge) async {
    try {
      await _client.from('users').update({
        'show_age': showAge,
        'last_active': DateTime.now().toIso8601String(),
      }).eq('id', getUserId());
    } catch (e) {
      Log.e("Failed to update user show age: $e");
    }
  }

  Future<void> updateUserDisplayName(String fullName, List<String> searchArray) async {
    try {
      await _client.from('users').update({
        'display_name': fullName,
        'search_array': searchArray,
        'last_active': DateTime.now().toIso8601String(),
      }).eq('id', getUserId());
    } catch (e) {
      Log.e("Failed to update user displayName: $e");
    }
  }

  Future<void> updateUserProfileImage({
    required String profileImageUrl,
    required ChatUser user,
    required bool hasNudity,
  }) async {
    try {
      await _client.from('users').update({
        'last_active': DateTime.now().toIso8601String(),
        'picture_data': profileImageUrl,
        'approved_image': hasNudity ? ApprovedImage.notReviewed.value : ApprovedImage.approved.value,
        'image_reports': <String>[],
      }).eq('id', getUserId());
    } catch (e) {
      Log.e("Failed to update user image: $e");
    }
  }

  Future<bool> getIsNameAvailable(String displayName) async {
    try {
      final data = await _client
          .from('users')
          .select('id')
          .eq('display_name', displayName)
          .limit(1);
      return (data as List).isEmpty;
    } catch (e) {
      Log.e("Failed to check name: $e");
      return false;
    }
  }

  Future<void> updateUserOnLogout() async {
    await _client.from('users').update({
      'presence': false,
      'fcm_token': '',
      'last_active': DateTime.now().toIso8601String(),
    }).eq('id', getUserId());
  }

  void updateUserLocation(UserLocation userLocation) {
    _client.from('users').update({
      'city': userLocation.city,
      'country_code': userLocation.countryCode,
      'country': userLocation.countryName,
      'region_name': userLocation.state,
      'last_active': DateTime.now().toIso8601String(),
    }).eq('id', getUserId());
  }

  void setUserAsActive() {
    _client.from('users').update({
      'presence': true,
      'last_active': DateTime.now().toIso8601String(),
    }).eq('id', getUserId());
  }

  void updateCurrentUsersCurrentChatRoom({required String chatId}) {
    _client.from('users').update({
      'current_room_chat_id': chatId,
      'presence': true,
      'last_active': DateTime.now().toIso8601String(),
    }).eq('id', getUserId());
  }

  void saveFcmTokenOnUser(String fcmToken) {
    _client.from('users').update({
      'fcm_token': fcmToken,
      'last_active': DateTime.now().toIso8601String(),
    }).eq('id', getUserId());
  }

  void updateImageNotReviewedStatus() {
    _client.from('users').update({
      'approved_image': ApprovedImage.notReviewed.value,
    }).eq('id', getUserId());
  }

  Future<void> deleteUserPhoto() async {
    await _client.from('users').update({
      'picture_data': '',
      'approved_image': ApprovedImage.notReviewed.value,
    }).eq('id', getUserId());
  }

  Future<void> deleteUserAndFiles() async {
    final userId = getUserId();
    try {
      await _client.from('users').delete().eq('id', userId);
    } catch (e) {
      Log.e("Error deleting user: $e");
    }
  }

  Future<void> setUserAsPremium(bool isPremiumUser) async {
    await _client.from('users').update({
      'is_premium_user': isPremiumUser,
    }).eq('id', getUserId());
  }

  // =============================================
  // BLOCK / REPORT OPERATIONS
  // =============================================

  Future<void> blockUser(String id) async {
    final data = await _client.from('users').select('blocked_by').eq('id', id).single();
    final blockedBy = List<String>.from(data['blocked_by'] ?? []);
    if (!blockedBy.contains(getUserId())) {
      blockedBy.add(getUserId());
      await _client.from('users').update({'blocked_by': blockedBy}).eq('id', id);
    }
  }

  Future<void> unblockUser(String id) async {
    final data = await _client.from('users').select('blocked_by').eq('id', id).single();
    final blockedBy = List<String>.from(data['blocked_by'] ?? []);
    blockedBy.remove(getUserId());
    await _client.from('users').update({'blocked_by': blockedBy}).eq('id', id);
  }

  void reportMessage(Message message) async {
    await _client.from('reports').insert({
      'message_id': message.id,
      'message_text': message.text,
      'message_created': message.created.toIso8601String(),
      'message_created_by': message.createdById,
      'message_created_by_gender': message.createdByGender,
      'message_created_by_country_code': message.createdByCountryCode,
      'message_created_by_image_url': message.createdByImageUrl,
      'message_created_by_display_name': message.createdByName,
      'reported_by': getUserId(),
    });
  }

  Future<void> postInappropriateImageReport(String reportedUserId) async {
    final data = await _client.from('users').select('image_reports').eq('id', reportedUserId).single();
    final reports = List<String>.from(data['image_reports'] ?? []);
    if (!reports.contains(getUserId())) reports.add(getUserId());
    await _client.from('users').update({
      'image_reports': reports,
      'approved_image': ApprovedImage.notReviewed.value,
    }).eq('id', reportedUserId);
  }

  Future<void> postBotReport(String reportedUserId) async {
    final data = await _client.from('users').select('bot_reports').eq('id', reportedUserId).single();
    final reports = List<String>.from(data['bot_reports'] ?? []);
    if (!reports.contains(getUserId())) reports.add(getUserId());
    await _client.from('users').update({'bot_reports': reports}).eq('id', reportedUserId);
  }

  Future<void> postHatefulLanguageReport(String reportedUserId) async {
    final data = await _client.from('users').select('language_reports').eq('id', reportedUserId).single();
    final reports = List<String>.from(data['language_reports'] ?? []);
    if (!reports.contains(getUserId())) reports.add(getUserId());
    await _client.from('users').update({'language_reports': reports}).eq('id', reportedUserId);
  }

  // =============================================
  // ADMIN / MODERATION
  // =============================================

  Future<void> approveImage(String id) async {
    await _client.from('users').update({
      'approved_image': ApprovedImage.approved.value,
      'image_reports': <String>[],
    }).eq('id', id);
  }

  Future<void> rejectImage(String id) async {
    await _client.from('users').update({
      'approved_image': ApprovedImage.notApproved.value,
    }).eq('id', id);
  }

  // =============================================
  // CREDITS
  // =============================================

  Future<void> reduceUserCredits(String id, int i) async {
    await _client.rpc('increment_credits', params: {'target_user_id': id, 'amount': -i});
  }

  Future<void> increaseUserCredits(String id, int i) async {
    await _client.rpc('increment_credits', params: {'target_user_id': id, 'amount': i});
  }

  // =============================================
  // FEEDBACK
  // =============================================

  void postFeedback(String feedback, ChatUser user) {
    _client.from('feedback').insert({
      'feedback': feedback,
      'created_by_id': getUserId(),
      'created_by_name': user.displayName,
      'created_by_country_code': user.countryCode,
      'created_by_country_name': user.country,
    });
  }

  // =============================================
  // CHAT OPERATIONS
  // =============================================

  Future<RoomChat?> getChat(String chatId, bool isPrivateChat) async {
    try {
      final table = isPrivateChat ? 'private_chats' : 'chats';
      final data = await _client.from(table).select().eq('id', chatId).maybeSingle();
      if (data == null) return null;
      return RoomChat.fromJson(data['id'] as String, data);
    } catch (e) {
      Log.e("Failed to get chat: $e");
      return null;
    }
  }

  // =============================================
  // MESSAGE OPERATIONS
  // =============================================

  Future<List<Message>> getInitialMessages(String chatId, bool isPrivateChat) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .eq('is_private', isPrivateChat)
        .order('created', ascending: false)
        .limit(20);
    return (data as List).map((e) => Message.fromJson(e['id'] as String, e)).toList();
  }

  Future<List<Message>> getMoreMessages(
      String chatId, bool isPrivateChat, DateTime before) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .eq('is_private', isPrivateChat)
        .lt('created', before.toIso8601String())
        .order('created', ascending: false)
        .limit(20);
    return (data as List).map((e) => Message.fromJson(e['id'] as String, e)).toList();
  }

  Future<void> postMessage({
    required String chatId,
    required ChatUser user,
    required String message,
    required ChatType chatType,
    required bool isPrivateChat,
    bool isGiphy = false,
    String? sendPushToUserId,
    Message? replyMessage,
  }) async {
    if (isPrivateChat) {
      if (chatType == ChatType.message || chatType == ChatType.giphy || chatType == ChatType.image) {
        await _client.from('messages').insert({
          'chat_id': chatId,
          'is_private': true,
          'text': message,
          'chat_type': chatType.value,
          'created_by_id': getUserId(),
          'created_by_name': user.displayName,
          'created_by_gender': user.gender,
          'created_by_country_code': user.countryCode,
          'created_by_image_url': user.pictureData,
          'approved_image': user.approvedImage,
          'birth_date': user.birthDate?.toIso8601String(),
          'show_age': user.showAge,
          'image_reports': user.imageReports,
          'reply_id': replyMessage?.id,
          'reply_text': replyMessage?.text,
          'reply_chat_type': replyMessage?.chatType.value,
          'reply_created_by_id': replyMessage?.createdById,
          'reply_created_by_name': replyMessage?.createdByName,
          'reply_created_by_gender': replyMessage?.createdByGender,
          'reply_created_by_country_code': replyMessage?.createdByCountryCode,
          'reply_created_by_image_url': replyMessage?.createdByImageUrl,
          'reply_approved_image': replyMessage?.approvedImage,
          'reply_created': replyMessage?.created.toIso8601String(),
          'reply_birth_date': replyMessage?.birthDate?.toIso8601String(),
          'reply_show_age': replyMessage?.showAge,
          'reply_image_reports': replyMessage?.imageReports,
        });
      }
    } else {
      await _client.from('messages').insert({
        'chat_id': chatId,
        'is_private': false,
        'text': message,
        'chat_type': chatType.value,
        'created_by_id': getUserId(),
        'created_by_name': user.displayName,
        'created_by_gender': user.gender,
        'created_by_country_code': user.countryCode,
        'created_by_image_url': user.pictureData,
        'approved_image': user.approvedImage,
        'birth_date': user.birthDate?.toIso8601String(),
        'show_age': user.showAge,
        'image_reports': user.imageReports,
        'reply_id': replyMessage?.id,
        'reply_text': replyMessage?.text,
        'reply_chat_type': replyMessage?.chatType.value,
        'reply_created_by_id': replyMessage?.createdById,
        'reply_created_by_name': replyMessage?.createdByName,
        'reply_created_by_gender': replyMessage?.createdByGender,
        'reply_created_by_country_code': replyMessage?.createdByCountryCode,
        'reply_created_by_image_url': replyMessage?.createdByImageUrl,
        'reply_approved_image': replyMessage?.approvedImage,
        'reply_created': replyMessage?.created.toIso8601String(),
        'reply_birth_date': replyMessage?.birthDate?.toIso8601String(),
        'reply_show_age': replyMessage?.showAge,
        'reply_image_reports': replyMessage?.imageReports,
      });
    }

    if (chatType == ChatType.message || chatType == ChatType.giphy) {
      if (isPrivateChat) {
        await _client.from('private_chats').update({
          'last_message': message,
          'last_message_is_giphy': chatType == ChatType.giphy,
          'last_message_by_name': user.displayName,
          'last_message_read_by': [getUserId()],
          'last_message_timestamp': DateTime.now().toIso8601String(),
          'last_message_user_id': getUserId(),
          'send_push_to_user_id': sendPushToUserId,
        }).eq('id', chatId);
      }
    }
  }

  // =============================================
  // PRIVATE CHAT OPERATIONS
  // =============================================

  Future<PrivateChat?> createPrivateChat({
    required ChatUser myUser,
    required ChatUser otherUser,
    required String initialMessage,
  }) async {
    final trimmedMessage = initialMessage.trim();
    if (trimmedMessage.isEmpty || trimmedMessage.length > 1000) return null;
    try {
      final data = await _client.from('private_chats').insert({
        'users': [myUser.id, otherUser.id],
        'initiated_by': getUserId(),
        'initiated_by_user_name': myUser.displayName,
        'initiated_by_user_gender': myUser.gender,
        'initiated_by_picture_data': myUser.pictureData,
        'chat_name': '${otherUser.displayName} ${myUser.displayName}',
        'other_user_id': otherUser.id,
        'other_user_name': otherUser.displayName,
        'other_user_gender': otherUser.gender,
        'other_user_picture_data': otherUser.pictureData,
        'send_push_to_user_id': otherUser.id,
        'last_message_read_by': [getUserId()],
      }).select().single();

      await postMessage(
        chatId: data['id'] as String,
        user: myUser,
        message: trimmedMessage,
        isPrivateChat: true,
        chatType: ChatType.message,
        sendPushToUserId: otherUser.id,
      );
    } catch (e) {
      Log.e(e);
    }
    return null;
  }

  Future<bool> isPrivateChatAvailable(String userId) async {
    try {
      final data = await _client
          .from('private_chats')
          .select()
          .contains('users', [getUserId()]);
      final chats = (data as List)
          .map((e) => PrivateChat.fromJson(e['id'] as String, e))
          .where((e) => e.users.contains(userId));
      return chats.isEmpty;
    } catch (e) {
      Log.e("Failed to get chat: $e");
      return false;
    }
  }

  Future<void> leavePrivateChat(PrivateChat selectedChat) async {
    try {
      final data = await _client
          .from('private_chats')
          .select('users')
          .eq('id', selectedChat.id)
          .single();
      final users = List<String>.from(data['users'] ?? []);
      users.remove(getUserId());
      await _client.from('private_chats').update({'users': users}).eq('id', selectedChat.id);
    } catch (e) {
      Log.e("Failed to leave private chat: $e");
    }
  }

  Future<PrivateChat?> getPrivateChat(String userId) async {
    try {
      final data = await _client
          .from('private_chats')
          .select()
          .contains('users', [getUserId()]);
      return (data as List)
          .map((e) => PrivateChat.fromJson(e['id'] as String, e))
          .where((e) => e.users.contains(userId))
          .firstOrNull;
    } catch (e) {
      Log.e("Failed to fetch private chat: $e");
      return null;
    }
  }

  Future<void> setLastMessageRead({required String chatId}) async {
    try {
      final data = await _client
          .from('private_chats')
          .select('last_message_read_by')
          .eq('id', chatId)
          .single();
      final readBy = List<String>.from(data['last_message_read_by'] ?? []);
      if (!readBy.contains(getUserId())) {
        readBy.add(getUserId());
        await _client.from('private_chats').update({'last_message_read_by': readBy}).eq('id', chatId);
      }
    } catch (e) {
      Log.e(e);
    }
  }

  Future<void> leaveAllPrivateChats() async {
    final data = await _client
        .from('private_chats')
        .select()
        .contains('users', [getUserId()]);
    for (var doc in (data as List)) {
      await leavePrivateChat(PrivateChat.fromJson(doc['id'] as String, doc));
    }
  }

  // =============================================
  // STREAM OPERATIONS (REALTIME)
  // =============================================

  Stream<List<Message>> streamMessages(String chatId, bool isPrivateChat, int limit) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created', ascending: false)
        .limit(limit)
        .map((data) => data
            .where((e) => e['is_private'] == isPrivateChat)
            .map((e) => Message.fromJson(e['id'] as String, e))
            .toList());
  }

  Stream<ChatUser?> streamUser() {
    final userId = getUserId();
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isEmpty ? null : ChatUser.fromJson(data.first['id'] as String, data.first));
  }

  Stream<ChatUser?> streamUserById(String userId) {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isEmpty ? null : ChatUser.fromJson(data.first['id'] as String, data.first));
  }

  Stream<List<ChatUser>> streamUnapprovedImages() {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('approved_image', 0)
        .map((data) => data
            .where((e) => (e['picture_data'] ?? '').toString().isNotEmpty)
            .map((e) => ChatUser.fromJson(e['id'] as String, e))
            .toList());
  }

  Stream<List<RoomChat>> streamOpenChats(ChatUser user) {
    if (kDebugMode) {
      return _client
          .from('chats')
          .stream(primaryKey: ['id'])
          .map((data) => data
              .map((e) => RoomChat.fromJson(e['id'] as String, e))
              .toList());
    } else {
      return _client
          .from('chats')
          .stream(primaryKey: ['id'])
          .eq('enabled', true)
          .map((data) => data
              .where((e) => e['country_code'] == 'all' || e['country_code'] == user.countryCode)
              .map((e) => RoomChat.fromJson(e['id'] as String, e))
              .toList());
    }
  }

  final StreamController<List<PrivateChat>> _privateChatsStreamController =
      StreamController<List<PrivateChat>>.broadcast();
  RealtimeChannel? _privateChatsChannel;

  Stream<List<PrivateChat>> getPrivateChatsStream() => _privateChatsStreamController.stream;

  void startPrivateChatsStream(String userId) {
    _privateChatsChannel?.unsubscribe();

    _fetchAndEmitPrivateChats(userId);

    _privateChatsChannel = _client.channel('private-chats-$userId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'private_chats',
        callback: (_) => _fetchAndEmitPrivateChats(userId),
      )
      .subscribe();
  }

  Future<void> _fetchAndEmitPrivateChats(String userId) async {
    try {
      final data = await _client
          .from('private_chats')
          .select()
          .contains('users', [userId]);
      final chats = (data as List)
          .map((e) => PrivateChat.fromJson(e['id'] as String, e))
          .toList();
      if (!_privateChatsStreamController.isClosed) {
        _privateChatsStreamController.sink.add(chats);
      }
    } catch (e) {
      Log.e("Failed to get private chats: $e");
    }
  }

  void closePrivateChatStream() {
    _privateChatsChannel?.unsubscribe();
    _privateChatsStreamController.close();
  }

  final StreamController<List<ChatUser>> _onlineUsersStreamController =
      StreamController<List<ChatUser>>.broadcast();
  RealtimeChannel? _onlineUsersChannel;

  Stream<List<ChatUser>> get onlineUsersStream => _onlineUsersStreamController.stream;

  Future<void> startOnlineUsersStream(String countryCode) async {
    _onlineUsersChannel?.unsubscribe();
    _onlineUsersStreamController.sink.add([]);
    await _processor.start();

    _fetchAndEmitOnlineUsers(countryCode);

    _onlineUsersChannel = _client.channel('online-users')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'users',
        callback: (_) => _fetchAndEmitOnlineUsers(countryCode),
      )
      .subscribe();
  }

  Future<void> _fetchAndEmitOnlineUsers(String countryCode) async {
    try {
      final cutoff = DateTime.now().subtract(onlineDuration);
      final data = await _client
          .from('users')
          .select()
          .gte('last_active', cutoff.toIso8601String());

      final userData = (data as List)
          .map((e) => {'id': e['id'] as String, 'data': e as Map<String, dynamic>})
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
    _onlineUsersChannel?.unsubscribe();
    _onlineUsersStreamController.close();
    _processor.stop();
  }

  void closeAllStreams() {
    _privateChatsChannel?.unsubscribe();
    _onlineUsersChannel?.unsubscribe();
    _privateChatsStreamController.close();
    _onlineUsersStreamController.close();
  }
}
