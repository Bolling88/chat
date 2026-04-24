import 'package:chat/model/chat_user.dart';
import 'package:flutter/material.dart';
import '../utils/enums.dart';
import '../utils/gender.dart';
import '../utils/time_util.dart';
import 'chat.dart';

class PrivateChat extends Chat implements Comparable<PrivateChat> {
  final String initiatedBy;
  final String initiatedByUserName;
  final int initiatedByUserGender;
  final String initiatedByPictureData;
  final String otherUserId;
  final String otherUserName;
  final int otherUserGender;
  final String otherUserPictureData;
  final DateTime created;
  final List<String> lastMessageReadBy;
  final List<String> users;
  final List<ChatUser> userInfos = [];
  final String usersText = "";

  PrivateChat({
    required this.initiatedBy,
    required this.initiatedByUserName,
    required this.initiatedByUserGender,
    required this.initiatedByPictureData,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserGender,
    required this.otherUserPictureData,
    required this.created,
    required this.lastMessageReadBy,
    required this.users,
    required super.id,
    required super.lastMessage,
    required super.lastMessageIsGiphy,
    required super.lastMessageByName,
    required super.lastMessageTimestamp,
    required super.lastMessageUserId,
  });

  @override
  PrivateChat copyWith({
    String? initiatedBy,
    String? initiatedByUserName,
    int? initiatedByUserGender,
    String? initiatedByPictureData,
    String? otherUserId,
    String? otherUserName,
    int? otherUserGender,
    String? otherUserPictureData,
    DateTime? created,
    List<String>? lastMessageReadBy,
    String? id,
    List<String>? users,
    String? lastMessage,
    bool? lastMessageIsGiphy,
    String? lastMessageByName,
    DateTime? lastMessageTimestamp,
    String? lastMessageUserId,
  }) {
    return PrivateChat(
      initiatedBy: initiatedBy ?? this.initiatedBy,
      initiatedByUserName: initiatedByUserName ?? this.initiatedByUserName,
      initiatedByUserGender: initiatedByUserGender ?? this.initiatedByUserGender,
      initiatedByPictureData: initiatedByPictureData ?? this.initiatedByPictureData,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserGender: otherUserGender ?? this.otherUserGender,
      otherUserPictureData: otherUserPictureData ?? this.otherUserPictureData,
      created: created ?? this.created,
      lastMessageReadBy: lastMessageReadBy ?? this.lastMessageReadBy,
      id: id ?? this.id,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageIsGiphy: lastMessageIsGiphy ?? this.lastMessageIsGiphy,
      lastMessageByName: lastMessageByName ?? this.lastMessageByName,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastMessageUserId: lastMessageUserId ?? this.lastMessageUserId,
    );
  }

  PrivateChat.fromJson(String id, Map<String, dynamic> json)
      : initiatedBy = json['initiated_by'] ?? '',
        initiatedByUserName = json['initiated_by_user_name'] ?? '',
        initiatedByUserGender = json['initiated_by_user_gender'] ?? 0,
        initiatedByPictureData = json['initiated_by_picture_data'] ?? '',
        otherUserId = json['other_user_id'] ?? '',
        users = json['users']?.cast<String>() ?? [],
        otherUserName = json['other_user_name'] ?? '',
        otherUserGender = json['other_user_gender'] ?? 0,
        otherUserPictureData = json['other_user_picture_data'] ?? '',
        created = parseDateTime(json['created']),
        lastMessageReadBy = json['last_message_read_by']?.cast<String>() ?? [],
        super(
          id: id,
          lastMessage: json['last_message'] ?? "",
          lastMessageIsGiphy: json['last_message_is_giphy'] ?? false,
          lastMessageByName: json['last_message_by_name'] ?? "",
          lastMessageTimestamp: parseDateTime(json['last_message_timestamp']),
          lastMessageUserId: json['last_message_user_id'] ?? "",
        );

  String getLastMessageReadableDate() {
    return getLastMessageTimeFromDateTime(lastMessageTimestamp);
  }

  @override
  int compareTo(PrivateChat other) {
    return lastMessageTimestamp.compareTo(other.lastMessageTimestamp);
  }

  @override
  List<Object> get props => [
        id, lastMessage, lastMessageIsGiphy, lastMessageByName,
        lastMessageTimestamp, lastMessageUserId, users, userInfos,
        usersText, initiatedBy, initiatedByUserName,
        initiatedByUserGender, initiatedByPictureData,
        otherUserId, otherUserName, otherUserGender,
        otherUserPictureData, created, lastMessageReadBy,
      ];

  @override
  String getChatName(String userId) {
    return userId == initiatedBy ? otherUserName : initiatedByUserName;
  }

  @override
  Color getChatColor(String userId, BuildContext context) {
    return userId == initiatedBy
        ? getGenderColor(context, Gender.fromValue(otherUserGender))
        : getGenderColor(context, Gender.fromValue(initiatedByUserGender));
  }

  @override
  String? getChatImage(String userId) {
    return userId == initiatedBy ? otherUserPictureData : initiatedByPictureData;
  }

  @override
  String getOtherUserId(String userId) {
    return userId == initiatedBy ? otherUserId : initiatedBy;
  }

  @override
  bool isPrivateChat() => true;

  int getOtherUserGender(String userId) {
    return userId == initiatedBy ? initiatedByUserGender : otherUserGender;
  }
}
