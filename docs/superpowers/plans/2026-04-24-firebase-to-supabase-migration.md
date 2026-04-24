# Firebase to Supabase Migration — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Firebase/Firestore backend with self-hosted Supabase, keeping FCM and Crashlytics.

**Architecture:** Repository-swap approach — create new Supabase repository implementations matching existing interfaces. Models updated from Firestore Timestamp to DateTime with snake_case JSON keys. BLoCs receive typed streams instead of QuerySnapshot.

**Tech Stack:** Flutter, Supabase (self-hosted via Docker), PostgreSQL, supabase_flutter SDK, Firebase (FCM + Crashlytics only)

---

### Task 1: Extract enums and auth utility from FirestoreRepository

**Files:**
- Create: `lib/utils/enums.dart`
- Create: `lib/utils/auth_util.dart`

- [ ] **Step 1: Create `lib/utils/enums.dart`**

```dart
enum Gender {
  female(0),
  male(1),
  nonBinary(2),
  secret(3);

  const Gender(this.value);

  static Gender fromValue(num i) {
    if (i < 0 || i > 3) {
      i = 3;
    }
    return Gender.values.firstWhere((x) => x.value == i);
  }

  static List<Gender> getAsList() {
    return Gender.values;
  }

  final int value;
}

const onlineDuration = Duration(hours: 3);

enum ApprovedImage {
  notReviewed(0),
  notApproved(1),
  approved(2),
  notSet(3);

  const ApprovedImage(this.value);

  static ApprovedImage fromValue(num i) {
    if (i < 0 || i > 3) {
      i = 0;
    }
    return ApprovedImage.values.firstWhere((x) => x.value == i);
  }

  static List<ApprovedImage> getAsList() {
    return ApprovedImage.values;
  }

  final int value;
}

enum ChatType {
  message(0),
  joined(1),
  left(2),
  giphy(3),
  date(4),
  image(5);

  const ChatType(this.value);

  final num value;
}
```

- [ ] **Step 2: Create `lib/utils/auth_util.dart`**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

String getUserId() => Supabase.instance.client.auth.currentUser!.id;
```

- [ ] **Step 3: Verify**

Run: `cd /Users/lbofhn/Documents/Kvitter/chat && flutter analyze lib/utils/enums.dart`

- [ ] **Step 4: Commit**

```bash
git add lib/utils/enums.dart lib/utils/auth_util.dart
git commit -m "refactor: extract enums and auth utility for Supabase migration"
```

---

### Task 2: Update models from Timestamp to DateTime

**Files:**
- Modify: `lib/model/chat.dart`
- Modify: `lib/model/chat_user.dart`
- Modify: `lib/model/message.dart`
- Modify: `lib/model/room_chat.dart`
- Modify: `lib/model/private_chat.dart`

- [ ] **Step 1: Update `lib/model/chat.dart`**

Replace the entire file:

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class Chat extends Equatable {
  final String id;
  final String lastMessage;
  final bool lastMessageIsGiphy;
  final String lastMessageByName;
  final DateTime lastMessageTimestamp;
  final String lastMessageUserId;

  const Chat({
    required this.id,
    required this.lastMessage,
    required this.lastMessageIsGiphy,
    required this.lastMessageByName,
    required this.lastMessageTimestamp,
    required this.lastMessageUserId,
  });

  String getChatName(String userId);

  Color getChatColor(String userId, BuildContext context);

  String? getChatImage(String userId);

  String getOtherUserId(String userId);

  bool isPrivateChat();

  Chat copyWith({
    String? id,
    String? lastMessage,
    bool? lastMessageIsGiphy,
    String? lastMessageByName,
    DateTime? lastMessageTimestamp,
    String? lastMessageUserId,
  });
}
```

- [ ] **Step 2: Update `lib/model/chat_user.dart`**

Replace the entire file:

```dart
import 'package:chat/utils/auth_util.dart';
import 'package:chat/utils/enums.dart';
import 'package:equatable/equatable.dart';
import 'dart:core';

// Public so other model files (message.dart, room_chat.dart, private_chat.dart) can import and use them
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
```

- [ ] **Step 3: Update `lib/model/message.dart`**

Replace the entire file:

```dart
import 'package:chat/model/chat_user.dart';
import 'package:chat/utils/enums.dart';
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
  final DateTime created;
  final DateTime? birthDate;
  final bool showAge;
  final String? translation;
  final bool marked;
  final List<String> imageReports;
  final String replyId;
  final String replyText;
  final String replyCreatedById;
  final String replyCreatedByName;
  final int replyCreatedByGender;
  final String replyCreatedByCountryCode;
  final String replyCreatedByImageUrl;
  final ChatType replyChatType;
  final int replyApprovedImage;
  final DateTime? replyCreated;
  final DateTime? replyBirthDate;
  final bool replyShowAge;
  final List<String> replyImageReports;

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
    this.replyId = "",
    this.replyText = "",
    this.replyCreatedById = "",
    this.replyCreatedByName = "",
    this.replyCreatedByGender = 0,
    this.replyCreatedByCountryCode = "",
    this.replyCreatedByImageUrl = "",
    this.replyChatType = ChatType.message,
    this.replyApprovedImage = 0,
    this.replyCreated,
    this.replyBirthDate,
    this.replyShowAge = false,
    this.replyImageReports = const [],
  });

  Message.fromJson(this.id, Map<String, dynamic> json)
      : created = parseDateTime(json['created']),
        createdById = json['created_by_id'] ?? "",
        createdByName = json['created_by_name'] ?? "",
        createdByGender = json['created_by_gender'] ?? 0,
        createdByCountryCode = json['created_by_country_code'] ?? '',
        chatType = ChatType.values[json['chat_type'] ?? 0],
        createdByImageUrl = json['created_by_image_url'] ?? "",
        approvedImage = json['approved_image'] ?? ApprovedImage.notSet.value,
        text = json['text'] ?? "",
        birthDate = parseDateTimeNullable(json['birth_date']),
        showAge = json['show_age'] ?? true,
        translation = null,
        marked = false,
        imageReports = json['image_reports']?.cast<String>() ?? [],
        replyId = json['reply_id'] ?? "",
        replyText = json['reply_text'] ?? "",
        replyCreatedById = json['reply_created_by_id'] ?? "",
        replyCreatedByName = json['reply_created_by_name'] ?? "",
        replyCreatedByGender = json['reply_created_by_gender'] ?? 0,
        replyCreatedByCountryCode = json['reply_created_by_country_code'] ?? '',
        replyCreatedByImageUrl = json['reply_created_by_image_url'] ?? "",
        replyChatType = ChatType.values[json['reply_chat_type'] ?? 0],
        replyApprovedImage =
            json['reply_approved_image'] ?? ApprovedImage.notSet.value,
        replyCreated = parseDateTimeNullable(json['reply_created']),
        replyBirthDate = parseDateTimeNullable(json['reply_birth_date']),
        replyShowAge = json['reply_show_age'] ?? true,
        replyImageReports = json['reply_image_reports']?.cast<String>() ?? [];

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
    DateTime? created,
    DateTime? birthDate,
    bool? showAge,
    String? translation,
    bool? marked,
    List<String>? imageReports,
    String? replyId,
    String? replyText,
    String? replyCreatedById,
    String? replyCreatedByName,
    int? replyCreatedByGender,
    String? replyCreatedByCountryCode,
    String? replyCreatedByImageUrl,
    ChatType? replyChatType,
    int? replyApprovedImage,
    DateTime? replyCreated,
    DateTime? replyBirthDate,
    bool? replyShowAge,
    List<String>? replyImageReports,
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
      replyId: replyId ?? this.replyId,
      replyText: replyText ?? this.replyText,
      replyCreatedById: replyCreatedById ?? this.replyCreatedById,
      replyCreatedByName: replyCreatedByName ?? this.replyCreatedByName,
      replyCreatedByGender: replyCreatedByGender ?? this.replyCreatedByGender,
      replyCreatedByCountryCode:
          replyCreatedByCountryCode ?? this.replyCreatedByCountryCode,
      replyCreatedByImageUrl:
          replyCreatedByImageUrl ?? this.replyCreatedByImageUrl,
      replyChatType: replyChatType ?? this.replyChatType,
      replyApprovedImage: replyApprovedImage ?? this.replyApprovedImage,
      replyCreated: replyCreated ?? this.replyCreated,
      replyBirthDate: replyBirthDate ?? this.replyBirthDate,
      replyShowAge: replyShowAge ?? this.replyShowAge,
      replyImageReports: replyImageReports ?? this.replyImageReports,
    );
  }

  @override
  List<Object?> get props => [
        id, text, chatType, createdById, createdByName,
        createdByGender, createdByCountryCode, createdByImageUrl,
        approvedImage, created, birthDate, showAge, translation,
        marked, imageReports, replyId, replyText,
        replyCreatedById, replyCreatedByName, replyCreatedByGender,
        replyCreatedByCountryCode, replyCreatedByImageUrl,
        replyChatType, replyApprovedImage, replyCreated,
        replyBirthDate, replyShowAge, replyImageReports
      ];

  @override
  int compareTo(Message other) {
    return created.compareTo(other.created);
  }
}
```

- [ ] **Step 4: Update `lib/model/room_chat.dart`**

Replace the entire file:

