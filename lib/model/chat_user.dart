import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'dart:core';

class ChatUser extends Equatable {
  final String id;
  final String displayName;
  final int gender;
  final String pictureData;
  final bool onboardingCompleted;
  final Timestamp created;

  const ChatUser(this.id, this.displayName, this.gender,
      this.pictureData, this.onboardingCompleted, this.created);

  ChatUser.fromJson(this.id, Map<String, dynamic> json)
      : created = json['created'] ?? Timestamp.now(),
        displayName = json['displayName'] ?? "",
        onboardingCompleted = json['onboardingCompleted'] ?? false,
        gender = json['gender'] ?? -1,
        pictureData = json['pictureData'] ?? "";

  ChatUser.asUnknown(this.id)
      : created = Timestamp.now(),
        displayName = "",
        onboardingCompleted = false,
        gender = -1,
        pictureData = "";

  ChatUser copyWith(
      {String? name,
      String? displayName,
      int? gender,
      String? pictureData,
      bool? onboardingCompleted,
      Timestamp? created}) {
    return ChatUser(
        id,
        displayName ?? this.displayName,
        gender ?? this.gender,
        pictureData ?? this.pictureData,
        onboardingCompleted ?? this.onboardingCompleted,
        created ?? this.created);
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        gender,
        pictureData,
        onboardingCompleted,
        created,
      ];
}
