import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class Chat extends Equatable {
  final String id;
  final List<String> users;
  final String lastMessage;
  final String lastMessageByName;
  final Timestamp lastMessageTimestamp;
  final String lastMessageUserId;

  const Chat({
    required this.id,
    required this.users,
    required this.lastMessage,
    required this.lastMessageByName,
    required this.lastMessageTimestamp,
    required this.lastMessageUserId,
  });

  String getChatName(String userId);

  @override
  List<Object> get props => [];

  Chat copyWith({
    String? id,
    List<String>? users,
    String? lastMessage,
    String? lastMessageByName,
    Timestamp? lastMessageTimestamp,
    String? lastMessageUserId,
  });
}
