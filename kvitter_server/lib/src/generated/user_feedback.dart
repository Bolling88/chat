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

abstract class UserFeedback
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  UserFeedback._({
    this.id,
    required this.feedback,
    required this.createdById,
    required this.createdByName,
    required this.createdByCountryCode,
    required this.createdByCountryName,
    required this.created,
  });

  factory UserFeedback({
    _i1.UuidValue? id,
    required String feedback,
    required String createdById,
    required String createdByName,
    required String createdByCountryCode,
    required String createdByCountryName,
    required DateTime created,
  }) = _UserFeedbackImpl;

  factory UserFeedback.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserFeedback(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      feedback: jsonSerialization['feedback'] as String,
      createdById: jsonSerialization['createdById'] as String,
      createdByName: jsonSerialization['createdByName'] as String,
      createdByCountryCode: jsonSerialization['createdByCountryCode'] as String,
      createdByCountryName: jsonSerialization['createdByCountryName'] as String,
      created: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['created']),
    );
  }

  static final t = UserFeedbackTable();

  static const db = UserFeedbackRepository._();

  @override
  _i1.UuidValue? id;

  String feedback;

  String createdById;

  String createdByName;

  String createdByCountryCode;

  String createdByCountryName;

  DateTime created;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [UserFeedback]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserFeedback copyWith({
    _i1.UuidValue? id,
    String? feedback,
    String? createdById,
    String? createdByName,
    String? createdByCountryCode,
    String? createdByCountryName,
    DateTime? created,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserFeedback',
      if (id != null) 'id': id?.toJson(),
      'feedback': feedback,
      'createdById': createdById,
      'createdByName': createdByName,
      'createdByCountryCode': createdByCountryCode,
      'createdByCountryName': createdByCountryName,
      'created': created.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserFeedback',
      if (id != null) 'id': id?.toJson(),
      'feedback': feedback,
      'createdById': createdById,
      'createdByName': createdByName,
      'createdByCountryCode': createdByCountryCode,
      'createdByCountryName': createdByCountryName,
      'created': created.toJson(),
    };
  }

  static UserFeedbackInclude include() {
    return UserFeedbackInclude._();
  }

  static UserFeedbackIncludeList includeList({
    _i1.WhereExpressionBuilder<UserFeedbackTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserFeedbackTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserFeedbackTable>? orderByList,
    UserFeedbackInclude? include,
  }) {
    return UserFeedbackIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserFeedback.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserFeedback.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserFeedbackImpl extends UserFeedback {
  _UserFeedbackImpl({
    _i1.UuidValue? id,
    required String feedback,
    required String createdById,
    required String createdByName,
    required String createdByCountryCode,
    required String createdByCountryName,
    required DateTime created,
  }) : super._(
         id: id,
         feedback: feedback,
         createdById: createdById,
         createdByName: createdByName,
         createdByCountryCode: createdByCountryCode,
         createdByCountryName: createdByCountryName,
         created: created,
       );

  /// Returns a shallow copy of this [UserFeedback]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserFeedback copyWith({
    Object? id = _Undefined,
    String? feedback,
    String? createdById,
    String? createdByName,
    String? createdByCountryCode,
    String? createdByCountryName,
    DateTime? created,
  }) {
    return UserFeedback(
      id: id is _i1.UuidValue? ? id : this.id,
      feedback: feedback ?? this.feedback,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      createdByCountryCode: createdByCountryCode ?? this.createdByCountryCode,
      createdByCountryName: createdByCountryName ?? this.createdByCountryName,
      created: created ?? this.created,
    );
  }
}

class UserFeedbackUpdateTable extends _i1.UpdateTable<UserFeedbackTable> {
  UserFeedbackUpdateTable(super.table);

