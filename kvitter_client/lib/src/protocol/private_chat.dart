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

abstract class PrivateChat implements _i1.SerializableModel {
  PrivateChat._({
    this.id,
    required this.users,
    required this.created,
    required this.initiatedBy,
    required this.initiatedByUserName,
    required this.initiatedByUserGender,
    required this.initiatedByPictureData,
    required this.chatName,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserGender,
    required this.otherUserPictureData,
    required this.lastMessage,
    required this.lastMessageIsGiphy,
    required this.lastMessageByName,
    required this.lastMessageTimestamp,
    this.lastMessageUserId,
    required this.lastMessageReadBy,
    this.sendPushToUserId,
  });

  factory PrivateChat({
    _i1.UuidValue? id,
    required List<String> users,
    required DateTime created,
    required String initiatedBy,
    required String initiatedByUserName,
    required int initiatedByUserGender,
    required String initiatedByPictureData,
    required String chatName,
    required String otherUserId,
    required String otherUserName,
    required int otherUserGender,
    required String otherUserPictureData,
    required String lastMessage,
    required bool lastMessageIsGiphy,
    required String lastMessageByName,
    required DateTime lastMessageTimestamp,
    String? lastMessageUserId,
    required List<String> lastMessageReadBy,
    String? sendPushToUserId,
  }) = _PrivateChatImpl;

