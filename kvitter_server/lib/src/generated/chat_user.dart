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

abstract class ChatUser
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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

  static final t = ChatUserTable();

  static const db = ChatUserRepository._();

  @override
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

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static ChatUserInclude include() {
    return ChatUserInclude._();
  }

  static ChatUserIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatUserTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatUserTable>? orderByList,
    ChatUserInclude? include,
  }) {
    return ChatUserIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatUser.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ChatUser.t),
      include: include,
    );
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

class ChatUserUpdateTable extends _i1.UpdateTable<ChatUserTable> {
  ChatUserUpdateTable(super.table);

  _i1.ColumnValue<String, String> authUserIdentifier(String value) =>
      _i1.ColumnValue(
        table.authUserIdentifier,
        value,
      );

  _i1.ColumnValue<String, String> email(String value) => _i1.ColumnValue(
    table.email,
    value,
  );

  _i1.ColumnValue<String, String> displayName(String value) => _i1.ColumnValue(
    table.displayName,
    value,
  );

  _i1.ColumnValue<int, int> gender(int value) => _i1.ColumnValue(
    table.gender,
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

  _i1.ColumnValue<String, String> pictureData(String value) => _i1.ColumnValue(
    table.pictureData,
    value,
  );

  _i1.ColumnValue<int, int> approvedImage(int value) => _i1.ColumnValue(
    table.approvedImage,
    value,
  );

  _i1.ColumnValue<String, String> city(String value) => _i1.ColumnValue(
    table.city,
    value,
  );

  _i1.ColumnValue<String, String> countryCode(String value) => _i1.ColumnValue(
    table.countryCode,
    value,
  );

  _i1.ColumnValue<String, String> country(String value) => _i1.ColumnValue(
    table.country,
    value,
  );

  _i1.ColumnValue<String, String> regionName(String value) => _i1.ColumnValue(
    table.regionName,
    value,
  );

  _i1.ColumnValue<bool, bool> presence(bool value) => _i1.ColumnValue(
    table.presence,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> lastActive(DateTime value) =>
      _i1.ColumnValue(
        table.lastActive,
        value,
      );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> currentRoomChatId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.currentRoomChatId,
    value,
  );

  _i1.ColumnValue<String, String> fcmToken(String value) => _i1.ColumnValue(
    table.fcmToken,
    value,
  );

  _i1.ColumnValue<List<String>, List<String>> blockedBy(List<String> value) =>
      _i1.ColumnValue(
        table.blockedBy,
        value,
      );

  _i1.ColumnValue<List<String>, List<String>> imageReports(
    List<String> value,
  ) => _i1.ColumnValue(
    table.imageReports,
    value,
  );

  _i1.ColumnValue<List<String>, List<String>> botReports(List<String> value) =>
      _i1.ColumnValue(
        table.botReports,
        value,
      );

  _i1.ColumnValue<List<String>, List<String>> languageReports(
    List<String> value,
  ) => _i1.ColumnValue(
    table.languageReports,
    value,
  );

  _i1.ColumnValue<int, int> kvitterCredits(int value) => _i1.ColumnValue(
    table.kvitterCredits,
    value,
  );

  _i1.ColumnValue<bool, bool> isPremiumUser(bool value) => _i1.ColumnValue(
    table.isPremiumUser,
    value,
  );

  _i1.ColumnValue<bool, bool> onboardingCompleted(bool value) =>
      _i1.ColumnValue(
        table.onboardingCompleted,
        value,
      );

  _i1.ColumnValue<bool, bool> isAdmin(bool value) => _i1.ColumnValue(
    table.isAdmin,
    value,
  );

  _i1.ColumnValue<List<String>, List<String>> searchArray(List<String> value) =>
      _i1.ColumnValue(
        table.searchArray,
        value,
      );
}

class ChatUserTable extends _i1.Table<_i1.UuidValue?> {
  ChatUserTable({super.tableRelation}) : super(tableName: 'chat_users') {
    updateTable = ChatUserUpdateTable(this);
    authUserIdentifier = _i1.ColumnString(
      'authUserIdentifier',
      this,
    );
    email = _i1.ColumnString(
      'email',
      this,
    );
    displayName = _i1.ColumnString(
      'displayName',
      this,
    );
    gender = _i1.ColumnInt(
      'gender',
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
    pictureData = _i1.ColumnString(
      'pictureData',
      this,
    );
    approvedImage = _i1.ColumnInt(
      'approvedImage',
      this,
    );
    city = _i1.ColumnString(
      'city',
      this,
    );
    countryCode = _i1.ColumnString(
      'countryCode',
      this,
    );
    country = _i1.ColumnString(
      'country',
      this,
    );
    regionName = _i1.ColumnString(
      'regionName',
      this,
    );
    presence = _i1.ColumnBool(
      'presence',
      this,
    );
    lastActive = _i1.ColumnDateTime(
      'lastActive',
      this,
    );
    currentRoomChatId = _i1.ColumnUuid(
      'currentRoomChatId',
      this,
    );
    fcmToken = _i1.ColumnString(
      'fcmToken',
      this,
    );
    blockedBy = _i1.ColumnSerializable<List<String>>(
      'blockedBy',
      this,
    );
    imageReports = _i1.ColumnSerializable<List<String>>(
      'imageReports',
      this,
    );
    botReports = _i1.ColumnSerializable<List<String>>(
      'botReports',
      this,
    );
    languageReports = _i1.ColumnSerializable<List<String>>(
      'languageReports',
      this,
    );
    kvitterCredits = _i1.ColumnInt(
      'kvitterCredits',
      this,
    );
    isPremiumUser = _i1.ColumnBool(
      'isPremiumUser',
      this,
    );
    onboardingCompleted = _i1.ColumnBool(
      'onboardingCompleted',
      this,
    );
    isAdmin = _i1.ColumnBool(
      'isAdmin',
      this,
    );
    searchArray = _i1.ColumnSerializable<List<String>>(
      'searchArray',
      this,
    );
  }

  late final ChatUserUpdateTable updateTable;

  late final _i1.ColumnString authUserIdentifier;

  late final _i1.ColumnString email;

  late final _i1.ColumnString displayName;

  late final _i1.ColumnInt gender;

  late final _i1.ColumnDateTime birthDate;

  late final _i1.ColumnBool showAge;

  late final _i1.ColumnString pictureData;

  late final _i1.ColumnInt approvedImage;

  late final _i1.ColumnString city;

  late final _i1.ColumnString countryCode;

  late final _i1.ColumnString country;

  late final _i1.ColumnString regionName;

  late final _i1.ColumnBool presence;

  late final _i1.ColumnDateTime lastActive;

  late final _i1.ColumnUuid currentRoomChatId;

  late final _i1.ColumnString fcmToken;

  late final _i1.ColumnSerializable<List<String>> blockedBy;

  late final _i1.ColumnSerializable<List<String>> imageReports;

  late final _i1.ColumnSerializable<List<String>> botReports;

  late final _i1.ColumnSerializable<List<String>> languageReports;

  late final _i1.ColumnInt kvitterCredits;

  late final _i1.ColumnBool isPremiumUser;

  late final _i1.ColumnBool onboardingCompleted;

  late final _i1.ColumnBool isAdmin;

  late final _i1.ColumnSerializable<List<String>> searchArray;

  @override
  List<_i1.Column> get columns => [
    id,
    authUserIdentifier,
    email,
    displayName,
    gender,
    birthDate,
    showAge,
    pictureData,
    approvedImage,
    city,
    countryCode,
    country,
    regionName,
    presence,
    lastActive,
    currentRoomChatId,
    fcmToken,
    blockedBy,
    imageReports,
    botReports,
    languageReports,
    kvitterCredits,
    isPremiumUser,
    onboardingCompleted,
    isAdmin,
    searchArray,
  ];
}

class ChatUserInclude extends _i1.IncludeObject {
  ChatUserInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => ChatUser.t;
}

class ChatUserIncludeList extends _i1.IncludeList {
  ChatUserIncludeList._({
    _i1.WhereExpressionBuilder<ChatUserTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatUser.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => ChatUser.t;
}

class ChatUserRepository {
  const ChatUserRepository._();

  /// Returns a list of [ChatUser]s matching the given query parameters.
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
  Future<List<ChatUser>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatUserTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatUserTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ChatUser>(
      where: where?.call(ChatUser.t),
      orderBy: orderBy?.call(ChatUser.t),
      orderByList: orderByList?.call(ChatUser.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ChatUser] matching the given query parameters.
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
  Future<ChatUser?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatUserTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatUserTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ChatUser>(
      where: where?.call(ChatUser.t),
      orderBy: orderBy?.call(ChatUser.t),
      orderByList: orderByList?.call(ChatUser.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ChatUser] by its [id] or null if no such row exists.
  Future<ChatUser?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ChatUser>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ChatUser]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatUser]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ChatUser>> insert(
    _i1.DatabaseSession session,
    List<ChatUser> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ChatUser>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ChatUser] and returns the inserted row.
  ///
  /// The returned [ChatUser] will have its `id` field set.
  Future<ChatUser> insertRow(
    _i1.DatabaseSession session,
    ChatUser row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatUser>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ChatUser]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ChatUser>> update(
    _i1.DatabaseSession session,
    List<ChatUser> rows, {
    _i1.ColumnSelections<ChatUserTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ChatUser>(
      rows,
      columns: columns?.call(ChatUser.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatUser]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatUser> updateRow(
    _i1.DatabaseSession session,
    ChatUser row, {
    _i1.ColumnSelections<ChatUserTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatUser>(
      row,
      columns: columns?.call(ChatUser.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatUser] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChatUser?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<ChatUserUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ChatUser>(
      id,
      columnValues: columnValues(ChatUser.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChatUser]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ChatUser>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ChatUserUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ChatUserTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatUserTable>? orderBy,
    _i1.OrderByListBuilder<ChatUserTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ChatUser>(
      columnValues: columnValues(ChatUser.t.updateTable),
      where: where(ChatUser.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatUser.t),
      orderByList: orderByList?.call(ChatUser.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ChatUser]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ChatUser>> delete(
    _i1.DatabaseSession session,
    List<ChatUser> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ChatUser>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ChatUser].
  Future<ChatUser> deleteRow(
    _i1.DatabaseSession session,
    ChatUser row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatUser>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ChatUser>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatUserTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ChatUser>(
      where: where(ChatUser.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ChatUserTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ChatUser>(
      where: where?.call(ChatUser.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ChatUser] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ChatUserTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ChatUser>(
      where: where(ChatUser.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
