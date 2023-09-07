import 'package:chat/model/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../utils/time_util.dart';

class Chat extends Equatable implements Comparable<Chat> {
  final String id;
  final List<String> users;
  final String lastMessage;
  final String lastMessageByName;
  final String countryCode;
  final Timestamp lastMessageTimestamp;
  final String lastMessageUserId;
  final List<String> lastMessageReadBy;
  final String initiatedBy;
  final String chatName;
  final String imageUrl;
  final int imageOverflow;
  final int imageTranslationX;

  final List<ChatUser> userInfos = [];
  final String usersText = "";

  Chat.fromJson(this.id, Map<String, dynamic> json)
      : countryCode = json['countryCode'] ?? 'en',
        users = json['users']?.cast<String>() ?? [],
        lastMessage = json['lastMessage'] ?? "",
        lastMessageByName = json['lastMessageByName'] ?? "",
        lastMessageTimestamp = json['lastMessageTimestamp'] ?? Timestamp.now(),
        lastMessageUserId = json['lastMessageUserId'] ?? "",
        lastMessageReadBy = json['lastMessageReadBy']?.cast<String>() ?? [],
        initiatedBy = json['initiatedBy'] ?? "",
        chatName = json['chatName'] ?? "",
        imageUrl = json['imageUrl'] ?? "",
        imageOverflow = json['imageOverflow'] ?? 80,
        imageTranslationX = json['imageTranslationX'] ?? 0;

  String getLastMessageReadableDate() {
    return getLastMessageTimeFromTimeStamp(lastMessageTimestamp);
  }

  @override
  int compareTo(Chat other) {
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
        initiatedBy,
        usersText,
        imageUrl,
    imageOverflow,
    imageTranslationX
      ];
}
