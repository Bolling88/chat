import 'package:chat/repository/firestore_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Message extends Equatable implements Comparable<Message> {
  final String id;
  final String text;
  final String createdById;
  final String createdByName;
  final String createdByImageUrl;
  final ChatType chatType;
  final Timestamp created;

  Message.fromJson(this.id, Map<String, dynamic> json)
      : created = json['created'] ?? Timestamp.now(),
        createdById = json['createdById'] ?? "",
        createdByName = json['createdByName'] ?? "",
        chatType = ChatType.values[json['chatType'] ?? 0],
        createdByImageUrl = json['createdByImageUrl'] ?? "",
        text = json['text'] ?? "";

  @override
  List<Object> get props => [
        id,
        text,
        chatType,
        createdById,
        createdByName,
        createdByImageUrl,
        created
      ];

  @override
  int compareTo(Message other) {
    return created.compareTo(other.created);
  }
}