```dart
import 'package:chat/model/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../utils/time_util.dart';
import 'chat.dart';

class RoomChat extends Chat implements Comparable<RoomChat> {
  final String countryCode;
  final String chatName;
  final int chatColor;
  final String imageUrl;
  final int imageOverflow;
  final int imageTranslationX;
  final bool lastMessageReadByUser;
  final bool enabled;
  final String infoKey;

  const RoomChat({
    required this.countryCode,
    required this.chatName,
    required this.chatColor,
    required this.imageUrl,
    required this.imageOverflow,
    required this.imageTranslationX,
    required this.lastMessageReadByUser,
    required this.enabled,
    required this.infoKey,
    required super.id,
    required super.lastMessage,
    required super.lastMessageIsGiphy,
    required super.lastMessageByName,
    required super.lastMessageTimestamp,
    required super.lastMessageUserId,
  });

  RoomChat.fromJson(String id, Map<String, dynamic> json)
      : countryCode = json['country_code'] ?? 'en',
        chatName = json['chat_name'] ?? "",
        chatColor = json['chat_color'] ?? 0xFF30c7c2,
        imageUrl = json['image_url'] ?? "",
        imageOverflow = json['image_overflow'] ?? 80,
        imageTranslationX = json['image_translation_x'] ?? 0,
        infoKey = json['info_key'] ?? '',
        lastMessageReadByUser = false,
        enabled = json['enabled'] ?? true,
        super(
          id: id,
          lastMessage: json['last_message'] ?? "",
          lastMessageIsGiphy: json['last_message_is_giphy'] ?? false,
          lastMessageByName: json['last_message_by_name'] ?? "",
          lastMessageTimestamp: parseDateTime(json['last_message_timestamp']),
          lastMessageUserId: json['last_message_user_id'] ?? "",
        );

  String getLastMessageReadableDate() {
    return getLastMessageTimeFromDateTime(lastMessageTimestamp);
  }

  @override
  int compareTo(RoomChat other) {
    return lastMessageTimestamp.compareTo(other.lastMessageTimestamp);
  }

  @override
  RoomChat copyWith({
    String? countryCode,
    String? chatName,
    int? chatColor,
    String? imageUrl,
    int? imageOverflow,
    int? imageTranslationX,
    String? id,
    List<String>? users,
    String? lastMessage,
    bool? lastMessageIsGiphy,
    String? lastMessageByName,
    DateTime? lastMessageTimestamp,
    String? lastMessageUserId,
    bool? lastMessageReadByUser,
    bool? enabled,
    String? infoKey,
  }) {
    return RoomChat(
      countryCode: countryCode ?? this.countryCode,
      chatName: chatName ?? this.chatName,
      chatColor: chatColor ?? this.chatColor,
      imageUrl: imageUrl ?? this.imageUrl,
      imageOverflow: imageOverflow ?? this.imageOverflow,
      imageTranslationX: imageTranslationX ?? this.imageTranslationX,
      id: id ?? this.id,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageIsGiphy: lastMessageIsGiphy ?? this.lastMessageIsGiphy,
      lastMessageByName: lastMessageByName ?? this.lastMessageByName,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastMessageUserId: lastMessageUserId ?? this.lastMessageUserId,
      infoKey: infoKey ?? this.infoKey,
      lastMessageReadByUser:
          lastMessageReadByUser ?? this.lastMessageReadByUser,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List<Object> get props => [
        id, countryCode, lastMessage, lastMessageIsGiphy,
        lastMessageByName, lastMessageTimestamp, lastMessageUserId,
        lastMessageReadByUser, enabled, chatName, chatColor,
        imageUrl, imageOverflow, imageTranslationX, infoKey
      ];

  @override
  String getChatName(String userId) => chatName;

  @override
  Color getChatColor(String userId, BuildContext context) => Color(chatColor);

  @override
  String? getChatImage(String userId) => null;

  @override
  String getOtherUserId(String userId) => '';

  @override
  bool isPrivateChat() => false;

  String getInfoText(BuildContext context) {
    if (infoKey.isEmpty) {
      return FlutterI18n.translate(context, 'info_country');
    }
    return FlutterI18n.translate(context, infoKey);
  }
}
```

- [ ] **Step 5: Update `lib/model/private_chat.dart`**

Replace the entire file:

```dart
import 'package:chat/model/chat_user.dart';
import 'package:flutter/material.dart';
import '../utils/auth_util.dart';
import '../utils/gender.dart';
import '../utils/time_util.dart';
import 'chat.dart';

class PrivateChat extends Chat implements Comparable<PrivateChat> {
  final String initiatedBy;
  final String initiatedByUserName;
  final int initiatedByUserGender;
  final String initiatedByPictureData;
  final String otherUserId;
  final String otherUserName;
  final int otherUserGender;
  final String otherUserPictureData;
  final DateTime created;
  final List<String> lastMessageReadBy;
  final List<String> users;
  final List<ChatUser> userInfos = [];
  final String usersText = "";

  PrivateChat({
    required this.initiatedBy,
    required this.initiatedByUserName,
    required this.initiatedByUserGender,
    required this.initiatedByPictureData,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserGender,
    required this.otherUserPictureData,
    required this.created,
    required this.lastMessageReadBy,
    required this.users,
    required super.id,
    required super.lastMessage,
    required super.lastMessageIsGiphy,
    required super.lastMessageByName,
    required super.lastMessageTimestamp,
    required super.lastMessageUserId,
  });

  @override
  PrivateChat copyWith({
    String? initiatedBy,
    String? initiatedByUserName,
    int? initiatedByUserGender,
    String? initiatedByPictureData,
    String? otherUserId,
    String? otherUserName,
    int? otherUserGender,
    String? otherUserPictureData,
    DateTime? created,
    List<String>? lastMessageReadBy,
    String? id,
    List<String>? users,
    String? lastMessage,
    bool? lastMessageIsGiphy,
    String? lastMessageByName,
    DateTime? lastMessageTimestamp,
    String? lastMessageUserId,
  }) {
    return PrivateChat(
      initiatedBy: initiatedBy ?? this.initiatedBy,
      initiatedByUserName: initiatedByUserName ?? this.initiatedByUserName,
      initiatedByUserGender: initiatedByUserGender ?? this.initiatedByUserGender,
      initiatedByPictureData: initiatedByPictureData ?? this.initiatedByPictureData,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserGender: otherUserGender ?? this.otherUserGender,
      otherUserPictureData: otherUserPictureData ?? this.otherUserPictureData,
      created: created ?? this.created,
      lastMessageReadBy: lastMessageReadBy ?? this.lastMessageReadBy,
      id: id ?? this.id,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageIsGiphy: lastMessageIsGiphy ?? this.lastMessageIsGiphy,
      lastMessageByName: lastMessageByName ?? this.lastMessageByName,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastMessageUserId: lastMessageUserId ?? this.lastMessageUserId,
    );
  }

  PrivateChat.fromJson(String id, Map<String, dynamic> json)
      : initiatedBy = json['initiated_by'] ?? '',
        initiatedByUserName = json['initiated_by_user_name'] ?? '',
        initiatedByUserGender = json['initiated_by_user_gender'] ?? 0,
        initiatedByPictureData = json['initiated_by_picture_data'] ?? '',
        otherUserId = json['other_user_id'] ?? '',
        users = json['users']?.cast<String>() ?? [],
        otherUserName = json['other_user_name'] ?? '',
        otherUserGender = json['other_user_gender'] ?? 0,
        otherUserPictureData = json['other_user_picture_data'] ?? '',
        created = parseDateTime(json['created']),
        lastMessageReadBy = json['last_message_read_by']?.cast<String>() ?? [],
        super(
          id: id,
          lastMessage: json['last_message'] ?? "",
          lastMessageIsGiphy: json['last_message_is_giphy'] ?? false,
          lastMessageByName: json['last_message_by_name'] ?? "",
          lastMessageTimestamp: parseDateTime(json['last_message_timestamp']),
          lastMessageUserId: json['last_message_user_id'] ?? "",
        );

  String getLastMessageReadableDate() {
    return getLastMessageTimeFromDateTime(lastMessageTimestamp);
  }

  @override
  int compareTo(PrivateChat other) {
    return lastMessageTimestamp.compareTo(other.lastMessageTimestamp);
  }

  @override
  List<Object> get props => [
        id, lastMessage, lastMessageIsGiphy, lastMessageByName,
        lastMessageTimestamp, lastMessageUserId, users, userInfos,
        usersText, initiatedBy, initiatedByUserName,
        initiatedByUserGender, initiatedByPictureData,
        otherUserId, otherUserName, otherUserGender,
        otherUserPictureData, created, lastMessageReadBy,
      ];

  @override
  String getChatName(String userId) {
    return userId == initiatedBy ? otherUserName : initiatedByUserName;
  }

  @override
  Color getChatColor(String userId, BuildContext context) {
    return userId == initiatedBy
        ? getGenderColor(context, Gender.fromValue(otherUserGender))
        : getGenderColor(context, Gender.fromValue(initiatedByUserGender));
  }

  @override
  String? getChatImage(String userId) {
    return userId == initiatedBy ? otherUserPictureData : initiatedByPictureData;
  }

  @override
  String getOtherUserId(String userId) {
    return userId == initiatedBy ? otherUserId : initiatedBy;
  }

  @override
  bool isPrivateChat() => true;

  int getOtherUserGender(String userId) {
    return userId == initiatedBy ? initiatedByUserGender : otherUserGender;
  }
}
```

- [ ] **Step 6: Verify models compile**

Run: `cd /Users/lbofhn/Documents/Kvitter/chat && flutter analyze lib/model/`

Note: This will show errors in files that still import `cloud_firestore` or `firestore_repository` — those will be fixed in later tasks.

- [ ] **Step 7: Commit**

```bash
git add lib/model/
git commit -m "refactor: migrate models from Timestamp to DateTime with snake_case keys"
```

---

### Task 3: Update time_util.dart

**Files:**
- Modify: `lib/utils/time_util.dart`

- [ ] **Step 1: Replace `lib/utils/time_util.dart`**

```dart
import 'package:intl/intl.dart';

String getLastMessageTimeFromDateTime(DateTime dateTime) {
  final DateFormat dateFormat = DateFormat('dd MMM');
  final DateFormat hourFormat = DateFormat('HH:mm');
  final localDate = dateTime.toLocal();
  final now = DateTime.now();
  final difference = now.difference(localDate);
  if (difference.inSeconds < secondsInDay) {
    return hourFormat.format(localDate);
  } else {
    return dateFormat.format(localDate);
  }
}

String getTimeSince(DateTime dateTime) {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat hourFormat = DateFormat('HH:mm');
  final localDate = dateTime.toLocal();
  final now = DateTime.now();
  final difference = now.difference(localDate);
  if (difference.inSeconds < secondsInDay) {
    return hourFormat.format(localDate);
  } else {
    return dateFormat.format(localDate);
  }
}

Duration getDurationFromNow(DateTime dateTime) {
  final localDate = dateTime.toLocal();
  final now = DateTime.now();
  return now.difference(localDate);
}

String getFormattedDate(DateTime dateTime) {
  final DateFormat dateFormat = DateFormat('d MMM yyyy');
  final localDate = dateTime.toLocal();
  return dateFormat.format(localDate);
}

String getFormattedTime(DateTime dateTime) {
  final DateFormat dateFormat = DateFormat('HH:mm');
  final localDate = dateTime.toLocal();
  return dateFormat.format(localDate);
}

String getMessageDate(DateTime dateTime) {
  final DateFormat dateFormat = DateFormat('EEEE dd MMM HH:mm');
  final DateFormat hourFormat = DateFormat('HH:mm');
  final localDate = dateTime.toLocal();
  final now = DateTime.now();
  final difference = now.difference(localDate);
  if (difference.inSeconds < secondsInDay) {
    return hourFormat.format(localDate);
  } else {
    return dateFormat.format(localDate);
  }
}

const secondsInDay = 86400;
const secondsInHour = 3600;
```

- [ ] **Step 2: Commit**

```bash
git add lib/utils/time_util.dart
git commit -m "refactor: migrate time_util from Timestamp to DateTime"
```

---

