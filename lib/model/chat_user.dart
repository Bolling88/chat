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
  final String city;
  final String countryCode;
  final String country;
  final String regionName;

  const ChatUser({
    required this.id,
    required this.displayName,
    required this.gender,
    required this.pictureData,
    required this.onboardingCompleted,
    required this.created,
    required this.city,
    required this.countryCode,
    required this.country,
    required this.regionName,
  });

  ChatUser.fromJson(this.id, Map<String, dynamic> json)
      : created = json['created'] ?? Timestamp.now(),
        displayName = json['displayName'] ?? "",
        onboardingCompleted = json['onboardingCompleted'] ?? false,
        gender = json['gender'] ?? -1,
        pictureData = json['pictureData'] ?? "",
        city = json['city'] ?? "",
        countryCode = json['countryCode'] ?? "",
        country = json['country'] ?? "",
        regionName = json['regionName'] ?? "";

  ChatUser.asUnknown(this.id)
      : created = Timestamp.now(),
        displayName = "",
        onboardingCompleted = false,
        gender = -1,
        pictureData = "",
        city = "",
        countryCode = "",
        country = "",
        regionName = "";

  ChatUser copyWith(
      {String? name,
      String? displayName,
      int? gender,
      String? pictureData,
      bool? onboardingCompleted,
      Timestamp? created,
      String? city,
      String? countryCode,
      String? country,
      String? regionName}) {
    return ChatUser(
        id: id,
        displayName: displayName ?? this.displayName,
        gender: gender ?? this.gender,
        pictureData: pictureData ?? this.pictureData,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        created: created ?? this.created,
        city: city ?? this.city,
        countryCode: countryCode ?? this.countryCode,
        country: country ?? this.country,
        regionName: regionName ?? this.regionName);
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        gender,
        pictureData,
        onboardingCompleted,
        created,
        city,
        countryCode,
        country,
        regionName,
      ];
}
