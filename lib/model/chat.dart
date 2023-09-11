import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class Chat extends Equatable {
  final String id;
  final List<String> users;
  final String lastMessage;
  final String lastMessageByName;
  final Timestamp lastMessageTimestamp;
  final String lastMessageUserId;
  final List<String> lastMessageReadBy;

  const Chat({
    required this.id,
    required this.users,
    required this.lastMessage,
    required this.lastMessageByName,
    required this.lastMessageTimestamp,
    required this.lastMessageUserId,
    required this.lastMessageReadBy,
  });

  String getChatName(String userId);

  @override
  List<Object> get props => [];
}