  _i1.ColumnValue<String, String> feedback(String value) => _i1.ColumnValue(
    table.feedback,
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

  _i1.ColumnValue<String, String> createdByCountryCode(String value) =>
      _i1.ColumnValue(
        table.createdByCountryCode,
        value,
      );

  _i1.ColumnValue<String, String> createdByCountryName(String value) =>
      _i1.ColumnValue(
        table.createdByCountryName,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> created(DateTime value) =>
      _i1.ColumnValue(
        table.created,
        value,
      );
}

class UserFeedbackTable extends _i1.Table<_i1.UuidValue?> {
  UserFeedbackTable({super.tableRelation})
    : super(tableName: 'user_feedbacks') {
    updateTable = UserFeedbackUpdateTable(this);
    feedback = _i1.ColumnString(
      'feedback',
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
    createdByCountryCode = _i1.ColumnString(
      'createdByCountryCode',
      this,
    );
    createdByCountryName = _i1.ColumnString(
      'createdByCountryName',
      this,
    );
    created = _i1.ColumnDateTime(
      'created',
      this,
    );
  }

  late final UserFeedbackUpdateTable updateTable;

  late final _i1.ColumnString feedback;

  late final _i1.ColumnString createdById;

  late final _i1.ColumnString createdByName;

  late final _i1.ColumnString createdByCountryCode;

  late final _i1.ColumnString createdByCountryName;

  late final _i1.ColumnDateTime created;

  @override
  List<_i1.Column> get columns => [
    id,
    feedback,
    createdById,
    createdByName,
    createdByCountryCode,
    createdByCountryName,
    created,
  ];
}

class UserFeedbackInclude extends _i1.IncludeObject {
  UserFeedbackInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => UserFeedback.t;
}

class UserFeedbackIncludeList extends _i1.IncludeList {
  UserFeedbackIncludeList._({
    _i1.WhereExpressionBuilder<UserFeedbackTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserFeedback.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => UserFeedback.t;
}

class UserFeedbackRepository {
  const UserFeedbackRepository._();

  /// Returns a list of [UserFeedback]s matching the given query parameters.
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
  Future<List<UserFeedback>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserFeedbackTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserFeedbackTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserFeedbackTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UserFeedback>(
      where: where?.call(UserFeedback.t),
      orderBy: orderBy?.call(UserFeedback.t),
      orderByList: orderByList?.call(UserFeedback.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [UserFeedback] matching the given query parameters.
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
  Future<UserFeedback?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserFeedbackTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserFeedbackTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserFeedbackTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UserFeedback>(
      where: where?.call(UserFeedback.t),
      orderBy: orderBy?.call(UserFeedback.t),
      orderByList: orderByList?.call(UserFeedback.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UserFeedback] by its [id] or null if no such row exists.
  Future<UserFeedback?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UserFeedback>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UserFeedback]s in the list and returns the inserted rows.
  ///
  /// The returned [UserFeedback]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<UserFeedback>> insert(
    _i1.DatabaseSession session,
    List<UserFeedback> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<UserFeedback>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [UserFeedback] and returns the inserted row.
  ///
  /// The returned [UserFeedback] will have its `id` field set.
  Future<UserFeedback> insertRow(
    _i1.DatabaseSession session,
    UserFeedback row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserFeedback>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserFeedback]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserFeedback>> update(
    _i1.DatabaseSession session,
    List<UserFeedback> rows, {
    _i1.ColumnSelections<UserFeedbackTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserFeedback>(
      rows,
      columns: columns?.call(UserFeedback.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserFeedback]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserFeedback> updateRow(
    _i1.DatabaseSession session,
    UserFeedback row, {
    _i1.ColumnSelections<UserFeedbackTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserFeedback>(
      row,
      columns: columns?.call(UserFeedback.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserFeedback] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserFeedback?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<UserFeedbackUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserFeedback>(
      id,
      columnValues: columnValues(UserFeedback.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserFeedback]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserFeedback>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<UserFeedbackUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<UserFeedbackTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserFeedbackTable>? orderBy,
    _i1.OrderByListBuilder<UserFeedbackTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserFeedback>(
      columnValues: columnValues(UserFeedback.t.updateTable),
      where: where(UserFeedback.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserFeedback.t),
      orderByList: orderByList?.call(UserFeedback.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserFeedback]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserFeedback>> delete(
    _i1.DatabaseSession session,
    List<UserFeedback> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserFeedback>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserFeedback].
  Future<UserFeedback> deleteRow(
    _i1.DatabaseSession session,
    UserFeedback row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserFeedback>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserFeedback>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserFeedbackTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserFeedback>(
      where: where(UserFeedback.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserFeedbackTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserFeedback>(
      where: where?.call(UserFeedback.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UserFeedback] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserFeedbackTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UserFeedback>(
      where: where(UserFeedback.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
