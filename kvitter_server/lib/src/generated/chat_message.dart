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
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:kvitter_server/src/generated/protocol.dart' as _i2;

abstract class ChatMessage
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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

  static final t = ChatMessageTable();

  static const db = ChatMessageRepository._();

  @override
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

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static ChatMessageInclude include() {
    return ChatMessageInclude._();
  }

  static ChatMessageIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatMessageTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatMessageTable>? orderByList,
    ChatMessageInclude? include,
  }) {
    return ChatMessageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatMessage.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ChatMessage.t),
      include: include,
    );
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

class ChatMessageUpdateTable extends _i1.UpdateTable<ChatMessageTable> {
  ChatMessageUpdateTable(super.table);

  _i1.ColumnValue<String, String> chatId(String value) => _i1.ColumnValue(
    table.chatId,
    value,
  );

  _i1.ColumnValue<bool, bool> isPrivate(bool value) => _i1.ColumnValue(
    table.isPrivate,
    value,
  );

  _i1.ColumnValue<String, String> text(String value) => _i1.ColumnValue(
    table.text,
    value,
  );

  _i1.ColumnValue<int, int> chatType(int value) => _i1.ColumnValue(
    table.chatType,
    value,
  );

  _i1.ColumnValue<String, String> createdById(String value) => _i1.ColumnValue(
    table.createdById,
    value,
  );

  _i1.ColumnValue<String, String> createdByName(String value) =>
      _i1.ColumnValue(
        table.createdByName,
        value,
      );

  _i1.ColumnValue<int, int> createdByGender(int value) => _i1.ColumnValue(
    table.createdByGender,
    value,
  );

  _i1.ColumnValue<String, String> createdByCountryCode(String value) =>
      _i1.ColumnValue(
        table.createdByCountryCode,
        value,
      );

  _i1.ColumnValue<String, String> createdByImageUrl(String value) =>
      _i1.ColumnValue(
        table.createdByImageUrl,
        value,
      );

