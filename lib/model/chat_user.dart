import 'package:chat/repository/firestore_repository.dart';
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
  final bool presence;
  final String currentRoomChatId;
  final List<String> blockedBy;

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
    required this.blockedBy,
    required this.presence,
    required this.currentRoomChatId,
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
        regionName = json['regionName'] ?? "",
        presence = json['presence'] ?? false,
        currentRoomChatId = json['currentRoomChatId'] ?? '',
        blockedBy = json['blockedBy']?.cast<String>() ?? [];

  ChatUser.asUnknown(this.id)
      : created = Timestamp.now(),
        displayName = "",
        onboardingCompleted = false,
        gender = -1,
        pictureData = "",
        city = "",
        countryCode = "",
        country = "",
        presence = false,
        currentRoomChatId = '',
        regionName = "",
        blockedBy = [];

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
      String? regionName,
      bool? presence,
      String? currentRoomChatId,
      List<String>? blockedBy}) {
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
        presence: presence ?? this.presence,
        currentRoomChatId: currentRoomChatId ?? this.currentRoomChatId,
        regionName: regionName ?? this.regionName,
        blockedBy: blockedBy ?? this.blockedBy);
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
        presence,
        currentRoomChatId,
        regionName,
        blockedBy,
      ];

  bool isUserBlocked() {
    return blockedBy.contains(getUserId());
  }
}