### Task 4: Update dependencies and create Supabase config

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/supabase_config.dart`

- [ ] **Step 1: Update `pubspec.yaml`**

Remove these dependencies:
```yaml
cloud_firestore:
firebase_auth:
firebase_storage:
firebase_database:
firebase_app_check:
firebase_performance:
firebase_analytics:
cloud_functions:
google_sign_in:
sign_in_with_apple:
```

Add:
```yaml
supabase_flutter: ^2.8.0
```

Keep:
```yaml
firebase_core:
firebase_crashlytics:
firebase_messaging:
```

- [ ] **Step 2: Create `lib/supabase_config.dart`**

```dart
class SupabaseConfig {
  static const String url = 'https://YOUR_MAC_MINI_DOMAIN';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

Replace `YOUR_MAC_MINI_DOMAIN` and `YOUR_SUPABASE_ANON_KEY` with values from your self-hosted Supabase `.env` file after Docker setup.

- [ ] **Step 3: Run pub get**

Run: `cd /Users/lbofhn/Documents/Kvitter/chat && flutter pub get`

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/supabase_config.dart
git commit -m "feat: add supabase_flutter dependency and config"
```

---

### Task 5: Create SQL schema for Supabase

**Files:**
- Create: `supabase/schema.sql`

- [ ] **Step 1: Create `supabase/schema.sql`**

This file is run on the Mac Mini's Supabase PostgreSQL instance.

```sql
-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLES
-- ============================================

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  firebase_uid TEXT,
  email TEXT,
  display_name TEXT DEFAULT '',
  gender INT DEFAULT -1,
  birth_date TIMESTAMPTZ,
  show_age BOOLEAN DEFAULT TRUE,
  picture_data TEXT DEFAULT '',
  approved_image INT DEFAULT 3,
  city TEXT DEFAULT '',
  country_code TEXT DEFAULT '',
  country TEXT DEFAULT '',
  region_name TEXT DEFAULT '',
  presence BOOLEAN DEFAULT FALSE,
  last_active TIMESTAMPTZ DEFAULT now(),
  current_room_chat_id UUID,
  fcm_token TEXT DEFAULT '',
  blocked_by TEXT[] DEFAULT '{}',
  image_reports TEXT[] DEFAULT '{}',
  bot_reports TEXT[] DEFAULT '{}',
  language_reports TEXT[] DEFAULT '{}',
  kvitter_credits INT DEFAULT 0,
  is_premium_user BOOLEAN DEFAULT FALSE,
  onboarding_completed BOOLEAN DEFAULT FALSE,
  is_admin BOOLEAN DEFAULT FALSE,
  search_array TEXT[] DEFAULT '{}',
  created TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_name TEXT DEFAULT '',
  chat_color INT DEFAULT 3253186,
  image_url TEXT DEFAULT '',
  country_code TEXT DEFAULT 'all',
  enabled BOOLEAN DEFAULT TRUE,
  info_key TEXT DEFAULT '',
  image_overflow INT DEFAULT 80,
  image_translation_x INT DEFAULT 0,
  last_message TEXT DEFAULT '',
  last_message_is_giphy BOOLEAN DEFAULT FALSE,
  last_message_by_name TEXT DEFAULT '',
  last_message_timestamp TIMESTAMPTZ DEFAULT now(),
  last_message_user_id UUID
);

CREATE TABLE IF NOT EXISTS private_chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  users TEXT[] DEFAULT '{}',
  created TIMESTAMPTZ DEFAULT now(),
  initiated_by UUID,
  initiated_by_user_name TEXT DEFAULT '',
  initiated_by_user_gender INT DEFAULT 0,
  initiated_by_picture_data TEXT DEFAULT '',
  chat_name TEXT DEFAULT '',
  other_user_id UUID,
  other_user_name TEXT DEFAULT '',
  other_user_gender INT DEFAULT 0,
  other_user_picture_data TEXT DEFAULT '',
  last_message TEXT DEFAULT '',
  last_message_is_giphy BOOLEAN DEFAULT FALSE,
  last_message_by_name TEXT DEFAULT '',
  last_message_timestamp TIMESTAMPTZ DEFAULT now(),
  last_message_user_id UUID,
  last_message_read_by TEXT[] DEFAULT '{}',
  send_push_to_user_id UUID
);

CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_id UUID NOT NULL,
  is_private BOOLEAN DEFAULT FALSE,
  text TEXT DEFAULT '',
  chat_type INT DEFAULT 0,
  created_by_id UUID,
  created_by_name TEXT DEFAULT '',
  created_by_gender INT DEFAULT 0,
  created_by_country_code TEXT DEFAULT '',
  created_by_image_url TEXT DEFAULT '',
  approved_image INT DEFAULT 3,
  created TIMESTAMPTZ DEFAULT now(),
  birth_date TIMESTAMPTZ,
  show_age BOOLEAN DEFAULT TRUE,
  image_reports TEXT[] DEFAULT '{}',
  reply_id UUID,
  reply_text TEXT DEFAULT '',
  reply_chat_type INT DEFAULT 0,
  reply_created_by_id UUID,
  reply_created_by_name TEXT DEFAULT '',
  reply_created_by_gender INT DEFAULT 0,
  reply_created_by_country_code TEXT DEFAULT '',
  reply_created_by_image_url TEXT DEFAULT '',
  reply_approved_image INT DEFAULT 3,
  reply_created TIMESTAMPTZ,
  reply_birth_date TIMESTAMPTZ,
  reply_show_age BOOLEAN DEFAULT TRUE,
  reply_image_reports TEXT[] DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  message_id UUID,
  message_text TEXT,
  message_created TIMESTAMPTZ,
  message_created_by UUID,
  message_created_by_gender INT,
  message_created_by_country_code TEXT,
  message_created_by_image_url TEXT,
  message_created_by_display_name TEXT,
  reported_by UUID,
  reported_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS feedback (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  feedback TEXT,
  created_by_id UUID,
  created_by_name TEXT,
  created_by_country_code TEXT,
  created_by_country_name TEXT,
  created TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX idx_messages_chat_created ON messages (chat_id, created DESC);
CREATE INDEX idx_messages_created_by ON messages (created_by_id);
CREATE INDEX idx_users_last_active ON users (last_active);
CREATE INDEX idx_users_approved_image ON users (approved_image);
CREATE INDEX idx_users_display_name ON users (display_name);
CREATE INDEX idx_private_chats_users ON private_chats USING GIN (users);
CREATE INDEX idx_chats_country_enabled ON chats (country_code, enabled);

-- ============================================
-- RPC FUNCTIONS
-- ============================================

CREATE OR REPLACE FUNCTION increment_credits(target_user_id UUID, amount INT)
RETURNS VOID AS $$
  UPDATE users SET kvitter_credits = kvitter_credits + amount WHERE id = target_user_id;
$$ LANGUAGE SQL SECURITY DEFINER;

-- ============================================
-- TRIGGERS
-- ============================================

-- Auto-delete private chat when users array has fewer than 2 entries
CREATE OR REPLACE FUNCTION delete_empty_private_chat()
RETURNS TRIGGER AS $$
BEGIN
  IF array_length(NEW.users, 1) IS NULL OR array_length(NEW.users, 1) < 2 THEN
    DELETE FROM messages WHERE chat_id = NEW.id;
    DELETE FROM private_chats WHERE id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_delete_empty_private_chat
  AFTER UPDATE ON private_chats
  FOR EACH ROW
  EXECUTE FUNCTION delete_empty_private_chat();

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE private_chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

-- Users: anyone authenticated can read, update own row only
CREATE POLICY "Users are viewable by authenticated users"
  ON users FOR SELECT TO authenticated
  USING (true);

CREATE POLICY "Users can update own record"
  ON users FOR UPDATE TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own record"
  ON users FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = id);

-- Chats: readable by authenticated, writable by admins
CREATE POLICY "Chats are viewable by authenticated users"
  ON chats FOR SELECT TO authenticated
  USING (true);

-- Private chats: only participants
CREATE POLICY "Private chats visible to participants"
  ON private_chats FOR SELECT TO authenticated
  USING (auth.uid()::text = ANY(users));

CREATE POLICY "Private chats insertable by authenticated"
  ON private_chats FOR INSERT TO authenticated
  WITH CHECK (auth.uid()::text = ANY(users));

CREATE POLICY "Private chats updatable by participants"
  ON private_chats FOR UPDATE TO authenticated
  USING (auth.uid()::text = ANY(users));

-- Messages: readable based on chat access, insertable by authenticated
CREATE POLICY "Public messages viewable by authenticated"
  ON messages FOR SELECT TO authenticated
  USING (
    NOT is_private
    OR EXISTS (
      SELECT 1 FROM private_chats
      WHERE private_chats.id = messages.chat_id
      AND auth.uid()::text = ANY(private_chats.users)
    )
  );

CREATE POLICY "Messages insertable by authenticated"
  ON messages FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = created_by_id);

-- Reports: insert by authenticated, read by admins
CREATE POLICY "Reports insertable by authenticated"
  ON reports FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY "Reports viewable by admins"
  ON reports FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.is_admin = true));

-- Feedback: insert by authenticated, read by admins
CREATE POLICY "Feedback insertable by authenticated"
  ON feedback FOR INSERT TO authenticated
  WITH CHECK (true);

CREATE POLICY "Feedback viewable by admins"
  ON feedback FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.is_admin = true));

-- ============================================
-- STORAGE BUCKETS
-- ============================================

INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('avatars', 'avatars', true, 2097152)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES ('chat-images', 'chat-images', true, 2097152)
ON CONFLICT (id) DO NOTHING;

-- Storage policies
CREATE POLICY "Avatar images are publicly accessible"
  ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Users can update own avatar"
  ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Users can delete own avatar"
  ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'avatars' AND (storage.foldername(name))[1] = auth.uid()::text);

CREATE POLICY "Chat images are publicly accessible"
  ON storage.objects FOR SELECT TO public
  USING (bucket_id = 'chat-images');

CREATE POLICY "Authenticated users can upload chat images"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'chat-images');

-- ============================================
-- REALTIME
-- ============================================

