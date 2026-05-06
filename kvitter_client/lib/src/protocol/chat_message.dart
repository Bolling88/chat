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

abstract class ChatMessage implements _i1.SerializableModel {
  ChatMessage._({
    this.id,
    required this.chatId,
    required this.isPrivate,
    required this.text,
    required this.chatType,
    required this.createdById,
    required this.createdByName,
    required this.createdByGender,
    required this.createdByCountryCode,
    required this.createdByImageUrl,
    required this.approvedImage,
    required this.created,
    this.birthDate,
    required this.showAge,
    required this.imageReports,
    this.replyId,
    required this.replyText,
    required this.replyChatType,
    this.replyCreatedById,
    required this.replyCreatedByName,
    required this.replyCreatedByGender,
    required this.replyCreatedByCountryCode,
    required this.replyCreatedByImageUrl,
    required this.replyApprovedImage,
    this.replyCreated,
    this.replyBirthDate,
    required this.replyShowAge,
    required this.replyImageReports,
  });

  factory ChatMessage({
    _i1.UuidValue? id,
    required String chatId,
    required bool isPrivate,
    required String text,
    required int chatType,
    required String createdById,
    required String createdByName,
    required int createdByGender,
    required String createdByCountryCode,
    required String createdByImageUrl,
    required int approvedImage,
    required DateTime created,
    DateTime? birthDate,
    required bool showAge,
    required List<String> imageReports,
    String? replyId,
    required String replyText,
    required int replyChatType,
    String? replyCreatedById,
    required String replyCreatedByName,
    required int replyCreatedByGender,
    required String replyCreatedByCountryCode,
    required String replyCreatedByImageUrl,
    required int replyApprovedImage,
    DateTime? replyCreated,
    DateTime? replyBirthDate,
    required bool replyShowAge,
    required List<String> replyImageReports,
  }) = _ChatMessageImpl;

