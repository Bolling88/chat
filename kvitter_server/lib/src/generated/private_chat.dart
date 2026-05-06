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

abstract class PrivateChat
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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

  static final t = PrivateChatTable();

  static const db = PrivateChatRepository._();

  @override
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

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static PrivateChatInclude include() {
    return PrivateChatInclude._();
  }

  static PrivateChatIncludeList includeList({
    _i1.WhereExpressionBuilder<PrivateChatTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PrivateChatTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PrivateChatTable>? orderByList,
    PrivateChatInclude? include,
  }) {
    return PrivateChatIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PrivateChat.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PrivateChat.t),
      include: include,
    );
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

class PrivateChatUpdateTable extends _i1.UpdateTable<PrivateChatTable> {
  PrivateChatUpdateTable(super.table);

  _i1.ColumnValue<List<String>, List<String>> users(List<String> value) =>
      _i1.ColumnValue(
        table.users,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> created(DateTime value) =>
      _i1.ColumnValue(
        table.created,
        value,
      );

  _i1.ColumnValue<String, String> initiatedBy(String value) => _i1.ColumnValue(
    table.initiatedBy,
    value,
  );

  _i1.ColumnValue<String, String> initiatedByUserName(String value) =>
      _i1.ColumnValue(
        table.initiatedByUserName,
        value,
      );

  _i1.ColumnValue<int, int> initiatedByUserGender(int value) => _i1.ColumnValue(
    table.initiatedByUserGender,
    value,
  );

  _i1.ColumnValue<String, String> initiatedByPictureData(String value) =>
      _i1.ColumnValue(
        table.initiatedByPictureData,
        value,
      );

  _i1.ColumnValue<String, String> chatName(String value) => _i1.ColumnValue(
    table.chatName,
    value,
  );

  _i1.ColumnValue<String, String> otherUserId(String value) => _i1.ColumnValue(
    table.otherUserId,
    value,
  );

  _i1.ColumnValue<String, String> otherUserName(String value) =>
      _i1.ColumnValue(
        table.otherUserName,
        value,
      );

  _i1.ColumnValue<int, int> otherUserGender(int value) => _i1.ColumnValue(
    table.otherUserGender,
    value,
  );

  _i1.ColumnValue<String, String> otherUserPictureData(String value) =>
      _i1.ColumnValue(
        table.otherUserPictureData,
        value,
      );

  _i1.ColumnValue<String, String> lastMessage(String value) => _i1.ColumnValue(
    table.lastMessage,
    value,
  );

  _i1.ColumnValue<bool, bool> lastMessageIsGiphy(bool value) => _i1.ColumnValue(
    table.lastMessageIsGiphy,
    value,
  );

  _i1.ColumnValue<String, String> lastMessageByName(String value) =>
      _i1.ColumnValue(
        table.lastMessageByName,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> lastMessageTimestamp(DateTime value) =>
      _i1.ColumnValue(
        table.lastMessageTimestamp,
        value,
      );

  _i1.ColumnValue<String, String> lastMessageUserId(String? value) =>
      _i1.ColumnValue(
        table.lastMessageUserId,
        value,
      );

  _i1.ColumnValue<List<String>, List<String>> lastMessageReadBy(
    List<String> value,
  ) => _i1.ColumnValue(
    table.lastMessageReadBy,
    value,
  );

  _i1.ColumnValue<String, String> sendPushToUserId(String? value) =>
      _i1.ColumnValue(
        table.sendPushToUserId,
        value,
      );
}

class PrivateChatTable extends _i1.Table<_i1.UuidValue?> {
  PrivateChatTable({super.tableRelation}) : super(tableName: 'private_chats') {
    updateTable = PrivateChatUpdateTable(this);
    users = _i1.ColumnSerializable<List<String>>(
      'users',
      this,
    );
    created = _i1.ColumnDateTime(
      'created',
      this,
    );
    initiatedBy = _i1.ColumnString(
      'initiatedBy',
      this,
    );
    initiatedByUserName = _i1.ColumnString(
      'initiatedByUserName',
      this,
    );
    initiatedByUserGender = _i1.ColumnInt(
      'initiatedByUserGender',
      this,
    );
    initiatedByPictureData = _i1.ColumnString(
      'initiatedByPictureData',
      this,
    );
    chatName = _i1.ColumnString(
      'chatName',
      this,
    );
    otherUserId = _i1.ColumnString(
      'otherUserId',
      this,
    );
    otherUserName = _i1.ColumnString(
      'otherUserName',
      this,
    );
    otherUserGender = _i1.ColumnInt(
      'otherUserGender',
      this,
    );
    otherUserPictureData = _i1.ColumnString(
      'otherUserPictureData',
      this,
    );
    lastMessage = _i1.ColumnString(
      'lastMessage',
      this,
    );
    lastMessageIsGiphy = _i1.ColumnBool(
      'lastMessageIsGiphy',
      this,
    );
    lastMessageByName = _i1.ColumnString(
      'lastMessageByName',
      this,
    );
    lastMessageTimestamp = _i1.ColumnDateTime(
      'lastMessageTimestamp',
      this,
    );
    lastMessageUserId = _i1.ColumnString(
      'lastMessageUserId',
      this,
    );
    lastMessageReadBy = _i1.ColumnSerializable<List<String>>(
      'lastMessageReadBy',
      this,
    );
    sendPushToUserId = _i1.ColumnString(
      'sendPushToUserId',
      this,
    );
  }

  late final PrivateChatUpdateTable updateTable;

  late final _i1.ColumnSerializable<List<String>> users;

  late final _i1.ColumnDateTime created;

  late final _i1.ColumnString initiatedBy;

  late final _i1.ColumnString initiatedByUserName;

  late final _i1.ColumnInt initiatedByUserGender;

  late final _i1.ColumnString initiatedByPictureData;

  late final _i1.ColumnString chatName;

  late final _i1.ColumnString otherUserId;

  late final _i1.ColumnString otherUserName;

  late final _i1.ColumnInt otherUserGender;

  late final _i1.ColumnString otherUserPictureData;

  late final _i1.ColumnString lastMessage;

  late final _i1.ColumnBool lastMessageIsGiphy;

  late final _i1.ColumnString lastMessageByName;

  late final _i1.ColumnDateTime lastMessageTimestamp;

  late final _i1.ColumnString lastMessageUserId;

  late final _i1.ColumnSerializable<List<String>> lastMessageReadBy;

  late final _i1.ColumnString sendPushToUserId;

  @override
  List<_i1.Column> get columns => [
    id,
    users,
    created,
    initiatedBy,
    initiatedByUserName,
    initiatedByUserGender,
    initiatedByPictureData,
    chatName,
    otherUserId,
    otherUserName,
    otherUserGender,
    otherUserPictureData,
    lastMessage,
    lastMessageIsGiphy,
    lastMessageByName,
    lastMessageTimestamp,
    lastMessageUserId,
    lastMessageReadBy,
    sendPushToUserId,
  ];
}

class PrivateChatInclude extends _i1.IncludeObject {
  PrivateChatInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => PrivateChat.t;
}

class PrivateChatIncludeList extends _i1.IncludeList {
  PrivateChatIncludeList._({
    _i1.WhereExpressionBuilder<PrivateChatTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PrivateChat.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => PrivateChat.t;
}

class PrivateChatRepository {
  const PrivateChatRepository._();

  /// Returns a list of [PrivateChat]s matching the given query parameters.
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
  Future<List<PrivateChat>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PrivateChatTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PrivateChatTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PrivateChatTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PrivateChat>(
      where: where?.call(PrivateChat.t),
      orderBy: orderBy?.call(PrivateChat.t),
      orderByList: orderByList?.call(PrivateChat.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PrivateChat] matching the given query parameters.
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
  Future<PrivateChat?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PrivateChatTable>? where,
    int? offset,
    _i1.OrderByBuilder<PrivateChatTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PrivateChatTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PrivateChat>(
      where: where?.call(PrivateChat.t),
      orderBy: orderBy?.call(PrivateChat.t),
      orderByList: orderByList?.call(PrivateChat.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PrivateChat] by its [id] or null if no such row exists.
  Future<PrivateChat?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PrivateChat>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PrivateChat]s in the list and returns the inserted rows.
  ///
  /// The returned [PrivateChat]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PrivateChat>> insert(
    _i1.DatabaseSession session,
    List<PrivateChat> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PrivateChat>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PrivateChat] and returns the inserted row.
  ///
  /// The returned [PrivateChat] will have its `id` field set.
  Future<PrivateChat> insertRow(
    _i1.DatabaseSession session,
    PrivateChat row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PrivateChat>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PrivateChat]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PrivateChat>> update(
    _i1.DatabaseSession session,
    List<PrivateChat> rows, {
    _i1.ColumnSelections<PrivateChatTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PrivateChat>(
      rows,
      columns: columns?.call(PrivateChat.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PrivateChat]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PrivateChat> updateRow(
    _i1.DatabaseSession session,
    PrivateChat row, {
    _i1.ColumnSelections<PrivateChatTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PrivateChat>(
      row,
      columns: columns?.call(PrivateChat.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PrivateChat] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PrivateChat?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PrivateChatUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PrivateChat>(
      id,
      columnValues: columnValues(PrivateChat.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PrivateChat]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PrivateChat>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PrivateChatUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PrivateChatTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PrivateChatTable>? orderBy,
    _i1.OrderByListBuilder<PrivateChatTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PrivateChat>(
      columnValues: columnValues(PrivateChat.t.updateTable),
      where: where(PrivateChat.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PrivateChat.t),
      orderByList: orderByList?.call(PrivateChat.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PrivateChat]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PrivateChat>> delete(
    _i1.DatabaseSession session,
    List<PrivateChat> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PrivateChat>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PrivateChat].
  Future<PrivateChat> deleteRow(
    _i1.DatabaseSession session,
    PrivateChat row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PrivateChat>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PrivateChat>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PrivateChatTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PrivateChat>(
      where: where(PrivateChat.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PrivateChatTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PrivateChat>(
      where: where?.call(PrivateChat.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PrivateChat] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PrivateChatTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PrivateChat>(
      where: where(PrivateChat.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