ALTER PUBLICATION supabase_realtime ADD TABLE users;
ALTER PUBLICATION supabase_realtime ADD TABLE chats;
ALTER PUBLICATION supabase_realtime ADD TABLE private_chats;
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
```

- [ ] **Step 2: Commit**

```bash
git add supabase/schema.sql
git commit -m "feat: add PostgreSQL schema for Supabase migration"
```

---

### Task 6: Create SupabaseAuthRepository

**Files:**
- Create: `lib/repository/supabase_auth_repository.dart`

- [ ] **Step 1: Create `lib/repository/supabase_auth_repository.dart`**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/log.dart';

class SupabaseAuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final result = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.kvitter://login-callback/',
      );
      if (!result) return null;
      return null;
    } catch (e, s) {
      Log.e(e, stackTrace: s);
      return null;
    }
  }

  Future<AuthResponse?> signInWithApple() async {
    try {
      final result = await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.kvitter://login-callback/',
      );
      if (!result) return null;
      return null;
    } catch (e, s) {
      Log.e(e, stackTrace: s);
      return null;
    }
  }

  Future<AuthResponse?> signInAnonymously() async {
    try {
      return await _client.auth.signInAnonymously();
    } catch (e, s) {
      Log.e(e, stackTrace: s);
      return null;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> deleteAccount() async {
    // Admin API required for account deletion — handled server-side
    // or via Supabase Edge Function
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/repository/supabase_auth_repository.dart
git commit -m "feat: add SupabaseAuthRepository"
```

---

### Task 7: Create SupabaseStorageRepository

**Files:**
- Create: `lib/repository/supabase_storage_repository.dart`

- [ ] **Step 1: Create `lib/repository/supabase_storage_repository.dart`**

```dart
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_io/io.dart';

import '../utils/auth_util.dart';
import '../utils/log.dart';

class SupabaseStorageRepository {
  final SupabaseClient _client = Supabase.instance.client;

  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String _getRandomString(int length) => String.fromCharCodes(
      Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<String?> uploadProfileImage(String filePath, String base64Image) async {
    final userId = getUserId();
    final path = '$userId.png';

    try {
      if (kIsWeb) {
        await _client.storage.from('avatars').uploadBinary(
          path,
          base64.decode(base64Image),
          fileOptions: const FileOptions(upsert: true, contentType: 'image/png'),
        );
      } else {
        await _client.storage.from('avatars').upload(
          path,
          File(filePath),
          fileOptions: const FileOptions(upsert: true, contentType: 'image/png'),
        );
      }
      return _client.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  Future<String?> uploadMessageImage(String filePath, String base64Image) async {
    final fileName = _getRandomString(20);
    final path = '$fileName.png';

    try {
      if (kIsWeb) {
        await _client.storage.from('chat-images').uploadBinary(
          path,
          base64.decode(base64Image),
          fileOptions: const FileOptions(contentType: 'image/png'),
        );
      } else {
        await _client.storage.from('chat-images').upload(
          path,
          File(filePath),
          fileOptions: const FileOptions(contentType: 'image/png'),
        );
      }
      return _client.storage.from('chat-images').getPublicUrl(path);
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  Future<void> deleteImage(String publicUrl) async {
    try {
      final uri = Uri.parse(publicUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf('avatars') != -1
          ? pathSegments.indexOf('avatars')
          : pathSegments.indexOf('chat-images');
      if (bucketIndex == -1) return;
      final bucket = pathSegments[bucketIndex];
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      await _client.storage.from(bucket).remove([filePath]);
    } catch (e) {
      Log.e(e.toString());
    }
  }

  Future<void> deleteUserAvatar(String userId) async {
    try {
      await _client.storage.from('avatars').remove(['$userId.png']);
    } catch (e) {
      Log.e('Error deleting avatar: $e');
    }
  }

  String getUserImageUrl(String userId) {
    return _client.storage.from('avatars').getPublicUrl('$userId.png');
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/repository/supabase_storage_repository.dart
git commit -m "feat: add SupabaseStorageRepository"
```

---

### Task 8: Create SupabaseRepository (main data layer)

**Files:**
- Create: `lib/repository/supabase_repository.dart`

- [ ] **Step 1: Create `lib/repository/supabase_repository.dart`**