  factory PrivateChat.fromJson(Map<String, dynamic> jsonSerialization) {
    return PrivateChat(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      users: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['users'],
      ),
      created: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['created']),
      initiatedBy: jsonSerialization['initiatedBy'] as String,
      initiatedByUserName: jsonSerialization['initiatedByUserName'] as String,
      initiatedByUserGender: jsonSerialization['initiatedByUserGender'] as int,
      initiatedByPictureData:
          jsonSerialization['initiatedByPictureData'] as String,
      chatName: jsonSerialization['chatName'] as String,
      otherUserId: jsonSerialization['otherUserId'] as String,
      otherUserName: jsonSerialization['otherUserName'] as String,
      otherUserGender: jsonSerialization['otherUserGender'] as int,
      otherUserPictureData: jsonSerialization['otherUserPictureData'] as String,
      lastMessage: jsonSerialization['lastMessage'] as String,
      lastMessageIsGiphy: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['lastMessageIsGiphy'],
      ),
      lastMessageByName: jsonSerialization['lastMessageByName'] as String,
      lastMessageTimestamp: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastMessageTimestamp'],
      ),
      lastMessageUserId: jsonSerialization['lastMessageUserId'] as String?,
      lastMessageReadBy: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['lastMessageReadBy'],
      ),
      sendPushToUserId: jsonSerialization['sendPushToUserId'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  List<String> users;

  DateTime created;

  String initiatedBy;

  String initiatedByUserName;

  int initiatedByUserGender;

  String initiatedByPictureData;

  String chatName;

  String otherUserId;

  String otherUserName;

  int otherUserGender;

  String otherUserPictureData;

  String lastMessage;

  bool lastMessageIsGiphy;

  String lastMessageByName;

  DateTime lastMessageTimestamp;

  String? lastMessageUserId;

  List<String> lastMessageReadBy;

  String? sendPushToUserId;

  /// Returns a shallow copy of this [PrivateChat]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PrivateChat copyWith({
    _i1.UuidValue? id,
    List<String>? users,
    DateTime? created,
    String? initiatedBy,
    String? initiatedByUserName,
    int? initiatedByUserGender,
    String? initiatedByPictureData,
    String? chatName,
    String? otherUserId,
    String? otherUserName,
    int? otherUserGender,
    String? otherUserPictureData,
    String? lastMessage,
    bool? lastMessageIsGiphy,
    String? lastMessageByName,
    DateTime? lastMessageTimestamp,
    String? lastMessageUserId,
    List<String>? lastMessageReadBy,
    String? sendPushToUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PrivateChat',
      if (id != null) 'id': id?.toJson(),
      'users': users.toJson(),
      'created': created.toJson(),
      'initiatedBy': initiatedBy,
      'initiatedByUserName': initiatedByUserName,
      'initiatedByUserGender': initiatedByUserGender,
      'initiatedByPictureData': initiatedByPictureData,
      'chatName': chatName,
      'otherUserId': otherUserId,
      'otherUserName': otherUserName,
      'otherUserGender': otherUserGender,
      'otherUserPictureData': otherUserPictureData,
      'lastMessage': lastMessage,
      'lastMessageIsGiphy': lastMessageIsGiphy,
      'lastMessageByName': lastMessageByName,
      'lastMessageTimestamp': lastMessageTimestamp.toJson(),
      if (lastMessageUserId != null) 'lastMessageUserId': lastMessageUserId,
      'lastMessageReadBy': lastMessageReadBy.toJson(),
      if (sendPushToUserId != null) 'sendPushToUserId': sendPushToUserId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PrivateChatImpl extends PrivateChat {
  _PrivateChatImpl({
    _i1.UuidValue? id,
    required List<String> users,
    required DateTime created,
    required String initiatedBy,
    required String initiatedByUserName,
    required int initiatedByUserGender,
    required String initiatedByPictureData,
    required String chatName,
    required String otherUserId,
    required String otherUserName,
    required int otherUserGender,
    required String otherUserPictureData,
    required String lastMessage,
    required bool lastMessageIsGiphy,
    required String lastMessageByName,
    required DateTime lastMessageTimestamp,
    String? lastMessageUserId,
    required List<String> lastMessageReadBy,
    String? sendPushToUserId,
  }) : super._(
         id: id,
         users: users,
         created: created,
         initiatedBy: initiatedBy,
         initiatedByUserName: initiatedByUserName,
         initiatedByUserGender: initiatedByUserGender,
         initiatedByPictureData: initiatedByPictureData,
         chatName: chatName,
         otherUserId: otherUserId,
         otherUserName: otherUserName,
         otherUserGender: otherUserGender,
         otherUserPictureData: otherUserPictureData,
         lastMessage: lastMessage,
         lastMessageIsGiphy: lastMessageIsGiphy,
         lastMessageByName: lastMessageByName,
         lastMessageTimestamp: lastMessageTimestamp,
         lastMessageUserId: lastMessageUserId,
         lastMessageReadBy: lastMessageReadBy,
         sendPushToUserId: sendPushToUserId,
       );

  /// Returns a shallow copy of this [PrivateChat]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PrivateChat copyWith({
    Object? id = _Undefined,
    List<String>? users,
    DateTime? created,
    String? initiatedBy,
    String? initiatedByUserName,
    int? initiatedByUserGender,
    String? initiatedByPictureData,
    String? chatName,
    String? otherUserId,
    String? otherUserName,
    int? otherUserGender,
    String? otherUserPictureData,
    String? lastMessage,
    bool? lastMessageIsGiphy,
    String? lastMessageByName,
    DateTime? lastMessageTimestamp,
    Object? lastMessageUserId = _Undefined,
    List<String>? lastMessageReadBy,
    Object? sendPushToUserId = _Undefined,
  }) {
    return PrivateChat(
      id: id is _i1.UuidValue? ? id : this.id,
      users: users ?? this.users.map((e0) => e0).toList(),
      created: created ?? this.created,
      initiatedBy: initiatedBy ?? this.initiatedBy,
      initiatedByUserName: initiatedByUserName ?? this.initiatedByUserName,
      initiatedByUserGender:
          initiatedByUserGender ?? this.initiatedByUserGender,
      initiatedByPictureData:
          initiatedByPictureData ?? this.initiatedByPictureData,
      chatName: chatName ?? this.chatName,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserGender: otherUserGender ?? this.otherUserGender,
      otherUserPictureData: otherUserPictureData ?? this.otherUserPictureData,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageIsGiphy: lastMessageIsGiphy ?? this.lastMessageIsGiphy,
      lastMessageByName: lastMessageByName ?? this.lastMessageByName,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastMessageUserId: lastMessageUserId is String?
          ? lastMessageUserId
          : this.lastMessageUserId,
      lastMessageReadBy:
          lastMessageReadBy ?? this.lastMessageReadBy.map((e0) => e0).toList(),
      sendPushToUserId: sendPushToUserId is String?
          ? sendPushToUserId
          : this.sendPushToUserId,
    );
  }
}
