import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class Chat extends Equatable {
  final String id;
  final String lastMessage;
  final bool lastMessageIsGiphy;
  final String lastMessageByName;
  final Timestamp lastMessageTimestamp;
  final String lastMessageUserId;

  const Chat({
    required this.id,
    required this.lastMessage,
    required this.lastMessageIsGiphy,
    required this.lastMessageByName,
    required this.lastMessageTimestamp,
    required this.lastMessageUserId,
  });

  String getChatName(String userId);

  Color getChatColor(String userId, BuildContext context);

  String? getChatImage(String userId);

  String getOtherUserId(String userId);

  bool isPrivateChat();

  Chat copyWith({
    String? id,
    String? lastMessage,
    bool? lastMessageIsGiphy,
    String? lastMessageByName,
    Timestamp? lastMessageTimestamp,
    String? lastMessageUserId,
  });

}