```dart
import 'dart:async';

import 'package:chat/model/message.dart';
import 'package:chat/model/private_chat.dart';
import 'package:chat/model/room_chat.dart';
import 'package:chat/model/user_location.dart';
import 'package:chat/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/chat_user.dart';
import '../utils/auth_util.dart';
import '../utils/log.dart';
import '../utils/online_users_processor.dart';

class SupabaseRepository {
  final OnlineUserProcessor _processor;
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseRepository(this._processor);

  // =============================================
  // USER OPERATIONS
  // =============================================

  Future<ChatUser?> getUser({String? userId}) async {
    try {
      final uid = userId ?? _client.auth.currentUser?.id;
      if (uid == null) return null;
      final data = await _client.from('users').select().eq('id', uid).maybeSingle();
      if (data == null) return null;
      return ChatUser.fromJson(data['id'] as String, data);
    } catch (e) {
      Log.e("Failed to fetch user: $e");
      return null;
    }
  }

  Future<void> setInitialUserData(String email, String userId) async {
    try {
      await _client.from('users').upsert({
        'id': userId,
        'email': email,
        'approved_image': ApprovedImage.notReviewed.value,
        'created': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Log.e("Failed to add user: $e");
    }
  }

  Future<void> updateUserGender(Gender gender) async {
    try {
      await _client.from('users').update({
        'gender': gender.value,
        'last_active': DateTime.now().toIso8601String(),
      }).eq('id', getUserId());
    } catch (e) {
      Log.e("Failed to update user gender: $e");
    }
  }

  Future<void> updateUserBirthday(DateTime birthDate) async {
    try {
      await _client.from('users').update({
        'birth_date': birthDate.toIso8601String(),
        'last_active': DateTime.now().toIso8601String(),
      }).eq('id', getUserId());
    } catch (e) {
      Log.e("Failed to update user birthdate: $e");
    }
  }

  Future<void> updateUserShowAge(bool showAge) async {
    try {
      await _client.from('users').update({
        'show_age': showAge,
        'last_active': DateTime.now().toIso8601String(),
      }).eq('id', getUserId());
    } catch (e) {
      Log.e("Failed to update user show age: $e");
    }
  }

  Future<void> updateUserDisplayName(String fullName, List<String> searchArray) async {
    try {
      await _client.from('users').update({
        'display_name': fullName,
        'search_array': searchArray,
        'last_active': DateTime.now().toIso8601String(),
      }).eq('id', getUserId());
    } catch (e) {
      Log.e("Failed to update user displayName: $e");
    }
  }

  Future<void> updateUserProfileImage({
    required String profileImageUrl,
    required ChatUser user,
    required bool hasNudity,
  }) async {
    try {
      await _client.from('users').update({
        'last_active': DateTime.now().toIso8601String(),
        'picture_data': profileImageUrl,
        'approved_image': hasNudity ? ApprovedImage.notReviewed.value : ApprovedImage.approved.value,
        'image_reports': <String>[],
      }).eq('id', getUserId());
    } catch (e) {
      Log.e("Failed to update user image: $e");
    }
  }

  Future<bool> getIsNameAvailable(String displayName) async {
    try {
      final data = await _client
          .from('users')
          .select('id')
          .eq('display_name', displayName)
          .limit(1);
      return (data as List).isEmpty;
    } catch (e) {
      Log.e("Failed to check name: $e");
      return false;
    }
  }

  Future<void> updateUserOnLogout() async {
    await _client.from('users').update({
      'presence': false,
      'fcm_token': '',
      'last_active': DateTime.now().toIso8601String(),
    }).eq('id', getUserId());
  }

  void updateUserLocation(UserLocation userLocation) {
    _client.from('users').update({
      'city': userLocation.city,
      'country_code': userLocation.countryCode,
      'country': userLocation.countryName,
      'region_name': userLocation.state,
      'last_active': DateTime.now().toIso8601String(),
    }).eq('id', getUserId());
  }

  void setUserAsActive() {
    _client.from('users').update({
      'presence': true,
      'last_active': DateTime.now().toIso8601String(),
    }).eq('id', getUserId());
  }

  void updateCurrentUsersCurrentChatRoom({required String chatId}) {
    _client.from('users').update({
      'current_room_chat_id': chatId,
      'presence': true,
      'last_active': DateTime.now().toIso8601String(),
    }).eq('id', getUserId());
  }

  void saveFcmTokenOnUser(String fcmToken) {
    _client.from('users').update({
      'fcm_token': fcmToken,
      'last_active': DateTime.now().toIso8601String(),
    }).eq('id', getUserId());
  }

  void updateImageNotReviewedStatus() {
    _client.from('users').update({
      'approved_image': ApprovedImage.notReviewed.value,
    }).eq('id', getUserId());
  }

  Future<void> deleteUserPhoto() async {
    await _client.from('users').update({
      'picture_data': '',
      'approved_image': ApprovedImage.notReviewed.value,
    }).eq('id', getUserId());
  }

  Future<void> deleteUserAndFiles() async {
    final userId = getUserId();
    try {
      await _client.from('users').delete().eq('id', userId);
    } catch (e) {
      Log.e("Error deleting user: $e");
    }
  }

  Future<void> setUserAsPremium(bool isPremiumUser) async {
    await _client.from('users').update({
      'is_premium_user': isPremiumUser,
    }).eq('id', getUserId());
  }

  // =============================================
  // BLOCK / REPORT OPERATIONS
  // =============================================

  Future<void> blockUser(String id) async {
    final data = await _client.from('users').select('blocked_by').eq('id', id).single();
    final blockedBy = List<String>.from(data['blocked_by'] ?? []);
    if (!blockedBy.contains(getUserId())) {
      blockedBy.add(getUserId());
      await _client.from('users').update({'blocked_by': blockedBy}).eq('id', id);
    }
  }

  Future<void> unblockUser(String id) async {
    final data = await _client.from('users').select('blocked_by').eq('id', id).single();
    final blockedBy = List<String>.from(data['blocked_by'] ?? []);
    blockedBy.remove(getUserId());
    await _client.from('users').update({'blocked_by': blockedBy}).eq('id', id);
  }

  void reportMessage(Message message) async {
    await _client.from('reports').insert({
      'message_id': message.id,
      'message_text': message.text,
      'message_created': message.created.toIso8601String(),
      'message_created_by': message.createdById,
      'message_created_by_gender': message.createdByGender,
      'message_created_by_country_code': message.createdByCountryCode,
      'message_created_by_image_url': message.createdByImageUrl,
      'message_created_by_display_name': message.createdByName,
      'reported_by': getUserId(),
    });
  }

  Future<void> postInappropriateImageReport(String reportedUserId) async {
    final data = await _client.from('users').select('image_reports').eq('id', reportedUserId).single();
    final reports = List<String>.from(data['image_reports'] ?? []);
    if (!reports.contains(getUserId())) reports.add(getUserId());
    await _client.from('users').update({
      'image_reports': reports,
      'approved_image': ApprovedImage.notReviewed.value,
    }).eq('id', reportedUserId);
  }

  Future<void> postBotReport(String reportedUserId) async {
    final data = await _client.from('users').select('bot_reports').eq('id', reportedUserId).single();
    final reports = List<String>.from(data['bot_reports'] ?? []);
    if (!reports.contains(getUserId())) reports.add(getUserId());
    await _client.from('users').update({'bot_reports': reports}).eq('id', reportedUserId);
  }

  Future<void> postHatefulLanguageReport(String reportedUserId) async {
    final data = await _client.from('users').select('language_reports').eq('id', reportedUserId).single();
    final reports = List<String>.from(data['language_reports'] ?? []);
    if (!reports.contains(getUserId())) reports.add(getUserId());
    await _client.from('users').update({'language_reports': reports}).eq('id', reportedUserId);
  }

  // =============================================
  // ADMIN / MODERATION
  // =============================================

  Future<void> approveImage(String id) async {
    await _client.from('users').update({
      'approved_image': ApprovedImage.approved.value,
      'image_reports': <String>[],
    }).eq('id', id);
  }

  Future<void> rejectImage(String id) async {
    await _client.from('users').update({
      'approved_image': ApprovedImage.notApproved.value,
    }).eq('id', id);
  }

  // =============================================
  // CREDITS
  // =============================================

  Future<void> reduceUserCredits(String id, int i) async {
    await _client.rpc('increment_credits', params: {'target_user_id': id, 'amount': -i});
  }

  Future<void> increaseUserCredits(String id, int i) async {
    await _client.rpc('increment_credits', params: {'target_user_id': id, 'amount': i});
  }

  // =============================================
  // FEEDBACK
  // =============================================

  void postFeedback(String feedback, ChatUser user) {
    _client.from('feedback').insert({
      'feedback': feedback,
      'created_by_id': getUserId(),
      'created_by_name': user.displayName,
      'created_by_country_code': user.countryCode,
      'created_by_country_name': user.country,
    });
  }

  // =============================================
  // CHAT OPERATIONS
  // =============================================

  Future<RoomChat?> getChat(String chatId, bool isPrivateChat) async {
    try {
      final table = isPrivateChat ? 'private_chats' : 'chats';
      final data = await _client.from(table).select().eq('id', chatId).maybeSingle();
      if (data == null) return null;
      return RoomChat.fromJson(data['id'] as String, data);
    } catch (e) {
      Log.e("Failed to get chat: $e");
      return null;
    }
  }

  // =============================================
  // MESSAGE OPERATIONS
  // =============================================

  Future<List<Message>> getInitialMessages(String chatId, bool isPrivateChat) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .eq('is_private', isPrivateChat)
        .order('created', ascending: false)
        .limit(20);
    return (data as List).map((e) => Message.fromJson(e['id'] as String, e)).toList();
  }

  Future<List<Message>> getMoreMessages(
      String chatId, bool isPrivateChat, DateTime before) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .eq('is_private', isPrivateChat)
        .lt('created', before.toIso8601String())
        .order('created', ascending: false)
        .limit(20);
    return (data as List).map((e) => Message.fromJson(e['id'] as String, e)).toList();
  }

  Future<void> postMessage({
    required String chatId,
    required ChatUser user,
    required String message,
    required ChatType chatType,
    required bool isPrivateChat,
    bool isGiphy = false,
    String? sendPushToUserId,
    Message? replyMessage,
  }) async {
    if (isPrivateChat) {
      if (chatType == ChatType.message || chatType == ChatType.giphy || chatType == ChatType.image) {
        await _client.from('messages').insert({
          'chat_id': chatId,
          'is_private': true,
          'text': message,
          'chat_type': chatType.value,
          'created_by_id': getUserId(),
          'created_by_name': user.displayName,
          'created_by_gender': user.gender,
          'created_by_country_code': user.countryCode,
          'created_by_image_url': user.pictureData,
          'approved_image': user.approvedImage,
          'birth_date': user.birthDate?.toIso8601String(),
          'show_age': user.showAge,
          'image_reports': user.imageReports,
          'reply_id': replyMessage?.id,
          'reply_text': replyMessage?.text,
          'reply_chat_type': replyMessage?.chatType.value,
          'reply_created_by_id': replyMessage?.createdById,
          'reply_created_by_name': replyMessage?.createdByName,
          'reply_created_by_gender': replyMessage?.createdByGender,
          'reply_created_by_country_code': replyMessage?.createdByCountryCode,
          'reply_created_by_image_url': replyMessage?.createdByImageUrl,
          'reply_approved_image': replyMessage?.approvedImage,
          'reply_created': replyMessage?.created.toIso8601String(),
          'reply_birth_date': replyMessage?.birthDate?.toIso8601String(),
          'reply_show_age': replyMessage?.showAge,
          'reply_image_reports': replyMessage?.imageReports,
        });
      }
    } else {
      await _client.from('messages').insert({
        'chat_id': chatId,
        'is_private': false,
        'text': message,
        'chat_type': chatType.value,
        'created_by_id': getUserId(),
        'created_by_name': user.displayName,
        'created_by_gender': user.gender,
        'created_by_country_code': user.countryCode,
        'created_by_image_url': user.pictureData,
        'approved_image': user.approvedImage,
        'birth_date': user.birthDate?.toIso8601String(),
        'show_age': user.showAge,
        'image_reports': user.imageReports,
        'reply_id': replyMessage?.id,
        'reply_text': replyMessage?.text,
        'reply_chat_type': replyMessage?.chatType.value,
        'reply_created_by_id': replyMessage?.createdById,
        'reply_created_by_name': replyMessage?.createdByName,
        'reply_created_by_gender': replyMessage?.createdByGender,
        'reply_created_by_country_code': replyMessage?.createdByCountryCode,
        'reply_created_by_image_url': replyMessage?.createdByImageUrl,
        'reply_approved_image': replyMessage?.approvedImage,
        'reply_created': replyMessage?.created.toIso8601String(),
        'reply_birth_date': replyMessage?.birthDate?.toIso8601String(),
        'reply_show_age': replyMessage?.showAge,
        'reply_image_reports': replyMessage?.imageReports,
      });
    }

    if (chatType == ChatType.message || chatType == ChatType.giphy) {
      if (isPrivateChat) {
        await _client.from('private_chats').update({
          'last_message': message,
          'last_message_is_giphy': chatType == ChatType.giphy,
          'last_message_by_name': user.displayName,
          'last_message_read_by': [getUserId()],
          'last_message_timestamp': DateTime.now().toIso8601String(),
          'last_message_user_id': getUserId(),
          'send_push_to_user_id': sendPushToUserId,
        }).eq('id', chatId);
      }
    }
  }

  // =============================================
  // PRIVATE CHAT OPERATIONS
  // =============================================

  Future<PrivateChat?> createPrivateChat({
    required ChatUser myUser,
    required ChatUser otherUser,
    required String initialMessage,
  }) async {
    final trimmedMessage = initialMessage.trim();
    if (trimmedMessage.isEmpty || trimmedMessage.length > 1000) return null;
    try {
      final data = await _client.from('private_chats').insert({
        'users': [myUser.id, otherUser.id],
        'initiated_by': getUserId(),
        'initiated_by_user_name': myUser.displayName,
        'initiated_by_user_gender': myUser.gender,
        'initiated_by_picture_data': myUser.pictureData,
        'chat_name': '${otherUser.displayName} ${myUser.displayName}',
        'other_user_id': otherUser.id,
        'other_user_name': otherUser.displayName,
        'other_user_gender': otherUser.gender,
        'other_user_picture_data': otherUser.pictureData,
        'send_push_to_user_id': otherUser.id,
        'last_message_read_by': [getUserId()],
      }).select().single();

      await postMessage(
        chatId: data['id'] as String,
        user: myUser,
        message: trimmedMessage,
        isPrivateChat: true,
        chatType: ChatType.message,
        sendPushToUserId: otherUser.id,
      );
    } catch (e) {
      Log.e(e);
    }
    return null;
  }

  Future<bool> isPrivateChatAvailable(String userId) async {
    try {
      final data = await _client
          .from('private_chats')
          .select()
          .contains('users', [getUserId()]);
      final chats = (data as List)
          .map((e) => PrivateChat.fromJson(e['id'] as String, e))
          .where((e) => e.users.contains(userId));
      return chats.isEmpty;
    } catch (e) {
      Log.e("Failed to get chat: $e");
      return false;
    }
  }

  Future<void> leavePrivateChat(PrivateChat selectedChat) async {
    try {
      final data = await _client
          .from('private_chats')
          .select('users')
          .eq('id', selectedChat.id)
          .single();
      final users = List<String>.from(data['users'] ?? []);
      users.remove(getUserId());
      await _client.from('private_chats').update({'users': users}).eq('id', selectedChat.id);
    } catch (e) {
      Log.e("Failed to leave private chat: $e");
    }
  }

  Future<PrivateChat?> getPrivateChat(String userId) async {
    try {
      final data = await _client
          .from('private_chats')
          .select()
          .contains('users', [getUserId()]);
      return (data as List)
          .map((e) => PrivateChat.fromJson(e['id'] as String, e))
          .where((e) => e.users.contains(userId))
          .firstOrNull;
    } catch (e) {
      Log.e("Failed to fetch private chat: $e");
      return null;
    }
  }

  Future<void> setLastMessageRead({required String chatId}) async {
    try {
      final data = await _client
          .from('private_chats')
          .select('last_message_read_by')
          .eq('id', chatId)
          .single();
      final readBy = List<String>.from(data['last_message_read_by'] ?? []);
      if (!readBy.contains(getUserId())) {
        readBy.add(getUserId());
        await _client.from('private_chats').update({'last_message_read_by': readBy}).eq('id', chatId);
      }
    } catch (e) {
      Log.e(e);
    }
  }

  Future<void> leaveAllPrivateChats() async {
    final data = await _client
        .from('private_chats')
        .select()
        .contains('users', [getUserId()]);
    for (var doc in (data as List)) {
      await leavePrivateChat(PrivateChat.fromJson(doc['id'] as String, doc));
    }
  }

  // =============================================
  // STREAM OPERATIONS (REALTIME)
  // =============================================

  Stream<List<Message>> streamMessages(String chatId, bool isPrivateChat, int limit) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created', ascending: false)
        .limit(limit)
        .map((data) => data
            .where((e) => e['is_private'] == isPrivateChat)
            .map((e) => Message.fromJson(e['id'] as String, e))
            .toList());
  }

  Stream<ChatUser?> streamUser() {
    final userId = getUserId();
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isEmpty ? null : ChatUser.fromJson(data.first['id'] as String, data.first));
  }

  Stream<ChatUser?> streamUserById(String userId) {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) => data.isEmpty ? null : ChatUser.fromJson(data.first['id'] as String, data.first));
  }

  Stream<List<ChatUser>> streamUnapprovedImages() {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('approved_image', 0)
        .map((data) => data
            .where((e) => (e['picture_data'] ?? '').toString().isNotEmpty)
            .map((e) => ChatUser.fromJson(e['id'] as String, e))
            .toList());
  }

  Stream<List<RoomChat>> streamOpenChats(ChatUser user) {
    if (kDebugMode) {
      return _client
          .from('chats')
          .stream(primaryKey: ['id'])
          .map((data) => data
              .map((e) => RoomChat.fromJson(e['id'] as String, e))
              .toList());
    } else {
      return _client
          .from('chats')
          .stream(primaryKey: ['id'])
          .eq('enabled', true)
          .map((data) => data
              .where((e) => e['country_code'] == 'all' || e['country_code'] == user.countryCode)
              .map((e) => RoomChat.fromJson(e['id'] as String, e))
              .toList());
    }
  }

  // Private chats stream — RLS ensures only user's chats are visible
  final StreamController<List<PrivateChat>> _privateChatsStreamController =
      StreamController<List<PrivateChat>>.broadcast();
  RealtimeChannel? _privateChatsChannel;

  Stream<List<PrivateChat>> getPrivateChatsStream() => _privateChatsStreamController.stream;

  void startPrivateChatsStream(String userId) {
    _privateChatsChannel?.unsubscribe();

    _fetchAndEmitPrivateChats(userId);

    _privateChatsChannel = _client.channel('private-chats-$userId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'private_chats',
        callback: (_) => _fetchAndEmitPrivateChats(userId),
      )
      .subscribe();
  }

  Future<void> _fetchAndEmitPrivateChats(String userId) async {
    try {
      final data = await _client
          .from('private_chats')
          .select()
          .contains('users', [userId]);
      final chats = (data as List)
          .map((e) => PrivateChat.fromJson(e['id'] as String, e))
          .toList();
      if (!_privateChatsStreamController.isClosed) {
        _privateChatsStreamController.sink.add(chats);
      }
    } catch (e) {
      Log.e("Failed to get private chats: $e");
    }
  }

  void closePrivateChatStream() {
    _privateChatsChannel?.unsubscribe();
    _privateChatsStreamController.close();
  }

  // Online users stream
  final StreamController<List<ChatUser>> _onlineUsersStreamController =
      StreamController<List<ChatUser>>.broadcast();
  RealtimeChannel? _onlineUsersChannel;

  Stream<List<ChatUser>> get onlineUsersStream => _onlineUsersStreamController.stream;

  Future<void> startOnlineUsersStream(String countryCode) async {
    _onlineUsersChannel?.unsubscribe();
    _onlineUsersStreamController.sink.add([]);
    await _processor.start();

    _fetchAndEmitOnlineUsers(countryCode);

    _onlineUsersChannel = _client.channel('online-users')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'users',
        callback: (_) => _fetchAndEmitOnlineUsers(countryCode),
      )
      .subscribe();
  }

  Future<void> _fetchAndEmitOnlineUsers(String countryCode) async {
    try {
      final cutoff = DateTime.now().subtract(onlineDuration);
      final data = await _client
          .from('users')
          .select()
          .gte('last_active', cutoff.toIso8601String());

      final userData = (data as List)
          .map((e) => {'id': e['id'] as String, 'data': e as Map<String, dynamic>})
          .toList();

      final processedUsers = await _processor.process(
          userData, getUserId(), countryCode, onlineDuration);

      if (!_onlineUsersStreamController.isClosed) {
        _onlineUsersStreamController.sink.add(processedUsers);
      }
    } catch (e) {
      Log.e("Failed to get online users: $e");
    }
  }

  void closeOnlineUsersStream() {
    _onlineUsersChannel?.unsubscribe();
    _onlineUsersStreamController.close();
    _processor.stop();
  }

  void closeAllStreams() {
    _privateChatsChannel?.unsubscribe();
    _onlineUsersChannel?.unsubscribe();
    _privateChatsStreamController.close();
    _onlineUsersStreamController.close();
  }
}
```

