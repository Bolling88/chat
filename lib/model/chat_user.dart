import 'package:chat/utils/auth_util.dart';
import 'package:chat/utils/enums.dart';
import 'package:equatable/equatable.dart';
import 'dart:core';

DateTime parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is String) return DateTime.parse(value);
  return DateTime.now();
}

int parseLastActive(dynamic value) {
  if (value == null) return DateTime.now().millisecondsSinceEpoch;
  if (value is int) return value;
  if (value is String) return DateTime.parse(value).millisecondsSinceEpoch;
  return DateTime.now().millisecondsSinceEpoch;
}

DateTime? parseDateTimeNullable(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.parse(value);
  return null;
}

class ChatUser extends Equatable {
  final String id;
  final String displayName;
  final int gender;
  final String pictureData;
  final int approvedImage;
  final bool onboardingCompleted;
  final bool isAdmin;
  final DateTime created;
  final int lastActive;
  final String city;
  final String countryCode;
  final String country;
  final String regionName;
  final bool presence;
  final bool showAge;
  final String currentRoomChatId;
  final String fcmToken;
  final DateTime? birthDate;
  final List<String> blockedBy;
  final List<String> imageReports;
  final List<String> botReports;
  final List<String> languageReports;
  final num kvitterCredits;
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
      : created = parseDateTime(json['created']),
        lastActive = parseLastActive(json['last_active']),
        displayName = json['display_name'] ?? "",
        onboardingCompleted = json['onboarding_completed'] ?? false,
        isAdmin = json['is_admin'] ?? false,
        gender = json['gender'] ?? -1,
        pictureData = json['picture_data'] ?? "",
        approvedImage = json['approved_image'] ?? ApprovedImage.notSet.value,
        city = json['city'] ?? "",
        countryCode = json['country_code'] ?? "",
        country = json['country'] ?? "",
        regionName = json['region_name'] ?? "",
        presence = json['presence'] ?? false,
        showAge = json['show_age'] ?? true,
        currentRoomChatId = json['current_room_chat_id'] ?? '',
        fcmToken = json['fcm_token'] ?? '',
        birthDate = parseDateTimeNullable(json['birth_date']),
        blockedBy = json['blocked_by']?.cast<String>() ?? [],
        imageReports = json['image_reports']?.cast<String>() ?? [],
        botReports = json['bot_reports']?.cast<String>() ?? [],
        languageReports = json['language_reports']?.cast<String>() ?? [],
        kvitterCredits = json['kvitter_credits'] ?? 0,
        isPremiumUser = json['is_premium_user'] ?? false;

  ChatUser.asUnknown(this.id)
      : created = DateTime.now(),
        lastActive = DateTime.now().millisecondsSinceEpoch,
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
      DateTime? created,
      int? lastActive,
      String? city,
      String? countryCode,
      String? country,
      String? regionName,
      bool? presence,
      bool? showAge,
      String? currentRoomChatId,
      String? fcmToken,
      DateTime? birthDate,
      List<String>? blockedBy,
      List<String>? imageReports,
      List<String>? botReports,
      List<String>? languageReports,
      num? kvitterCredits,
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
        id, displayName, gender, pictureData, approvedImage,
        onboardingCompleted, isAdmin, created, lastActive,
        city, countryCode, country, presence, showAge,
        currentRoomChatId, regionName, fcmToken, birthDate,
        blockedBy, imageReports, botReports, languageReports,
        kvitterCredits, isPremiumUser
      ];

  bool isUserBlocked() {
    return blockedBy.contains(getUserId());
  }
}
