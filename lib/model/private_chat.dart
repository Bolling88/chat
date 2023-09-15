import 'package:chat/model/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final List<String> lastMessageReadBy;
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
    required this.lastMessageReadBy,
    required String id,
    required List<String> users,
    required String lastMessage,
    required String lastMessageByName,
    required Timestamp lastMessageTimestamp,
    required String lastMessageUserId,
  }) : super(
          id: id,
          users: users,
          lastMessage: lastMessage,
          lastMessageByName: lastMessageByName,
          lastMessageTimestamp: lastMessageTimestamp,
          lastMessageUserId: lastMessageUserId,
        );

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
    List<String>? lastMessageReadBy,
    String? id,
    List<String>? users,
    String? lastMessage,
    String? lastMessageByName,
    Timestamp? lastMessageTimestamp,
    String? lastMessageUserId,
  }) {
    return PrivateChat(
      initiatedBy: initiatedBy ?? this.initiatedBy,
      initiatedByUserName: initiatedByUserName ?? this.initiatedByUserName,
      initiatedByUserGender:
          initiatedByUserGender ?? this.initiatedByUserGender,
      initiatedByPictureData:
          initiatedByPictureData ?? this.initiatedByPictureData,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserGender: otherUserGender ?? this.otherUserGender,
      otherUserPictureData: otherUserPictureData ?? this.otherUserPictureData,
      lastMessageReadBy: lastMessageReadBy ?? this.lastMessageReadBy,
      id: id ?? this.id,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageByName: lastMessageByName ?? this.lastMessageByName,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastMessageUserId: lastMessageUserId ?? this.lastMessageUserId,
    );
  }

  PrivateChat.fromJson(String id, Map<String, dynamic> json)
      : initiatedBy = json['initiatedBy'] ?? '',
        initiatedByUserName = json['initiatedByUserName'] ?? '',
        initiatedByUserGender = json['initiatedByUserGender'] ?? 0,
        initiatedByPictureData = json['initiatedByPictureData'] ?? '',
        otherUserId = json['otherUserId'] ?? '',
        otherUserName = json['otherUserName'] ?? '',
        otherUserGender = json['otherUserGender'] ?? 0,
        otherUserPictureData = json['otherUserPictureData'] ?? '',
        lastMessageReadBy = json['lastMessageReadBy']?.cast<String>() ?? [],
        super(
          id: id,
          users: json['users']?.cast<String>() ?? [],
          lastMessage: json['lastMessage'] ?? "",
          lastMessageByName: json['lastMessageByName'] ?? "",
          lastMessageTimestamp: json['lastMessageTimestamp'] ?? Timestamp.now(),
          lastMessageUserId: json['lastMessageUserId'] ?? "",
        );

  String getLastMessageReadableDate() {
    return getLastMessageTimeFromTimeStamp(lastMessageTimestamp);
  }

  @override
  int compareTo(PrivateChat other) {
    return lastMessageTimestamp.compareTo(other.lastMessageTimestamp);
  }

  @override
  List<Object> get props => [
        id,
        lastMessage,
        lastMessageByName,
        lastMessageTimestamp,
        lastMessageUserId,
        users,
        userInfos,
        usersText,
        initiatedBy,
        initiatedByUserName,
        initiatedByUserGender,
        initiatedByPictureData,
        otherUserId,
        otherUserName,
        otherUserGender,
        otherUserPictureData,
        lastMessageReadBy,
      ];

  @override
  String getChatName(String userId) {
    return userId == initiatedBy ? otherUserName : initiatedByUserName;
  }
}