- [ ] **Step 2: Verify**

Run: `cd /Users/lbofhn/Documents/Kvitter/chat && flutter analyze lib/repository/supabase_repository.dart`

- [ ] **Step 3: Commit**

```bash
git add lib/repository/supabase_repository.dart
git commit -m "feat: add SupabaseRepository with all data operations"
```

---

### Task 9: Create SupabasePresenceRepository

**Files:**
- Create: `lib/repository/supabase_presence_repository.dart`

- [ ] **Step 1: Create `lib/repository/supabase_presence_repository.dart`**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/auth_util.dart';
import '../utils/log.dart';

class SupabasePresenceRepository {
  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _presenceChannel;

  Future<void> updateUserPresence() async {
    try {
      await _client.from('users').update({
        'presence': true,
        'last_active': DateTime.now().toIso8601String(),
      }).eq('id', getUserId());

      _presenceChannel?.unsubscribe();
      _presenceChannel = _client.channel('presence-${getUserId()}');
      _presenceChannel!.subscribe((status, _) {
        if (status == RealtimeSubscribeStatus.closed) {
          _client.from('users').update({
            'presence': false,
            'last_active': DateTime.now().toIso8601String(),
          }).eq('id', getUserId());
        }
      });
    } catch (e) {
      Log.e('Error updating presence: $e');
    }
  }

  void dispose() {
    _presenceChannel?.unsubscribe();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/repository/supabase_presence_repository.dart
git commit -m "feat: add SupabasePresenceRepository"
```

---

### Task 10: Update OnlineUserProcessor

**Files:**
- Modify: `lib/utils/online_users_processor.dart`
- Modify: `lib/utils/web_online_user_processor.dart`

- [ ] **Step 1: Update `lib/utils/online_users_processor.dart`**

Replace the file. The processor now takes `List<Map<String, dynamic>>` (where each map has `{id, data}`) instead of `List<QueryDocumentSnapshot>`:

```dart
import 'dart:isolate';

import '../model/chat_user.dart';

abstract class OnlineUserProcessor {
  Future<List<ChatUser>> process(List<Map<String, dynamic>> users,
      String userId, String userCountryCode, Duration onlineDuration);

  void stop();

  Future<void> start();
}

class MobileOnlineUsersProcessor extends OnlineUserProcessor {
  Isolate? _isolate;
  SendPort? _sendPort;
  final ReceivePort _receivePort = ReceivePort();

  @override
  Future<void> start() async {
    _isolate = await Isolate.spawn(processUsers, _receivePort.sendPort);
    _sendPort = await _receivePort.first as SendPort;
  }

  @override
  Future<List<ChatUser>> process(List<Map<String, dynamic>> users,
      String userId, String userCountryCode, Duration onlineDuration) async {
    ReceivePort responsePort = ReceivePort();

    _sendPort!.send([
      users,
      userId,
      userCountryCode,
      onlineDuration,
      responsePort.sendPort
    ]);

    var result = await responsePort.first as List;
    return result as List<ChatUser>;
  }

  static void processUsers(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      var data = message[0] as List<Map<String, dynamic>>;
      var userId = message[1] as String;
      var userCountryCode = message[2] as String;
      var onlineDuration = message[3] as Duration;
      SendPort replyPort = message[4];

      var filteredUsers = data
          .where((element) => element['id'] != userId)
          .where((element) {
            final lastActive = element['data']['last_active'];
            if (lastActive == null) return false;
            final dt = DateTime.parse(lastActive as String);
            return dt.isAfter(DateTime.now().subtract(onlineDuration));
          })
          .toList();

      var chatUsers = filteredUsers.map((userData) {
        return ChatUser.fromJson(
            userData['id'] as String, userData['data'] as Map<String, dynamic>);
      }).toList();

      sortOnlineUsers(chatUsers, userCountryCode);

      replyPort.send(chatUsers);
    });
  }

  @override
  void stop() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }
}

void sortOnlineUsers(List<ChatUser> filteredUsers, String countryCode) {
  filteredUsers.sort((a, b) {
    bool isSameCountryAsMineA = a.countryCode == countryCode;
    bool isSameCountryAsMineB = b.countryCode == countryCode;

    if (a.countryCode.isEmpty) return 1;
    if (b.countryCode.isEmpty) return -1;

    if (isSameCountryAsMineA && isSameCountryAsMineB) {
      return b.lastActive.compareTo(a.lastActive);
    }
    if (isSameCountryAsMineA) return -1;
    if (isSameCountryAsMineB) return 1;

    int countryCodeComparison = a.countryCode.compareTo(b.countryCode);
    if (countryCodeComparison != 0) return countryCodeComparison;
    return b.lastActive.compareTo(a.lastActive);
  });
}
```

- [ ] **Step 2: Update `lib/utils/web_online_user_processor.dart`**

```dart
import '../model/chat_user.dart';
import 'online_users_processor.dart';

class WebOnlineUsersProcessor extends OnlineUserProcessor {
  @override
  Future<List<ChatUser>> process(List<Map<String, dynamic>> users,
      String userId, String userCountryCode, Duration onlineDuration) async {
    var filteredUsers = users
        .where((element) => element['id'] != userId)
        .where((element) {
          final lastActive = element['data']['last_active'];
          if (lastActive == null) return false;
          final dt = DateTime.parse(lastActive as String);
          return dt.isAfter(DateTime.now().subtract(onlineDuration));
        })
        .toList();

    var chatUsers = filteredUsers.map((userData) {
      return ChatUser.fromJson(
          userData['id'] as String, userData['data'] as Map<String, dynamic>);
    }).toList();

    sortOnlineUsers(chatUsers, userCountryCode);

    return chatUsers;
  }

  @override
  Future<void> start() => Future.value();

  @override
  void stop() {}
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/utils/online_users_processor.dart lib/utils/web_online_user_processor.dart
git commit -m "refactor: update OnlineUserProcessor for Supabase data format"
```

---

### Task 11: Update FcmRepository

**Files:**
- Modify: `lib/repository/fcm_repository.dart`

- [ ] **Step 1: Update `lib/repository/fcm_repository.dart`**

Change the dependency from `FirestoreRepository` to `SupabaseRepository`:

```dart
import 'dart:async';

import 'package:chat/repository/supabase_repository.dart';
import 'package:chat/utils/app_badge.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../utils/log.dart';

class FcmRepository {
  final SupabaseRepository _supabaseRepository;
  StreamSubscription<String>? _tokenRefreshSubscription;

  FcmRepository(this._supabaseRepository);

