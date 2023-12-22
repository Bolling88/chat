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
  final String? translation;
  final bool marked;
  final List<String> imageReports;

  const Message({
    required this.id,
    required this.text,
    required this.createdById,
    required this.createdByName,
    required this.createdByGender,
    required this.createdByCountryCode,
    required this.createdByImageUrl,
    required this.chatType,
    required this.approvedImage,
    required this.created,
    this.birthDate,
    required this.showAge,
    this.translation,
    required this.marked,
    required this.imageReports,

  });

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
        showAge = json['showAge'] ?? true,
        translation = null,
        marked = false,
        imageReports = json['imageReports']?.cast<String>() ?? [];

  //Copy with method
  Message copyWith({
    String? id,
    String? text,
    String? createdById,
    String? createdByName,
    int? createdByGender,
    String? createdByCountryCode,
    String? createdByImageUrl,
    ChatType? chatType,
    int? approvedImage,
    Timestamp? created,
    Timestamp? birthDate,
    bool? showAge,
    String? translation,
    bool? marked,
    List<String>? imageReports,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      createdByGender: createdByGender ?? this.createdByGender,
      createdByCountryCode: createdByCountryCode ?? this.createdByCountryCode,
      createdByImageUrl: createdByImageUrl ?? this.createdByImageUrl,
      chatType: chatType ?? this.chatType,
      approvedImage: approvedImage ?? this.approvedImage,
      created: created ?? this.created,
      birthDate: birthDate ?? this.birthDate,
      showAge: showAge ?? this.showAge,
      translation: translation ?? this.translation,
      marked: marked ?? this.marked,
      imageReports: imageReports ?? this.imageReports,
    );
  }

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
        showAge,
        translation,
        marked,
        imageReports,
      ];

  @override
  int compareTo(Message other) {
    return created.compareTo(other.created);
  }
}
