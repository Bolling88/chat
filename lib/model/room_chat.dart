import 'package:chat/model/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/time_util.dart';
import 'chat.dart';

class RoomChat extends Chat implements Comparable<RoomChat> {
  final String countryCode;
  final String chatName;
  final int chatColor;
  final String imageUrl;
  final int imageOverflow;
  final int imageTranslationX;

  final List<ChatUser> userInfos = [];
  final String usersText = "";

  RoomChat.fromJson(String id, Map<String, dynamic> json)
      : countryCode = json['countryCode'] ?? 'en',
        chatName = json['chatName'] ?? "",
        chatColor = json['chatColor'] ?? 0xFF30c7c2,
        imageUrl = json['imageUrl'] ?? "",
        imageOverflow = json['imageOverflow'] ?? 80,
        imageTranslationX = json['imageTranslationX'] ?? 0,
        super(
          id: id,
          users: json['users']?.cast<String>() ?? [],
          lastMessage: json['lastMessage'] ?? "",
          lastMessageByName: json['lastMessageByName'] ?? "",
          lastMessageTimestamp: json['lastMessageTimestamp'] ?? Timestamp.now(),
          lastMessageUserId: json['lastMessageUserId'] ?? "",
          lastMessageReadBy: json['lastMessageReadBy']?.cast<String>() ?? [],
        ); // Call the superclass constructor;

  String getLastMessageReadableDate() {
    return getLastMessageTimeFromTimeStamp(lastMessageTimestamp);
  }

  @override
  int compareTo(RoomChat other) {
    return lastMessageTimestamp.compareTo(other.lastMessageTimestamp);
  }

  @override
  List<Object> get props => [
        id,
        countryCode,
        lastMessage,
        lastMessageByName,
        lastMessageTimestamp,
        lastMessageUserId,
        users,
        userInfos,
        lastMessageReadBy,
        chatName,
        chatColor,
        usersText,
        imageUrl,
        imageOverflow,
        imageTranslationX
      ];

  @override
  String getChatName(String userId) {
    return chatName;
  }
}
