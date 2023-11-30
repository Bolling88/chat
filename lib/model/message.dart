import 'package:chat/repository/firestore_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Message extends Equatable implements Comparable<Message> {
  final String id;
  final String text;
  final String createdById;
  final String createdByName;
  final int createdByGender;
  final String createdByCountryCode;
  final String createdByImageUrl;
  final ChatType chatType;
  final int approvedImage;
  final Timestamp created;
  final Timestamp? birthDate;
  final bool showAge;

  Message.fromJson(this.id, Map<String, dynamic> json)
      : created = json['created'] ?? Timestamp.now(),
        createdById = json['createdById'] ?? "",
        createdByName = json['createdByName'] ?? "",
        createdByGender = json['createdByGender'] ?? 0,
        createdByCountryCode = json['createdByCountryCode'] ?? '',
        chatType = ChatType.values[json['chatType'] ?? 0],
        createdByImageUrl = json['createdByImageUrl'] ?? "",
        //For all users who have not updated, show it as true
        approvedImage = json['approvedImage'] ?? ApprovedImage.notSet.value,
        text = json['text'] ?? "",
        birthDate = json['birthDate'],
        showAge = json['showAge'] ?? true;

  @override
  List<Object?> get props => [
        id,
        text,
        chatType,
        createdById,
        createdByName,
        createdByGender,
        createdByCountryCode,
        createdByImageUrl,
        approvedImage,
        created,
        birthDate,
        showAge
      ];

  @override
  int compareTo(Message other) {
    return created.compareTo(other.created);
  }
}
