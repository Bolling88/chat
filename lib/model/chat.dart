import 'package:chat/model/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../utils/time_util.dart';

class Chat extends Equatable implements Comparable<Chat> {
  final String id;
  final Timestamp created;
  final List<String> users;
  final List<String> contributors;
  final String lastMessage;
  final bool isParty;
  final String clubId;
  final bool lastMessageIsGiphy;
  final bool lastMessageIsInfo;
  final Timestamp lastMessageTimestamp;
  final String lastMessageUserId;
  final List<String> lastMessageReadBy;
  final String chatName;

  final List<ChatUser> userInfos = [];
  final String usersText = "";

  Chat.fromJson(this.id, Map<String, dynamic> json)
      : created = json['created'] ?? Timestamp.now(),
        users = json['users']?.cast<String>() ?? [],
        contributors = json['contributors']?.cast<String>() ?? [],
        lastMessage = json['lastMessage'] ?? "",
        isParty = json['isParty'] ?? false,
        clubId = json['clubId'] ?? "",
        lastMessageIsGiphy = json['lastMessageIsGiphy'] ?? false,
        lastMessageIsInfo = json['lastMessageIsInfo'] ?? false,
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

  String getPartyChatName(BuildContext context) {
    if (chatName.isNotEmpty && clubId.isNotEmpty) {
      return chatName;
    } else if (chatName.isNotEmpty && clubId.isEmpty) {
      return '${chatName}';
    } else
      return FlutterI18n.translate(context, "party_chat");
  }

  @override
  List<Object> get props => [
        id,
        created,
        lastMessage,
        lastMessageTimestamp,
        lastMessageUserId,
        users,
        contributors,
        userInfos,
        lastMessageIsInfo,
        lastMessageIsGiphy,
        lastMessageReadBy,
        chatName,
        usersText,
        isParty,
      ];
}
