import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'dart:core';

class ChatUser extends Equatable {
  final String id;
  final String name;
  final int gender;
  final String pictureData;
  final bool onboardingCompleted;
  final Timestamp created;

  const ChatUser(this.id, this.name, this.gender, this.pictureData,
      this.onboardingCompleted, this.created);

  ChatUser.fromJson(this.id, Map<String, dynamic> json)
      : created = json['created'] ?? Timestamp.now(),
        name = json['name'] ?? "",
        onboardingCompleted = json['onboardingCompleted'] ?? false,
        gender = json['gender'] ?? -1,
        pictureData = json['pictureData'] ?? "";

  ChatUser.asUnknown(this.id)
      : created = Timestamp.now(),
        name = "",
        onboardingCompleted = false,
        gender = -1,
        pictureData = "";

  ChatUser copyWith(
      {String? name,
      int? gender,
      String? pictureData,
      bool? onboardingCompleted,
      Timestamp? created}) {
    return ChatUser(
        id,
        name ?? this.name,
        gender ?? this.gender,
        pictureData ?? this.pictureData,
        onboardingCompleted ?? this.onboardingCompleted,
        created ?? this.created);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        gender,
        pictureData,
        onboardingCompleted,
        created,
      ];
}
