/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'package:kvitter_client/src/protocol/protocol.dart' as _i2;

abstract class ChatUser implements _i1.SerializableModel {
  ChatUser._({
    this.id,
    required this.authUserIdentifier,
    required this.email,
    required this.displayName,
    required this.gender,
    this.birthDate,
    required this.showAge,
    required this.pictureData,
    required this.approvedImage,
    required this.city,
    required this.countryCode,
    required this.country,
    required this.regionName,
    required this.presence,
    required this.lastActive,
    this.currentRoomChatId,
    required this.fcmToken,
    required this.blockedBy,
    required this.imageReports,
    required this.botReports,
    required this.languageReports,
    required this.kvitterCredits,
    required this.isPremiumUser,
    required this.onboardingCompleted,
    required this.isAdmin,
    required this.searchArray,
  });

  factory ChatUser({
    _i1.UuidValue? id,
    required String authUserIdentifier,
    required String email,
    required String displayName,
    required int gender,
    DateTime? birthDate,
    required bool showAge,
    required String pictureData,
    required int approvedImage,
    required String city,
    required String countryCode,
    required String country,
    required String regionName,
    required bool presence,
    required DateTime lastActive,
    _i1.UuidValue? currentRoomChatId,
    required String fcmToken,
    required List<String> blockedBy,
    required List<String> imageReports,
    required List<String> botReports,
    required List<String> languageReports,
    required int kvitterCredits,
    required bool isPremiumUser,
    required bool onboardingCompleted,
    required bool isAdmin,
    required List<String> searchArray,
  }) = _ChatUserImpl;

