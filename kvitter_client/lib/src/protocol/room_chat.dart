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

abstract class RoomChat implements _i1.SerializableModel {
  RoomChat._({
    this.id,
    required this.chatName,
    required this.chatColor,
    required this.imageUrl,
    required this.countryCode,
    required this.enabled,
    required this.infoKey,
    required this.imageOverflow,
    required this.imageTranslationX,
    required this.lastMessage,
    required this.lastMessageIsGiphy,
    required this.lastMessageByName,
    required this.lastMessageTimestamp,
    this.lastMessageUserId,
  });

  factory RoomChat({
    _i1.UuidValue? id,
    required String chatName,
    required int chatColor,
    required String imageUrl,
    required String countryCode,
    required bool enabled,
    required String infoKey,
    required int imageOverflow,
    required int imageTranslationX,
    required String lastMessage,
    required bool lastMessageIsGiphy,
    required String lastMessageByName,
    required DateTime lastMessageTimestamp,
    _i1.UuidValue? lastMessageUserId,
  }) = _RoomChatImpl;

  factory RoomChat.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomChat(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      chatName: jsonSerialization['chatName'] as String,
      chatColor: jsonSerialization['chatColor'] as int,
      imageUrl: jsonSerialization['imageUrl'] as String,
      countryCode: jsonSerialization['countryCode'] as String,
      enabled: _i1.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      infoKey: jsonSerialization['infoKey'] as String,
      imageOverflow: jsonSerialization['imageOverflow'] as int,
      imageTranslationX: jsonSerialization['imageTranslationX'] as int,
      lastMessage: jsonSerialization['lastMessage'] as String,
      lastMessageIsGiphy: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['lastMessageIsGiphy'],
      ),
      lastMessageByName: jsonSerialization['lastMessageByName'] as String,
      lastMessageTimestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastMessageTimestamp'],
      ),
      lastMessageUserId: jsonSerialization['lastMessageUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['lastMessageUserId'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String chatName;

  int chatColor;

  String imageUrl;

  String countryCode;

  bool enabled;

  String infoKey;

  int imageOverflow;

  int imageTranslationX;

  String lastMessage;

  bool lastMessageIsGiphy;

  String lastMessageByName;

  DateTime lastMessageTimestamp;

  _i1.UuidValue? lastMessageUserId;

  /// Returns a shallow copy of this [RoomChat]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RoomChat copyWith({
    _i1.UuidValue? id,
    String? chatName,
    int? chatColor,
    String? imageUrl,
    String? countryCode,
    bool? enabled,
    String? infoKey,
    int? imageOverflow,
    int? imageTranslationX,
    String? lastMessage,
    bool? lastMessageIsGiphy,
    String? lastMessageByName,
    DateTime? lastMessageTimestamp,
    _i1.UuidValue? lastMessageUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomChat',
      if (id != null) 'id': id?.toJson(),
      'chatName': chatName,
      'chatColor': chatColor,
      'imageUrl': imageUrl,
      'countryCode': countryCode,
      'enabled': enabled,
      'infoKey': infoKey,
      'imageOverflow': imageOverflow,
      'imageTranslationX': imageTranslationX,
      'lastMessage': lastMessage,
      'lastMessageIsGiphy': lastMessageIsGiphy,
      'lastMessageByName': lastMessageByName,
      'lastMessageTimestamp': lastMessageTimestamp.toJson(),
      if (lastMessageUserId != null)
        'lastMessageUserId': lastMessageUserId?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomChatImpl extends RoomChat {
  _RoomChatImpl({
    _i1.UuidValue? id,
    required String chatName,
    required int chatColor,
    required String imageUrl,
    required String countryCode,
    required bool enabled,
    required String infoKey,
    required int imageOverflow,
    required int imageTranslationX,
    required String lastMessage,
    required bool lastMessageIsGiphy,
    required String lastMessageByName,
    required DateTime lastMessageTimestamp,
    _i1.UuidValue? lastMessageUserId,
  }) : super._(
         id: id,
         chatName: chatName,
         chatColor: chatColor,
         imageUrl: imageUrl,
         countryCode: countryCode,
         enabled: enabled,
         infoKey: infoKey,
         imageOverflow: imageOverflow,
         imageTranslationX: imageTranslationX,
         lastMessage: lastMessage,
         lastMessageIsGiphy: lastMessageIsGiphy,
         lastMessageByName: lastMessageByName,
         lastMessageTimestamp: lastMessageTimestamp,
         lastMessageUserId: lastMessageUserId,
       );

  /// Returns a shallow copy of this [RoomChat]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RoomChat copyWith({
    Object? id = _Undefined,
    String? chatName,
    int? chatColor,
    String? imageUrl,
    String? countryCode,
    bool? enabled,
    String? infoKey,
    int? imageOverflow,
    int? imageTranslationX,
    String? lastMessage,
    bool? lastMessageIsGiphy,
    String? lastMessageByName,
    DateTime? lastMessageTimestamp,
    Object? lastMessageUserId = _Undefined,
  }) {
    return RoomChat(
      id: id is _i1.UuidValue? ? id : this.id,
      chatName: chatName ?? this.chatName,
      chatColor: chatColor ?? this.chatColor,
      imageUrl: imageUrl ?? this.imageUrl,
      countryCode: countryCode ?? this.countryCode,
      enabled: enabled ?? this.enabled,
      infoKey: infoKey ?? this.infoKey,
      imageOverflow: imageOverflow ?? this.imageOverflow,
      imageTranslationX: imageTranslationX ?? this.imageTranslationX,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageIsGiphy: lastMessageIsGiphy ?? this.lastMessageIsGiphy,
      lastMessageByName: lastMessageByName ?? this.lastMessageByName,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastMessageUserId: lastMessageUserId is _i1.UuidValue?
          ? lastMessageUserId
          : this.lastMessageUserId,
    );
  }
}
