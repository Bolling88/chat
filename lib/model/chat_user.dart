import 'package:chat/repository/firestore_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'dart:core';

class ChatUser extends Equatable {
  final String id;
  final String displayName;
  final int gender;
  final String pictureData;
  final int approvedImage;
  final bool onboardingCompleted;
  final bool isAdmin;
  final Timestamp created;
  final int lastActive;
  final String city;
  final String countryCode;
  final String country;
  final String regionName;
  final bool presence;
  final bool showAge;
  final String currentRoomChatId;
  final String fcmToken;
  final Timestamp? birthDate;
  final List<String> blockedBy;
  final List<String> imageReports;
  final List<String> botReports;
  final List<String> languageReports;
  final int kvitterCredits;
  final bool isPremiumUser;

  const ChatUser(
      {required this.id,
      required this.displayName,
      required this.gender,
      required this.pictureData,
      required this.approvedImage,
      required this.onboardingCompleted,
      required this.isAdmin,
      required this.created,
      required this.lastActive,
      required this.city,
      required this.countryCode,
      required this.country,
      required this.regionName,
      required this.blockedBy,
      required this.presence,
      required this.showAge,
      required this.fcmToken,
      required this.birthDate,
      required this.currentRoomChatId,
      required this.imageReports,
      required this.botReports,
      required this.languageReports,
      required this.kvitterCredits,
      required this.isPremiumUser});

  ChatUser.fromJson(this.id, Map<String, dynamic> json)
      : created = json['created'] ?? Timestamp.now(),
        lastActive =
            json['lastActive'] ?? Timestamp.now().millisecondsSinceEpoch,
        displayName = json['displayName'] ?? "",
        onboardingCompleted = json['onboardingCompleted'] ?? false,
        isAdmin = json['isAdmin'] ?? false,
        gender = json['gender'] ?? -1,
        pictureData = json['pictureData'] ?? "",
        approvedImage = json['approvedImage'] ?? ApprovedImage.notSet.value,
        city = json['city'] ?? "",
        countryCode = json['countryCode'] ?? "",
        country = json['country'] ?? "",
        regionName = json['regionName'] ?? "",
        presence = json['presence'] ?? false,
        showAge = json['showAge'] ?? true,
        currentRoomChatId = json['currentRoomChatId'] ?? '',
        fcmToken = json['fcmToken'] ?? '',
        birthDate = json['birthDate'],
        blockedBy = json['blockedBy']?.cast<String>() ?? [],
        imageReports = json['imageReports']?.cast<String>() ?? [],
        botReports = json['botReports']?.cast<String>() ?? [],
        languageReports = json['languageReports']?.cast<String>() ?? [],
        kvitterCredits = json['kvitterCredits'] ?? 0,
        isPremiumUser = json['isPremiumUser'] ?? false;

  ChatUser.asUnknown(this.id)
      : created = Timestamp.now(),
        lastActive = Timestamp.now().millisecondsSinceEpoch,
        displayName = "",
        onboardingCompleted = false,
        isAdmin = false,
        gender = -1,
        pictureData = "",
        approvedImage = 0,
        city = "",
        countryCode = "",
        country = "",
        presence = false,
        showAge = true,
        currentRoomChatId = '',
        regionName = "",
        fcmToken = "",
        birthDate = null,
        blockedBy = [],
        imageReports = [],
        botReports = [],
        languageReports = [],
        kvitterCredits = 0,
        isPremiumUser = false;

  ChatUser copyWith(
      {String? name,
      String? displayName,
      int? gender,
      String? pictureData,
      int? approvedImage,
      bool? onboardingCompleted,
      bool? isAdmin,
      Timestamp? created,
      int? lastActive,
      String? city,
      String? countryCode,
      String? country,
      String? regionName,
      bool? presence,
      bool? showAge,
      String? currentRoomChatId,
      String? fcmToken,
      Timestamp? birthDate,
      List<String>? blockedBy,
      List<String>? imageReports,
      List<String>? botReports,
      List<String>? languageReports,
      int? kvitterCredits,
      bool? isPremiumUser}) {
    return ChatUser(
        id: id,
        displayName: displayName ?? this.displayName,
        gender: gender ?? this.gender,
        pictureData: pictureData ?? this.pictureData,
        approvedImage: approvedImage ?? this.approvedImage,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        isAdmin: isAdmin ?? this.isAdmin,
        created: created ?? this.created,
        lastActive: lastActive ?? this.lastActive,
        city: city ?? this.city,
        countryCode: countryCode ?? this.countryCode,
        country: country ?? this.country,
        presence: presence ?? this.presence,
        showAge: showAge ?? this.showAge,
        currentRoomChatId: currentRoomChatId ?? this.currentRoomChatId,
        regionName: regionName ?? this.regionName,
        fcmToken: fcmToken ?? this.fcmToken,
        birthDate: birthDate ?? this.birthDate,
        blockedBy: blockedBy ?? this.blockedBy,
        imageReports: imageReports ?? this.imageReports,
        botReports: botReports ?? this.botReports,
        languageReports: languageReports ?? this.languageReports,
        kvitterCredits: kvitterCredits ?? this.kvitterCredits,
        isPremiumUser: isPremiumUser ?? this.isPremiumUser);
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        gender,
        pictureData,
        approvedImage,
        onboardingCompleted,
        isAdmin,
        created,
        lastActive,
        city,
        countryCode,
        country,
        presence,
        showAge,
        currentRoomChatId,
        regionName,
        fcmToken,
        birthDate,
        blockedBy,
        imageReports,
        botReports,
        languageReports,
        kvitterCredits,
        isPremiumUser
      ];

  bool isUserBlocked() {
    return blockedBy.contains(getUserId());
  }
}
