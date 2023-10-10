import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'chat_user.dart';

abstract class Chat extends Equatable {
  final String id;
  final String lastMessage;
  final String lastMessageByName;
  final Timestamp lastMessageTimestamp;
  final String lastMessageUserId;

  const Chat({
    required this.id,
    required this.lastMessage,
    required this.lastMessageByName,
    required this.lastMessageTimestamp,
    required this.lastMessageUserId,
  });

  String getChatName(String userId);

  Color getChatColor(String userId);

  @override
  List<Object> get props => [];

  Chat copyWith({
    String? id,
    String? lastMessage,
    String? lastMessageByName,
    Timestamp? lastMessageTimestamp,
    String? lastMessageUserId,
  });
}