  _i1.ColumnValue<int, int> approvedImage(int value) => _i1.ColumnValue(
    table.approvedImage,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> created(DateTime value) =>
      _i1.ColumnValue(
        table.created,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> birthDate(DateTime? value) =>
      _i1.ColumnValue(
        table.birthDate,
        value,
      );

  _i1.ColumnValue<bool, bool> showAge(bool value) => _i1.ColumnValue(
    table.showAge,
    value,
  );

  _i1.ColumnValue<List<String>, List<String>> imageReports(
    List<String> value,
  ) => _i1.ColumnValue(
    table.imageReports,
    value,
  );

  _i1.ColumnValue<String, String> replyId(String? value) => _i1.ColumnValue(
    table.replyId,
    value,
  );

  _i1.ColumnValue<String, String> replyText(String value) => _i1.ColumnValue(
    table.replyText,
    value,
  );

  _i1.ColumnValue<int, int> replyChatType(int value) => _i1.ColumnValue(
    table.replyChatType,
    value,
  );

  _i1.ColumnValue<String, String> replyCreatedById(String? value) =>
      _i1.ColumnValue(
        table.replyCreatedById,
        value,
      );

  _i1.ColumnValue<String, String> replyCreatedByName(String value) =>
      _i1.ColumnValue(
        table.replyCreatedByName,
        value,
      );

  _i1.ColumnValue<int, int> replyCreatedByGender(int value) => _i1.ColumnValue(
    table.replyCreatedByGender,
    value,
  );

  _i1.ColumnValue<String, String> replyCreatedByCountryCode(String value) =>
      _i1.ColumnValue(
        table.replyCreatedByCountryCode,
        value,
      );

  _i1.ColumnValue<String, String> replyCreatedByImageUrl(String value) =>
      _i1.ColumnValue(
        table.replyCreatedByImageUrl,
        value,
      );

  _i1.ColumnValue<int, int> replyApprovedImage(int value) => _i1.ColumnValue(
    table.replyApprovedImage,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> replyCreated(DateTime? value) =>
      _i1.ColumnValue(
        table.replyCreated,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> replyBirthDate(DateTime? value) =>
      _i1.ColumnValue(
        table.replyBirthDate,
        value,
      );

  _i1.ColumnValue<bool, bool> replyShowAge(bool value) => _i1.ColumnValue(
    table.replyShowAge,
    value,
  );

  _i1.ColumnValue<List<String>, List<String>> replyImageReports(
    List<String> value,
  ) => _i1.ColumnValue(
    table.replyImageReports,
    value,
  );
}

class ChatMessageTable extends _i1.Table<_i1.UuidValue?> {
  ChatMessageTable({super.tableRelation}) : super(tableName: 'messages') {
    updateTable = ChatMessageUpdateTable(this);
    chatId = _i1.ColumnString(
      'chatId',
      this,
    );
    isPrivate = _i1.ColumnBool(
      'isPrivate',
      this,
    );
    text = _i1.ColumnString(
      'text',
      this,
    );
    chatType = _i1.ColumnInt(
      'chatType',
      this,
    );
    createdById = _i1.ColumnString(
      'createdById',
      this,
    );
    createdByName = _i1.ColumnString(
      'createdByName',
      this,
    );
    createdByGender = _i1.ColumnInt(
      'createdByGender',
      this,
    );
    createdByCountryCode = _i1.ColumnString(
      'createdByCountryCode',
      this,
    );
    createdByImageUrl = _i1.ColumnString(
      'createdByImageUrl',
      this,
    );
    approvedImage = _i1.ColumnInt(
      'approvedImage',
      this,
    );
    created = _i1.ColumnDateTime(
      'created',
      this,
    );
    birthDate = _i1.ColumnDateTime(
      'birthDate',
      this,
    );
    showAge = _i1.ColumnBool(
      'showAge',
      this,
    );
    imageReports = _i1.ColumnSerializable<List<String>>(
      'imageReports',
      this,
    );
    replyId = _i1.ColumnString(
      'replyId',
      this,
    );
    replyText = _i1.ColumnString(
      'replyText',
      this,
    );
    replyChatType = _i1.ColumnInt(
      'replyChatType',
      this,
    );
    replyCreatedById = _i1.ColumnString(
      'replyCreatedById',
      this,
    );
    replyCreatedByName = _i1.ColumnString(
      'replyCreatedByName',
      this,
    );
    replyCreatedByGender = _i1.ColumnInt(
      'replyCreatedByGender',
      this,
    );
    replyCreatedByCountryCode = _i1.ColumnString(
      'replyCreatedByCountryCode',
      this,
    );
    replyCreatedByImageUrl = _i1.ColumnString(
      'replyCreatedByImageUrl',
      this,
    );
    replyApprovedImage = _i1.ColumnInt(
      'replyApprovedImage',
      this,
    );
    replyCreated = _i1.ColumnDateTime(
      'replyCreated',
      this,
    );
    replyBirthDate = _i1.ColumnDateTime(
      'replyBirthDate',
      this,
    );
    replyShowAge = _i1.ColumnBool(
      'replyShowAge',
      this,
    );
    replyImageReports = _i1.ColumnSerializable<List<String>>(
      'replyImageReports',
      this,
    );
  }

  late final ChatMessageUpdateTable updateTable;

  late final _i1.ColumnString chatId;

  late final _i1.ColumnBool isPrivate;

  late final _i1.ColumnString text;

  late final _i1.ColumnInt chatType;

  late final _i1.ColumnString createdById;

  late final _i1.ColumnString createdByName;

  late final _i1.ColumnInt createdByGender;

  late final _i1.ColumnString createdByCountryCode;

  late final _i1.ColumnString createdByImageUrl;

  late final _i1.ColumnInt approvedImage;

  late final _i1.ColumnDateTime created;

  late final _i1.ColumnDateTime birthDate;

  late final _i1.ColumnBool showAge;

  late final _i1.ColumnSerializable<List<String>> imageReports;

  late final _i1.ColumnString replyId;

  late final _i1.ColumnString replyText;

  late final _i1.ColumnInt replyChatType;

  late final _i1.ColumnString replyCreatedById;

  late final _i1.ColumnString replyCreatedByName;

  late final _i1.ColumnInt replyCreatedByGender;

  late final _i1.ColumnString replyCreatedByCountryCode;

  late final _i1.ColumnString replyCreatedByImageUrl;

  late final _i1.ColumnInt replyApprovedImage;

  late final _i1.ColumnDateTime replyCreated;

  late final _i1.ColumnDateTime replyBirthDate;

  late final _i1.ColumnBool replyShowAge;

  late final _i1.ColumnSerializable<List<String>> replyImageReports;

  @override
  List<_i1.Column> get columns => [
    id,
    chatId,
    isPrivate,
    text,
    chatType,
    createdById,
    createdByName,
    createdByGender,
    createdByCountryCode,
    createdByImageUrl,
    approvedImage,
    created,
    birthDate,
    showAge,
    imageReports,
    replyId,
    replyText,
    replyChatType,
    replyCreatedById,
    replyCreatedByName,
    replyCreatedByGender,
    replyCreatedByCountryCode,
    replyCreatedByImageUrl,
    replyApprovedImage,
    replyCreated,
    replyBirthDate,
    replyShowAge,
    replyImageReports,
  ];
}

class ChatMessageInclude extends _i1.IncludeObject {
  ChatMessageInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => ChatMessage.t;
}

class ChatMessageIncludeList extends _i1.IncludeList {
  ChatMessageIncludeList._({
    _i1.WhereExpressionBuilder<ChatMessageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatMessage.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => ChatMessage.t;
}

class ChatMessageRepository {
  const ChatMessageRepository._();

  /// Returns a list of [ChatMessage]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<ChatMessage>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatMessageTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatMessageTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ChatMessage>(
      where: where?.call(ChatMessage.t),
      orderBy: orderBy?.call(ChatMessage.t),
      orderByList: orderByList?.call(ChatMessage.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ChatMessage] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<ChatMessage?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatMessageTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatMessageTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ChatMessage>(
      where: where?.call(ChatMessage.t),
      orderBy: orderBy?.call(ChatMessage.t),
      orderByList: orderByList?.call(ChatMessage.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ChatMessage] by its [id] or null if no such row exists.
  Future<ChatMessage?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ChatMessage>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ChatMessage]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatMessage]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ChatMessage>> insert(
    _i1.DatabaseSession session,
    List<ChatMessage> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ChatMessage>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ChatMessage] and returns the inserted row.
  ///
  /// The returned [ChatMessage] will have its `id` field set.
  Future<ChatMessage> insertRow(
    _i1.DatabaseSession session,
    ChatMessage row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ChatMessage]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ChatMessage>> update(
    _i1.DatabaseSession session,
    List<ChatMessage> rows, {
    _i1.ColumnSelections<ChatMessageTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ChatMessage>(
      rows,
      columns: columns?.call(ChatMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatMessage]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatMessage> updateRow(
    _i1.DatabaseSession session,
    ChatMessage row, {
    _i1.ColumnSelections<ChatMessageTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatMessage>(
      row,
      columns: columns?.call(ChatMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatMessage] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChatMessage?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<ChatMessageUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ChatMessage>(
      id,
      columnValues: columnValues(ChatMessage.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChatMessage]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ChatMessage>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ChatMessageUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ChatMessageTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatMessageTable>? orderBy,
    _i1.OrderByListBuilder<ChatMessageTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ChatMessage>(
      columnValues: columnValues(ChatMessage.t.updateTable),
      where: where(ChatMessage.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatMessage.t),
      orderByList: orderByList?.call(ChatMessage.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ChatMessage]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ChatMessage>> delete(
    _i1.DatabaseSession session,
    List<ChatMessage> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ChatMessage>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ChatMessage].
  Future<ChatMessage> deleteRow(
    _i1.DatabaseSession session,
    ChatMessage row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ChatMessage>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatMessageTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ChatMessage>(
      where: where(ChatMessage.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatMessageTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ChatMessage>(
      where: where?.call(ChatMessage.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ChatMessage] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatMessageTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ChatMessage>(
      where: where(ChatMessage.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