  void setUpPushNotification() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Log.d('User granted permission');
      setUpToken();
      setUpBadge();
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      Log.d('User granted provisional permission');
      setUpToken();
      setUpBadge();
    } else {
      Log.d('User declined or has not accepted permission');
    }
  }

  Future<void> setUpToken() async {
    String? fcmToken;
    if (kIsWeb) {
      fcmToken = await FirebaseMessaging.instance
          .getToken(vapidKey: "F_2QYMzyCsTi_pPd2OYiGlLEjm8ibzvS3YJaUzawCkU");
    } else {
      fcmToken = await FirebaseMessaging.instance.getToken();
    }

    if (fcmToken != null) _supabaseRepository.saveFcmTokenOnUser(fcmToken);

    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      Log.d('FCM token updated: $fcmToken');
      _supabaseRepository.saveFcmTokenOnUser(fcmToken);
    }, onError: (err) {
      Log.e('FCM token error: $err');
    });
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  void setUpBadge() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Log.d('A new onMessageOpenedApp event was published!');
      if (!kIsWeb) AppBadge.removeBadge();
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    Log.d('Handling a background message ${message.messageId}');
    if (!kIsWeb) AppBadge.updateBadgeCount(1);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/repository/fcm_repository.dart
git commit -m "refactor: update FcmRepository to use SupabaseRepository"
```

---

### Task 12: Update main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Update `lib/main.dart`**

Key changes:
1. Initialize Supabase alongside Firebase (which is kept for Crashlytics + FCM)
2. Replace `FirestoreRepository` with `SupabaseRepository`
3. Replace `LoginRepository` with `SupabaseAuthRepository`
4. Replace `StorageRepository` with `SupabaseStorageRepository`
5. Replace `PresenceDatabase` with `SupabasePresenceRepository`
6. Remove `FirebaseAppCheck`
7. Remove `firebase_options.dart` import

Replace the imports and initialization logic. The full updated `main.dart`:

In `main()`, add Supabase initialization before `runApp`:

```dart
await Supabase.initialize(
  url: SupabaseConfig.url,
  anonKey: SupabaseConfig.anonKey,
);
```

Change `_initializeFirebase()` to only init `firebase_core` (for Crashlytics and FCM), removing App Check.

Change the provider setup in `build()`:

```dart
final OnlineUserProcessor onlineUsersProcessor =
    kIsWeb ? WebOnlineUsersProcessor() : MobileOnlineUsersProcessor();
final SupabaseRepository supabaseRepository =
    SupabaseRepository(onlineUsersProcessor);
final SupabaseAuthRepository authRepository = SupabaseAuthRepository();
final SupabaseStorageRepository storageRepository = SupabaseStorageRepository();
final FcmRepository fcmRepository = FcmRepository(supabaseRepository);
final AppImageCropper appImageCropper = AppImageCropper(context);
final SupabasePresenceRepository presenceRepository = SupabasePresenceRepository();
final ChatClickedRepository chatClickedRepository = ChatClickedRepository();
final SubscriptionRepository subscriptionRepository =
    SubscriptionRepository(supabaseRepository);

return MultiProvider(
  providers: [
    Provider<SupabaseRepository>.value(value: supabaseRepository),
    Provider<SupabaseAuthRepository>.value(value: authRepository),
    Provider<SupabaseStorageRepository>.value(value: storageRepository),
    Provider<SupabasePresenceRepository>.value(value: presenceRepository),
    Provider<AppImageCropper>.value(value: appImageCropper),
    Provider<FcmRepository>.value(value: fcmRepository),
    Provider<OnlineUserProcessor>.value(value: onlineUsersProcessor),
    Provider<ChatClickedRepository>.value(value: chatClickedRepository),
    Provider<SubscriptionRepository>.value(value: subscriptionRepository),
  ],
  // ... rest unchanged
);
```

Update imports at top of file:
- Remove: `firebase_app_check`, `firebase_options.dart`
- Add: `supabase_flutter`, `supabase_config.dart`, new repository imports
- Replace: old repository imports with new ones

- [ ] **Step 2: Verify**

Run: `cd /Users/lbofhn/Documents/Kvitter/chat && flutter analyze lib/main.dart`

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "refactor: update main.dart for Supabase initialization and DI"
```

---

### Task 13: Update all BLoCs to use SupabaseRepository

**Files:**
- Modify: All BLoC files in `lib/screens/*/bloc/`

This is the largest task but the changes are mechanical. For each BLoC:

1. Replace `import 'firestore_repository.dart'` with `import 'supabase_repository.dart'`
2. Replace `FirestoreRepository` type with `SupabaseRepository`
3. Replace `StreamSubscription<QuerySnapshot>` with typed subscriptions
4. Remove QuerySnapshot parsing (BLoCs now receive parsed model objects)
5. Replace `getUserId()` import from `firestore_repository.dart` to `auth_util.dart`

- [ ] **Step 1: Update `lib/screens/messages/bloc/messages_bloc.dart`**

Changes:
- `import 'firestore_repository.dart'` → `import 'supabase_repository.dart'`
- `import 'package:cloud_firestore/cloud_firestore.dart'` → remove
- `FirestoreRepository _firestoreRepository` → `SupabaseRepository _supabaseRepository`
- `StreamSubscription<QuerySnapshot>? messagesStream` → `StreamSubscription<List<Message>>? messagesStream`
- `StreamSubscription<QuerySnapshot>? userStream` → `StreamSubscription<ChatUser?>? userStream`
- `StreamSubscription<QuerySnapshot>? privateChatsStream` → `StreamSubscription<List<PrivateChat>>? privateChatsStream`
- Add `import 'package:chat/utils/auth_util.dart'`

In `_setUpMessagesListener`: replace QuerySnapshot parsing:
```dart
// OLD:
messagesStream = _firestoreRepository
    .streamMessages(chatId, isPrivateChat, 20)
    .listen((data) {
  final messages = data.docs
      .map((e) => Message.fromJson(e.id, e.data() as Map<String, dynamic>))
      .toList();
  if (messages.isNotEmpty) add(MessagesUpdatedEvent(messages));
});

// NEW:
messagesStream = _supabaseRepository
    .streamMessages(chatId, isPrivateChat, 20)
    .listen((messages) {
  if (messages.isNotEmpty) add(MessagesUpdatedEvent(messages));
});
```

In `_setUpUserListener`: replace QuerySnapshot parsing:
```dart
// OLD:
userStream = _firestoreRepository.streamUser().listen((event) async {
  if (event.docs.isEmpty) return;
  final Map<String, dynamic> userData = event.docs.first.data() as Map<String, dynamic>;
  if (userData.containsKey('lastActive') && userData['lastActive'] is Timestamp) {
    userData['lastActive'] = (userData['lastActive'] as Timestamp).millisecondsSinceEpoch;
  }
  final user = ChatUser.fromJson(event.docs.first.id, userData);
  add(MessagesUserUpdatedEvent(user));
});

// NEW:
userStream = _supabaseRepository.streamUser().listen((user) async {
  if (user == null) return;
  add(MessagesUserUpdatedEvent(user));
});
```

In `_setUpPrivateChatStream`: replace QuerySnapshot parsing:
```dart
// OLD:
privateChatsStream = _firestoreRepository.getPrivateChatsStream().listen((event) async {
  final PrivateChat? updatedChat = event.docs
      .map((e) => PrivateChat.fromJson(e.id, e.data() as Map<String, dynamic>))
      .firstWhereOrNull((element) => element.id == chat.id);
  if (updatedChat != null) add(MessagesPrivateChatsUpdatedEvent(updatedChat));
});

// NEW:
privateChatsStream = _supabaseRepository.getPrivateChatsStream().listen((chats) async {
  final PrivateChat? updatedChat = chats.firstWhereOrNull((element) => element.id == chat.id);
  if (updatedChat != null) add(MessagesPrivateChatsUpdatedEvent(updatedChat));
});
```

In image upload methods (`_onGalleryClicked`, `_onCameraClicked`): replace `imageUrl?.getDownloadURL()` with direct URL usage since `SupabaseStorageRepository.uploadMessageImage` returns a URL string:
```dart
// OLD:
final imageUrl = await _storageRepository.uploadMessageImage(pickedFile.path, base64Image);
final finalUrl = await imageUrl?.getDownloadURL() ?? "";

// NEW:
final finalUrl = await _storageRepository.uploadMessageImage(pickedFile.path, base64Image) ?? "";
```

Also change `_storageRepository` type from `StorageRepository` to `SupabaseStorageRepository`.

- [ ] **Step 2: Update remaining BLoCs**

Apply the same pattern to all BLoCs. Each BLoC needs:

**`lib/screens/chat/bloc/chat_bloc.dart`:**
- `FirestoreRepository` → `SupabaseRepository`
- `streamUser()` listener: parse `ChatUser?` instead of `QuerySnapshot`
- `streamOpenChats()` listener: parse `List<RoomChat>` instead of `QuerySnapshot`

**`lib/screens/people/bloc/people_bloc.dart`:**
- `FirestoreRepository` → `SupabaseRepository`
- `onlineUsersStream` already returns `List<ChatUser>` — no parsing change needed

**`lib/screens/profile/bloc/profile_bloc.dart`:**
- `FirestoreRepository` → `SupabaseRepository`
- `streamUser()` listener: parse `ChatUser?` instead of `QuerySnapshot`

**`lib/screens/login/bloc/login_bloc.dart`:**
- `LoginRepository` → `SupabaseAuthRepository`
- `FirestoreRepository` → `SupabaseRepository`
- Replace `signInWithGoogle()` return type handling
- Replace `FirebaseAuth.instance.signInAnonymously()` with `_authRepository.signInAnonymously()`

**`lib/screens/splash/bloc/splash_bloc.dart`:**
- Remove `FirebaseAuth.instance.currentUser` check
- Use `Supabase.instance.client.auth.currentUser` instead
- `FirestoreRepository` → `SupabaseRepository`

**`lib/screens/account/bloc/account_bloc.dart`:**
- `FirestoreRepository` → `SupabaseRepository`
- `streamUser()` listener: parse `ChatUser?` instead of `QuerySnapshot`
- Replace `FirebaseAuth.instance.signOut()` with `_authRepository.signOut()`

**`lib/screens/visit/bloc/visit_bloc.dart`:**
- `FirestoreRepository` → `SupabaseRepository`
- `streamUserById()` listener: parse `ChatUser?` instead of `QuerySnapshot`

**`lib/screens/review/bloc/review_bloc.dart`:**
- `FirestoreRepository` → `SupabaseRepository`
- `streamUnapprovedImages()` listener: parse `List<ChatUser>` instead of `QuerySnapshot`

**`lib/screens/options/bloc/options_bloc.dart`:**
- `FirestoreRepository` → `SupabaseRepository`
- `streamUser()` listener: parse `ChatUser?` instead of `QuerySnapshot`

**`lib/screens/onboarding_photo/bloc/onboarding_photo_bloc.dart`:**
- `FirestoreRepository` → `SupabaseRepository`
- `StorageRepository` → `SupabaseStorageRepository`
- Replace `uploadProfileImage` return type handling (URL string instead of Reference)

