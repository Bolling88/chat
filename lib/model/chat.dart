import 'package:chat/model/chat_user.dart';
import 'package:chat/repository/firestore_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../utils/time_util.dart';

class Chat extends Equatable implements Comparable<Chat> {
  final String id;
  final Timestamp created;
  final List<String> users;
  final String lastMessage;
  final ChatType chatType;
  final Timestamp lastMessageTimestamp;
  final String lastMessageUserId;
  final List<String> lastMessageReadBy;
  final String chatName;

  final List<ChatUser> userInfos = [];
  final String usersText = "";

  Chat.fromJson(this.id, Map<String, dynamic> json)
      : created = json['created'] ?? Timestamp.now(),
        users = json['users']?.cast<String>() ?? [],
        lastMessage = json['lastMessage'] ?? "",
        chatType = ChatType.values[json['chatType'] ?? 0],
        lastMessageTimestamp = json['lastMessageTimestamp'] ?? Timestamp.now(),
        lastMessageUserId = json['lastMessageUserId'] ?? "",
        lastMessageReadBy = json['lastMessageReadBy']?.cast<String>() ?? [],
        chatName = json['chatName'] ?? "";

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
        created,
        lastMessage,
        lastMessageTimestamp,
        lastMessageUserId,
        users,
        userInfos,
        chatType,
        lastMessageReadBy,
        chatName,
        usersText,
      ];
}