  factory ChatUser.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatUser(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authUserIdentifier: jsonSerialization['authUserIdentifier'] as String,
      email: jsonSerialization['email'] as String,
      displayName: jsonSerialization['displayName'] as String,
      gender: jsonSerialization['gender'] as int,
      birthDate: jsonSerialization['birthDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['birthDate']),
      showAge: _i1.BoolJsonExtension.fromJson(jsonSerialization['showAge']),
      pictureData: jsonSerialization['pictureData'] as String,
      approvedImage: jsonSerialization['approvedImage'] as int,
      city: jsonSerialization['city'] as String,
      countryCode: jsonSerialization['countryCode'] as String,
      country: jsonSerialization['country'] as String,
      regionName: jsonSerialization['regionName'] as String,
      presence: _i1.BoolJsonExtension.fromJson(jsonSerialization['presence']),
      lastActive: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastActive'],
      ),
      currentRoomChatId: jsonSerialization['currentRoomChatId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['currentRoomChatId'],
            ),
      fcmToken: jsonSerialization['fcmToken'] as String,
      blockedBy: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['blockedBy'],
      ),
      imageReports: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['imageReports'],
      ),
      botReports: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['botReports'],
      ),
      languageReports: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['languageReports'],
      ),
      kvitterCredits: jsonSerialization['kvitterCredits'] as int,
      isPremiumUser: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['isPremiumUser'],
      ),
      onboardingCompleted: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['onboardingCompleted'],
      ),
      isAdmin: _i1.BoolJsonExtension.fromJson(jsonSerialization['isAdmin']),
      searchArray: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['searchArray'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String authUserIdentifier;

  String email;

  String displayName;

  int gender;

  DateTime? birthDate;

  bool showAge;

  String pictureData;

  int approvedImage;

  String city;

  String countryCode;

  String country;

  String regionName;

  bool presence;

  DateTime lastActive;

  _i1.UuidValue? currentRoomChatId;

  String fcmToken;

  List<String> blockedBy;

  List<String> imageReports;

  List<String> botReports;

  List<String> languageReports;

  int kvitterCredits;

  bool isPremiumUser;

  bool onboardingCompleted;

  bool isAdmin;

  List<String> searchArray;

  /// Returns a shallow copy of this [ChatUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatUser copyWith({
    _i1.UuidValue? id,
    String? authUserIdentifier,
    String? email,
    String? displayName,
    int? gender,
    DateTime? birthDate,
    bool? showAge,
    String? pictureData,
    int? approvedImage,
    String? city,
    String? countryCode,
    String? country,
    String? regionName,
    bool? presence,
    DateTime? lastActive,
    _i1.UuidValue? currentRoomChatId,
    String? fcmToken,
    List<String>? blockedBy,
    List<String>? imageReports,
    List<String>? botReports,
    List<String>? languageReports,
    int? kvitterCredits,
    bool? isPremiumUser,
    bool? onboardingCompleted,
    bool? isAdmin,
    List<String>? searchArray,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatUser',
      if (id != null) 'id': id?.toJson(),
      'authUserIdentifier': authUserIdentifier,
      'email': email,
      'displayName': displayName,
      'gender': gender,
      if (birthDate != null) 'birthDate': birthDate?.toJson(),
      'showAge': showAge,
      'pictureData': pictureData,
      'approvedImage': approvedImage,
      'city': city,
      'countryCode': countryCode,
      'country': country,
      'regionName': regionName,
      'presence': presence,
      'lastActive': lastActive.toJson(),
      if (currentRoomChatId != null)
        'currentRoomChatId': currentRoomChatId?.toJson(),
      'fcmToken': fcmToken,
      'blockedBy': blockedBy.toJson(),
      'imageReports': imageReports.toJson(),
      'botReports': botReports.toJson(),
      'languageReports': languageReports.toJson(),
      'kvitterCredits': kvitterCredits,
      'isPremiumUser': isPremiumUser,
      'onboardingCompleted': onboardingCompleted,
      'isAdmin': isAdmin,
      'searchArray': searchArray.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatUserImpl extends ChatUser {
  _ChatUserImpl({
    _i1.UuidValue? id,
    required String authUserIdentifier,
    required String email,
    required String displayName,
    required int gender,
    DateTime? birthDate,
    required bool showAge,
    required String pictureData,
    required int approvedImage,
    required String city,
    required String countryCode,
    required String country,
    required String regionName,
    required bool presence,
    required DateTime lastActive,
    _i1.UuidValue? currentRoomChatId,
    required String fcmToken,
    required List<String> blockedBy,
    required List<String> imageReports,
    required List<String> botReports,
    required List<String> languageReports,
    required int kvitterCredits,
    required bool isPremiumUser,
    required bool onboardingCompleted,
    required bool isAdmin,
    required List<String> searchArray,
  }) : super._(
         id: id,
         authUserIdentifier: authUserIdentifier,
         email: email,
         displayName: displayName,
         gender: gender,
         birthDate: birthDate,
         showAge: showAge,
         pictureData: pictureData,
         approvedImage: approvedImage,
         city: city,
         countryCode: countryCode,
         country: country,
         regionName: regionName,
         presence: presence,
         lastActive: lastActive,
         currentRoomChatId: currentRoomChatId,
         fcmToken: fcmToken,
         blockedBy: blockedBy,
         imageReports: imageReports,
         botReports: botReports,
         languageReports: languageReports,
         kvitterCredits: kvitterCredits,
         isPremiumUser: isPremiumUser,
         onboardingCompleted: onboardingCompleted,
         isAdmin: isAdmin,
         searchArray: searchArray,
       );

  /// Returns a shallow copy of this [ChatUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatUser copyWith({
    Object? id = _Undefined,
    String? authUserIdentifier,
    String? email,
    String? displayName,
    int? gender,
    Object? birthDate = _Undefined,
    bool? showAge,
    String? pictureData,
    int? approvedImage,
    String? city,
    String? countryCode,
    String? country,
    String? regionName,
    bool? presence,
    DateTime? lastActive,
    Object? currentRoomChatId = _Undefined,
    String? fcmToken,
    List<String>? blockedBy,
    List<String>? imageReports,
    List<String>? botReports,
    List<String>? languageReports,
    int? kvitterCredits,
    bool? isPremiumUser,
    bool? onboardingCompleted,
    bool? isAdmin,
    List<String>? searchArray,
  }) {
    return ChatUser(
      id: id is _i1.UuidValue? ? id : this.id,
      authUserIdentifier: authUserIdentifier ?? this.authUserIdentifier,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      birthDate: birthDate is DateTime? ? birthDate : this.birthDate,
      showAge: showAge ?? this.showAge,
      pictureData: pictureData ?? this.pictureData,
      approvedImage: approvedImage ?? this.approvedImage,
      city: city ?? this.city,
      countryCode: countryCode ?? this.countryCode,
      country: country ?? this.country,
      regionName: regionName ?? this.regionName,
      presence: presence ?? this.presence,
      lastActive: lastActive ?? this.lastActive,
      currentRoomChatId: currentRoomChatId is _i1.UuidValue?
          ? currentRoomChatId
          : this.currentRoomChatId,
      fcmToken: fcmToken ?? this.fcmToken,
      blockedBy: blockedBy ?? this.blockedBy.map((e0) => e0).toList(),
      imageReports: imageReports ?? this.imageReports.map((e0) => e0).toList(),
      botReports: botReports ?? this.botReports.map((e0) => e0).toList(),
      languageReports:
          languageReports ?? this.languageReports.map((e0) => e0).toList(),
      kvitterCredits: kvitterCredits ?? this.kvitterCredits,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isAdmin: isAdmin ?? this.isAdmin,
      searchArray: searchArray ?? this.searchArray.map((e0) => e0).toList(),
    );
  }
}
