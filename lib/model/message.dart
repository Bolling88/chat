import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Message extends Equatable implements Comparable<Message> {
  final String id;
  final String text;
  final bool isGiphy;
  final bool isInfoMessage;
  final String createdBy;
  final String createdByImageUrl;
  final Timestamp created;

  Message.fromJson(this.id, Map<String, dynamic> json)
      : created = json['created'] ?? Timestamp.now(),
        createdBy = json['createdBy'] ?? "",
        isGiphy = json['isGiphy'] ?? false,
        isInfoMessage = json['isInfoMessage'] ?? false,
        createdByImageUrl = json['createdByImageUrl'] ?? "",
        text = json['text'] ?? "";

  @override
  List<Object> get props =>
      [id, text, isGiphy, isInfoMessage, createdBy, createdByImageUrl, created];

  @override
  int compareTo(Message other) {
    return created.compareTo(other.created);
  }
}