  factory ChatMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatMessage(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      chatId: jsonSerialization['chatId'] as String,
      isPrivate: _i1.BoolJsonExtension.fromJson(jsonSerialization['isPrivate']),
      text: jsonSerialization['text'] as String,
      chatType: jsonSerialization['chatType'] as int,
      createdById: jsonSerialization['createdById'] as String,
      createdByName: jsonSerialization['createdByName'] as String,
      createdByGender: jsonSerialization['createdByGender'] as int,
      createdByCountryCode: jsonSerialization['createdByCountryCode'] as String,
      createdByImageUrl: jsonSerialization['createdByImageUrl'] as String,
      approvedImage: jsonSerialization['approvedImage'] as int,
      created: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['created']),
      birthDate: jsonSerialization['birthDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['birthDate']),
      showAge: _i1.BoolJsonExtension.fromJson(jsonSerialization['showAge']),
      imageReports: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['imageReports'],
      ),
      replyId: jsonSerialization['replyId'] as String?,
      replyText: jsonSerialization['replyText'] as String,
      replyChatType: jsonSerialization['replyChatType'] as int,
      replyCreatedById: jsonSerialization['replyCreatedById'] as String?,
      replyCreatedByName: jsonSerialization['replyCreatedByName'] as String,
      replyCreatedByGender: jsonSerialization['replyCreatedByGender'] as int,
      replyCreatedByCountryCode:
          jsonSerialization['replyCreatedByCountryCode'] as String,
      replyCreatedByImageUrl:
          jsonSerialization['replyCreatedByImageUrl'] as String,
      replyApprovedImage: jsonSerialization['replyApprovedImage'] as int,
      replyCreated: jsonSerialization['replyCreated'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['replyCreated'],
            ),
      replyBirthDate: jsonSerialization['replyBirthDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['replyBirthDate'],
            ),
      replyShowAge: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['replyShowAge'],
      ),
      replyImageReports: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['replyImageReports'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String chatId;

  bool isPrivate;

  String text;

  int chatType;

  String createdById;

  String createdByName;

  int createdByGender;

  String createdByCountryCode;

  String createdByImageUrl;

  int approvedImage;

  DateTime created;

  DateTime? birthDate;

  bool showAge;

  List<String> imageReports;

  String? replyId;

  String replyText;

  int replyChatType;

  String? replyCreatedById;

  String replyCreatedByName;

  int replyCreatedByGender;

  String replyCreatedByCountryCode;

  String replyCreatedByImageUrl;

  int replyApprovedImage;

  DateTime? replyCreated;

  DateTime? replyBirthDate;

  bool replyShowAge;

  List<String> replyImageReports;

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatMessage copyWith({
    _i1.UuidValue? id,
    String? chatId,
    bool? isPrivate,
    String? text,
    int? chatType,
    String? createdById,
    String? createdByName,
    int? createdByGender,
    String? createdByCountryCode,
    String? createdByImageUrl,
    int? approvedImage,
    DateTime? created,
    DateTime? birthDate,
    bool? showAge,
    List<String>? imageReports,
    String? replyId,
    String? replyText,
    int? replyChatType,
    String? replyCreatedById,
    String? replyCreatedByName,
    int? replyCreatedByGender,
    String? replyCreatedByCountryCode,
    String? replyCreatedByImageUrl,
    int? replyApprovedImage,
    DateTime? replyCreated,
    DateTime? replyBirthDate,
    bool? replyShowAge,
    List<String>? replyImageReports,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatMessage',
      if (id != null) 'id': id?.toJson(),
      'chatId': chatId,
      'isPrivate': isPrivate,
      'text': text,
      'chatType': chatType,
      'createdById': createdById,
      'createdByName': createdByName,
      'createdByGender': createdByGender,
      'createdByCountryCode': createdByCountryCode,
      'createdByImageUrl': createdByImageUrl,
      'approvedImage': approvedImage,
      'created': created.toJson(),
      if (birthDate != null) 'birthDate': birthDate?.toJson(),
      'showAge': showAge,
      'imageReports': imageReports.toJson(),
      if (replyId != null) 'replyId': replyId,
      'replyText': replyText,
      'replyChatType': replyChatType,
      if (replyCreatedById != null) 'replyCreatedById': replyCreatedById,
      'replyCreatedByName': replyCreatedByName,
      'replyCreatedByGender': replyCreatedByGender,
      'replyCreatedByCountryCode': replyCreatedByCountryCode,
      'replyCreatedByImageUrl': replyCreatedByImageUrl,
      'replyApprovedImage': replyApprovedImage,
      if (replyCreated != null) 'replyCreated': replyCreated?.toJson(),
      if (replyBirthDate != null) 'replyBirthDate': replyBirthDate?.toJson(),
      'replyShowAge': replyShowAge,
      'replyImageReports': replyImageReports.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatMessageImpl extends ChatMessage {
  _ChatMessageImpl({
    _i1.UuidValue? id,
    required String chatId,
    required bool isPrivate,
    required String text,
    required int chatType,
    required String createdById,
    required String createdByName,
    required int createdByGender,
    required String createdByCountryCode,
    required String createdByImageUrl,
    required int approvedImage,
    required DateTime created,
    DateTime? birthDate,
    required bool showAge,
    required List<String> imageReports,
    String? replyId,
    required String replyText,
    required int replyChatType,
    String? replyCreatedById,
    required String replyCreatedByName,
    required int replyCreatedByGender,
    required String replyCreatedByCountryCode,
    required String replyCreatedByImageUrl,
    required int replyApprovedImage,
    DateTime? replyCreated,
    DateTime? replyBirthDate,
    required bool replyShowAge,
    required List<String> replyImageReports,
  }) : super._(
         id: id,
         chatId: chatId,
         isPrivate: isPrivate,
         text: text,
         chatType: chatType,
         createdById: createdById,
         createdByName: createdByName,
         createdByGender: createdByGender,
         createdByCountryCode: createdByCountryCode,
         createdByImageUrl: createdByImageUrl,
         approvedImage: approvedImage,
         created: created,
         birthDate: birthDate,
         showAge: showAge,
         imageReports: imageReports,
         replyId: replyId,
         replyText: replyText,
         replyChatType: replyChatType,
         replyCreatedById: replyCreatedById,
         replyCreatedByName: replyCreatedByName,
         replyCreatedByGender: replyCreatedByGender,
         replyCreatedByCountryCode: replyCreatedByCountryCode,
         replyCreatedByImageUrl: replyCreatedByImageUrl,
         replyApprovedImage: replyApprovedImage,
         replyCreated: replyCreated,
         replyBirthDate: replyBirthDate,
         replyShowAge: replyShowAge,
         replyImageReports: replyImageReports,
       );

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatMessage copyWith({
    Object? id = _Undefined,
    String? chatId,
    bool? isPrivate,
    String? text,
    int? chatType,
    String? createdById,
    String? createdByName,
    int? createdByGender,
    String? createdByCountryCode,
    String? createdByImageUrl,
    int? approvedImage,
    DateTime? created,
    Object? birthDate = _Undefined,
    bool? showAge,
    List<String>? imageReports,
    Object? replyId = _Undefined,
    String? replyText,
    int? replyChatType,
    Object? replyCreatedById = _Undefined,
    String? replyCreatedByName,
    int? replyCreatedByGender,
    String? replyCreatedByCountryCode,
    String? replyCreatedByImageUrl,
    int? replyApprovedImage,
    Object? replyCreated = _Undefined,
    Object? replyBirthDate = _Undefined,
    bool? replyShowAge,
    List<String>? replyImageReports,
  }) {
    return ChatMessage(
      id: id is _i1.UuidValue? ? id : this.id,
      chatId: chatId ?? this.chatId,
      isPrivate: isPrivate ?? this.isPrivate,
      text: text ?? this.text,
      chatType: chatType ?? this.chatType,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      createdByGender: createdByGender ?? this.createdByGender,
      createdByCountryCode: createdByCountryCode ?? this.createdByCountryCode,
      createdByImageUrl: createdByImageUrl ?? this.createdByImageUrl,
      approvedImage: approvedImage ?? this.approvedImage,
      created: created ?? this.created,
      birthDate: birthDate is DateTime? ? birthDate : this.birthDate,
      showAge: showAge ?? this.showAge,
      imageReports: imageReports ?? this.imageReports.map((e0) => e0).toList(),
      replyId: replyId is String? ? replyId : this.replyId,
      replyText: replyText ?? this.replyText,
      replyChatType: replyChatType ?? this.replyChatType,
      replyCreatedById: replyCreatedById is String?
          ? replyCreatedById
          : this.replyCreatedById,
      replyCreatedByName: replyCreatedByName ?? this.replyCreatedByName,
      replyCreatedByGender: replyCreatedByGender ?? this.replyCreatedByGender,
      replyCreatedByCountryCode:
          replyCreatedByCountryCode ?? this.replyCreatedByCountryCode,
      replyCreatedByImageUrl:
          replyCreatedByImageUrl ?? this.replyCreatedByImageUrl,
      replyApprovedImage: replyApprovedImage ?? this.replyApprovedImage,
      replyCreated: replyCreated is DateTime?
          ? replyCreated
          : this.replyCreated,
      replyBirthDate: replyBirthDate is DateTime?
          ? replyBirthDate
          : this.replyBirthDate,
      replyShowAge: replyShowAge ?? this.replyShowAge,
      replyImageReports:
          replyImageReports ?? this.replyImageReports.map((e0) => e0).toList(),
    );
  }
}
