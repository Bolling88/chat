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

abstract class RoomChat
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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

  static final t = RoomChatTable();

  static const db = RoomChatRepository._();

  @override
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

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static RoomChatInclude include() {
    return RoomChatInclude._();
  }

  static RoomChatIncludeList includeList({
    _i1.WhereExpressionBuilder<RoomChatTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RoomChatTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RoomChatTable>? orderByList,
    RoomChatInclude? include,
  }) {
    return RoomChatIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RoomChat.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(RoomChat.t),
      include: include,
    );
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

class RoomChatUpdateTable extends _i1.UpdateTable<RoomChatTable> {
  RoomChatUpdateTable(super.table);

  _i1.ColumnValue<String, String> chatName(String value) => _i1.ColumnValue(
    table.chatName,
    value,
  );

  _i1.ColumnValue<int, int> chatColor(int value) => _i1.ColumnValue(
    table.chatColor,
    value,
  );

  _i1.ColumnValue<String, String> imageUrl(String value) => _i1.ColumnValue(
    table.imageUrl,
    value,
  );

  _i1.ColumnValue<String, String> countryCode(String value) => _i1.ColumnValue(
    table.countryCode,
    value,
  );

  _i1.ColumnValue<bool, bool> enabled(bool value) => _i1.ColumnValue(
    table.enabled,
    value,
  );

  _i1.ColumnValue<String, String> infoKey(String value) => _i1.ColumnValue(
    table.infoKey,
    value,
  );

  _i1.ColumnValue<int, int> imageOverflow(int value) => _i1.ColumnValue(
    table.imageOverflow,
    value,
  );

  _i1.ColumnValue<int, int> imageTranslationX(int value) => _i1.ColumnValue(
    table.imageTranslationX,
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

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> lastMessageUserId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.lastMessageUserId,
    value,
  );
}

class RoomChatTable extends _i1.Table<_i1.UuidValue?> {
  RoomChatTable({super.tableRelation}) : super(tableName: 'room_chats') {
    updateTable = RoomChatUpdateTable(this);
    chatName = _i1.ColumnString(
      'chatName',
      this,
    );
    chatColor = _i1.ColumnInt(
      'chatColor',
      this,
    );
    imageUrl = _i1.ColumnString(
      'imageUrl',
      this,
    );
    countryCode = _i1.ColumnString(
      'countryCode',
      this,
    );
    enabled = _i1.ColumnBool(
      'enabled',
      this,
    );
    infoKey = _i1.ColumnString(
      'infoKey',
      this,
    );
    imageOverflow = _i1.ColumnInt(
      'imageOverflow',
      this,
    );
    imageTranslationX = _i1.ColumnInt(
      'imageTranslationX',
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
    lastMessageUserId = _i1.ColumnUuid(
      'lastMessageUserId',
      this,
    );
  }

  late final RoomChatUpdateTable updateTable;

  late final _i1.ColumnString chatName;

  late final _i1.ColumnInt chatColor;

  late final _i1.ColumnString imageUrl;

  late final _i1.ColumnString countryCode;

  late final _i1.ColumnBool enabled;

  late final _i1.ColumnString infoKey;

  late final _i1.ColumnInt imageOverflow;

  late final _i1.ColumnInt imageTranslationX;

  late final _i1.ColumnString lastMessage;

  late final _i1.ColumnBool lastMessageIsGiphy;

  late final _i1.ColumnString lastMessageByName;

  late final _i1.ColumnDateTime lastMessageTimestamp;

  late final _i1.ColumnUuid lastMessageUserId;

  @override
  List<_i1.Column> get columns => [
    id,
    chatName,
    chatColor,
    imageUrl,
    countryCode,
    enabled,
    infoKey,
    imageOverflow,
    imageTranslationX,
    lastMessage,
    lastMessageIsGiphy,
    lastMessageByName,
    lastMessageTimestamp,
    lastMessageUserId,
  ];
}

class RoomChatInclude extends _i1.IncludeObject {
  RoomChatInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => RoomChat.t;
}

class RoomChatIncludeList extends _i1.IncludeList {
  RoomChatIncludeList._({
    _i1.WhereExpressionBuilder<RoomChatTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RoomChat.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => RoomChat.t;
}

class RoomChatRepository {
  const RoomChatRepository._();

  /// Returns a list of [RoomChat]s matching the given query parameters.
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
  Future<List<RoomChat>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<RoomChatTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RoomChatTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RoomChatTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RoomChat>(
      where: where?.call(RoomChat.t),
      orderBy: orderBy?.call(RoomChat.t),
      orderByList: orderByList?.call(RoomChat.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RoomChat] matching the given query parameters.
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
  Future<RoomChat?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<RoomChatTable>? where,
    int? offset,
    _i1.OrderByBuilder<RoomChatTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RoomChatTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RoomChat>(
      where: where?.call(RoomChat.t),
      orderBy: orderBy?.call(RoomChat.t),
      orderByList: orderByList?.call(RoomChat.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RoomChat] by its [id] or null if no such row exists.
  Future<RoomChat?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RoomChat>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RoomChat]s in the list and returns the inserted rows.
  ///
  /// The returned [RoomChat]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<RoomChat>> insert(
    _i1.DatabaseSession session,
    List<RoomChat> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<RoomChat>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [RoomChat] and returns the inserted row.
  ///
  /// The returned [RoomChat] will have its `id` field set.
  Future<RoomChat> insertRow(
    _i1.DatabaseSession session,
    RoomChat row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<RoomChat>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [RoomChat]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<RoomChat>> update(
    _i1.DatabaseSession session,
    List<RoomChat> rows, {
    _i1.ColumnSelections<RoomChatTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<RoomChat>(
      rows,
      columns: columns?.call(RoomChat.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RoomChat]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RoomChat> updateRow(
    _i1.DatabaseSession session,
    RoomChat row, {
    _i1.ColumnSelections<RoomChatTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<RoomChat>(
      row,
      columns: columns?.call(RoomChat.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RoomChat] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RoomChat?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<RoomChatUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<RoomChat>(
      id,
      columnValues: columnValues(RoomChat.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RoomChat]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<RoomChat>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<RoomChatUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<RoomChatTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RoomChatTable>? orderBy,
    _i1.OrderByListBuilder<RoomChatTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<RoomChat>(
      columnValues: columnValues(RoomChat.t.updateTable),
      where: where(RoomChat.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RoomChat.t),
      orderByList: orderByList?.call(RoomChat.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [RoomChat]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<RoomChat>> delete(
    _i1.DatabaseSession session,
    List<RoomChat> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<RoomChat>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [RoomChat].
  Future<RoomChat> deleteRow(
    _i1.DatabaseSession session,
    RoomChat row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RoomChat>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<RoomChat>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<RoomChatTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<RoomChat>(
      where: where(RoomChat.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<RoomChatTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<RoomChat>(
      where: where?.call(RoomChat.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RoomChat] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<RoomChatTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RoomChat>(
      where: where(RoomChat.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
