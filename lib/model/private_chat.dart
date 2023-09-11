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

  final List<ChatUser> userInfos = [];
  final String usersText = "";

  PrivateChat.fromJson(String id, Map<String, dynamic> json)
      : initiatedBy = json['initiatedBy'] ?? '',
        initiatedByUserName = json['initiatedByUserName'] ?? '',
        initiatedByUserGender = json['initiatedByUserGender'] ?? 0,
        initiatedByPictureData = json['initiatedByPictureData'] ?? '',
        otherUserId = json['otherUserId'] ?? '',
        otherUserName = json['otherUserName'] ?? '',
        otherUserGender = json['otherUserGender'] ?? 0,
        otherUserPictureData = json['otherUserPictureData'] ?? '',
        super(
          id: id,
          users: json['users']?.cast<String>() ?? [],
          lastMessage: json['lastMessage'] ?? "",
          lastMessageByName: json['lastMessageByName'] ?? "",
          lastMessageTimestamp: json['lastMessageTimestamp'] ?? Timestamp.now(),
          lastMessageUserId: json['lastMessageUserId'] ?? "",
          lastMessageReadBy: json['lastMessageReadBy']?.cast<String>() ?? [],
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
        lastMessageReadBy,
        usersText,
        initiatedBy,
        initiatedByUserName,
        initiatedByUserGender,
        initiatedByPictureData,
        otherUserId,
        otherUserName,
        otherUserGender,
        otherUserPictureData,
      ];

  @override
  String getChatName(String userId) {
    return userId == initiatedBy ? otherUserName : initiatedByUserName;
  }
}