**`lib/screens/message_holder/bloc/message_holder_bloc.dart`:**
- `FirestoreRepository` → `SupabaseRepository`
- `streamUser()`, `getPrivateChatsStream()`, `onlineUsersStream` listeners: update parsing

- [ ] **Step 3: Update `lib/utils/gender.dart`**

Change the import from `firestore_repository.dart` to `enums.dart`:
```dart
// OLD:
import '../repository/firestore_repository.dart';
// NEW:
import '../utils/enums.dart';
```

- [ ] **Step 4: Update screen files that reference repository types**

Search for `context.read<FirestoreRepository>()` in all screen files and replace with `context.read<SupabaseRepository>()`. Same for `LoginRepository`, `StorageRepository`, `PresenceDatabase`.

Run: `cd /Users/lbofhn/Documents/Kvitter/chat && grep -rn "FirestoreRepository\|LoginRepository\|StorageRepository\|PresenceDatabase" lib/screens/ --include="*.dart" -l`

Update each file found.

- [ ] **Step 5: Update `lib/repository/subscription_repository.dart`**

Change the dependency from `FirestoreRepository` to `SupabaseRepository`:
- `final FirestoreRepository _firestoreRepository` → `final SupabaseRepository _supabaseRepository`
- Update constructor and all usages

- [ ] **Step 6: Verify**

Run: `cd /Users/lbofhn/Documents/Kvitter/chat && flutter analyze`

Fix any remaining type errors. Common issues:
- Missing imports for `SupabaseRepository`, `SupabaseAuthRepository`, etc.
- `Timestamp` references that need to be `DateTime`
- `QuerySnapshot` references that need to be removed
- `getUserId()` imports pointing to old location

- [ ] **Step 7: Commit**

```bash
git add lib/screens/ lib/repository/subscription_repository.dart
git commit -m "refactor: update all BLoCs and screens for Supabase repositories"
```

---

### Task 14: Update callers of time_util.dart

**Files:**
- All files that call `getLastMessageTimeFromTimeStamp`, `getTimeSince`, `getDurationFromNow`, `getFormattedDate`, `getFormattedTime`, `getMessageDate`

- [ ] **Step 1: Find all callers**

Run: `cd /Users/lbofhn/Documents/Kvitter/chat && grep -rn "getLastMessageTimeFromTimeStamp\|getTimeSince\|getDurationFromNow\|getFormattedDate\|getFormattedTime\|getMessageDate" lib/ --include="*.dart" -l`

- [ ] **Step 2: Update function names and parameter types**

In each caller, update:
- `getLastMessageTimeFromTimeStamp(timestamp)` → `getLastMessageTimeFromDateTime(dateTime)`
- `getTimeSince(timestamp)` → `getTimeSince(dateTime)` (parameter is now DateTime)
- `getDurationFromNow(timestamp)` → `getDurationFromNow(dateTime)`
- `getFormattedDate(timestamp)` → `getFormattedDate(dateTime)`
- `getFormattedTime(timestamp)` → `getFormattedTime(dateTime)`
- `getMessageDate(timestamp)` → `getMessageDate(dateTime)`

Since model fields are now `DateTime` instead of `Timestamp`, callers no longer need `.toDate()` conversions.

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "refactor: update time_util callers for DateTime parameters"
```

---

### Task 15: Rewrite Cloud Function for HTTP-triggered push notifications

**Files:**
- Modify: `functions/index.js`

- [ ] **Step 1: Replace `functions/index.js`**

```javascript
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const SUPABASE_URL = "https://YOUR_MAC_MINI_DOMAIN";
const SUPABASE_SERVICE_KEY = "YOUR_SUPABASE_SERVICE_ROLE_KEY";

exports.sendPushNotification = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    res.status(405).send("Method Not Allowed");
    return;
  }

  try {
    const {record} = req.body;

    if (!record || !record.send_push_to_user_id) {
      res.status(200).send("No push needed");
      return;
    }

    const recipientId = record.send_push_to_user_id;
    const senderName = record.last_message_by_name || "Someone";
    const messageText = record.last_message || "";

    // Fetch recipient's FCM token from Supabase
    const response = await fetch(
        `${SUPABASE_URL}/rest/v1/users?id=eq.${recipientId}&select=fcm_token`,
        {
          headers: {
            "apikey": SUPABASE_SERVICE_KEY,
            "Authorization": `Bearer ${SUPABASE_SERVICE_KEY}`,
          },
        },
    );

    const users = await response.json();
    if (!users || users.length === 0 || !users[0].fcm_token) {
      res.status(200).send("No FCM token found");
      return;
    }

    const fcmToken = users[0].fcm_token;

    const payload = {
      notification: {
        title: senderName,
        body: messageText,
      },
    };

    await admin.messaging().send({
      token: fcmToken,
      notification: payload.notification,
    });

    res.status(200).send("Push sent");
  } catch (error) {
    console.error("Error sending push:", error);
    res.status(500).send("Error");
  }
});
```

- [ ] **Step 2: Configure Supabase webhook**

In the Supabase dashboard (or via SQL), create a webhook that calls this Cloud Function URL whenever `private_chats` is updated:

```sql
-- Run this in Supabase SQL editor
CREATE OR REPLACE FUNCTION notify_push_on_private_message()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.last_message IS DISTINCT FROM OLD.last_message AND NEW.send_push_to_user_id IS NOT NULL THEN
    PERFORM net.http_post(
      url := 'https://YOUR_CLOUD_FUNCTION_URL/sendPushNotification',
      body := jsonb_build_object('record', row_to_json(NEW)),
      headers := '{"Content-Type": "application/json"}'::jsonb
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_push_notification
  AFTER UPDATE ON private_chats
  FOR EACH ROW
  EXECUTE FUNCTION notify_push_on_private_message();
```

Note: This requires the `pg_net` extension enabled in Supabase (enabled by default in self-hosted).

- [ ] **Step 3: Commit**

```bash
git add functions/
git commit -m "feat: rewrite Cloud Function as HTTP-triggered push notification endpoint"
```

---

### Task 16: Cleanup — remove unused Firebase files and packages

**Files:**
- Delete: `lib/firebase_options.dart`
- Delete: `lib/repository/firestore_repository.dart`
- Delete: `lib/repository/login_repository.dart`
- Delete: `lib/repository/storage_repository.dart`
- Delete: `lib/repository/presence_database.dart`

- [ ] **Step 1: Verify no remaining references to old files**

Run: `cd /Users/lbofhn/Documents/Kvitter/chat && grep -rn "firestore_repository\|login_repository\|storage_repository\|presence_database\|firebase_options" lib/ --include="*.dart"`

Fix any remaining imports.

- [ ] **Step 2: Delete old files**

```bash
rm lib/firebase_options.dart
rm lib/repository/firestore_repository.dart
rm lib/repository/login_repository.dart
rm lib/repository/storage_repository.dart
rm lib/repository/presence_database.dart
```

- [ ] **Step 3: Remove unused imports across codebase**

Run: `cd /Users/lbofhn/Documents/Kvitter/chat && grep -rn "cloud_firestore\|firebase_auth\|firebase_storage\|firebase_database\|firebase_app_check\|firebase_analytics\|firebase_performance\|google_sign_in\|sign_in_with_apple" lib/ --include="*.dart"`

Remove each occurrence.

- [ ] **Step 4: Run full analysis**

Run: `cd /Users/lbofhn/Documents/Kvitter/chat && flutter analyze`

Fix all errors until analysis passes clean.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore: remove unused Firebase files and imports"
```

---

### Task 17: User migration script

**Files:**
- Create: `scripts/migrate_users.dart`

- [ ] **Step 1: Create `scripts/migrate_users.dart`**

This is a one-time script to export Firebase Auth users and create them in Supabase:

```dart
// Run with: dart run scripts/migrate_users.dart
//
// Prerequisites:
// 1. Export Firebase Auth users to a JSON file using Firebase Admin SDK:
//    firebase auth:export users.json --format=json
// 2. Set environment variables:
//    SUPABASE_URL=https://your-mac-mini-domain
//    SUPABASE_SERVICE_KEY=your-service-role-key

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL']!;
  final serviceKey = Platform.environment['SUPABASE_SERVICE_KEY']!;

  final usersFile = File('users.json');
  if (!usersFile.existsSync()) {
    print('users.json not found. Export from Firebase first.');
    exit(1);
  }

  final usersData = jsonDecode(usersFile.readAsStringSync());
  final users = usersData['users'] as List;

  print('Migrating ${users.length} users...');

  for (final user in users) {
    final email = user['email'] as String?;
    final uid = user['localId'] as String;

    if (email == null || email.isEmpty) {
      print('Skipping anonymous user: $uid');
      continue;
    }

    try {
      // Create user in Supabase Auth via admin API
      final response = await http.post(
        Uri.parse('$supabaseUrl/auth/v1/admin/users'),
        headers: {
          'apikey': serviceKey,
          'Authorization': 'Bearer $serviceKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'email_confirm': true,
          'user_metadata': {'firebase_uid': uid},
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newUser = jsonDecode(response.body);
        final newId = newUser['id'];

        // Create users table row with firebase_uid mapping
        await http.post(
          Uri.parse('$supabaseUrl/rest/v1/users'),
          headers: {
            'apikey': serviceKey,
            'Authorization': 'Bearer $serviceKey',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal',
          },
          body: jsonEncode({
            'id': newId,
            'firebase_uid': uid,
            'email': email,
          }),
        );

        print('Migrated: $email ($uid -> $newId)');
      } else {
        print('Failed to create user $email: ${response.body}');
      }
    } catch (e) {
      print('Error migrating $email: $e');
    }
  }

  print('Migration complete.');
}
```

- [ ] **Step 2: Commit**

```bash
git add scripts/migrate_users.dart
git commit -m "feat: add user migration script from Firebase to Supabase"
```

---

### Task 18: Final verification

- [ ] **Step 1: Run full analysis**

Run: `cd /Users/lbofhn/Documents/Kvitter/chat && flutter analyze`

- [ ] **Step 2: Test build**

Run: `cd /Users/lbofhn/Documents/Kvitter/chat && flutter build web`

- [ ] **Step 3: Verify all Firebase removals**

Run: `cd /Users/lbofhn/Documents/Kvitter/chat && grep -rn "cloud_firestore\|firebase_auth\|firebase_storage\|firebase_database" lib/ --include="*.dart"`

Should return zero results.

- [ ] **Step 4: Verify kept Firebase packages**

Run: `cd /Users/lbofhn/Documents/Kvitter/chat && grep -rn "firebase_crashlytics\|firebase_messaging\|firebase_core" lib/ --include="*.dart"`

Should show only `main.dart`, `fcm_repository.dart`, and `log.dart`.

- [ ] **Step 5: Commit final state**

```bash
git add -A
git commit -m "feat: complete Firebase to Supabase migration"
```
