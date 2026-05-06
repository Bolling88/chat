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

abstract class Report implements _i1.SerializableModel {
  Report._({
    this.id,
    required this.messageId,
    required this.messageText,
    required this.messageCreated,
    required this.messageCreatedBy,
    required this.messageCreatedByGender,
    required this.messageCreatedByCountryCode,
    required this.messageCreatedByImageUrl,
    required this.messageCreatedByDisplayName,
    required this.reportedBy,
    required this.reportedAt,
  });

  factory Report({
    _i1.UuidValue? id,
    required String messageId,
    required String messageText,
    required DateTime messageCreated,
    required String messageCreatedBy,
    required int messageCreatedByGender,
    required String messageCreatedByCountryCode,
    required String messageCreatedByImageUrl,
    required String messageCreatedByDisplayName,
    required String reportedBy,
    required DateTime reportedAt,
  }) = _ReportImpl;

  factory Report.fromJson(Map<String, dynamic> jsonSerialization) {
    return Report(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      messageId: jsonSerialization['messageId'] as String,
      messageText: jsonSerialization['messageText'] as String,
      messageCreated: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['messageCreated'],
      ),
      messageCreatedBy: jsonSerialization['messageCreatedBy'] as String,
      messageCreatedByGender:
          jsonSerialization['messageCreatedByGender'] as int,
      messageCreatedByCountryCode:
          jsonSerialization['messageCreatedByCountryCode'] as String,
      messageCreatedByImageUrl:
          jsonSerialization['messageCreatedByImageUrl'] as String,
      messageCreatedByDisplayName:
          jsonSerialization['messageCreatedByDisplayName'] as String,
      reportedBy: jsonSerialization['reportedBy'] as String,
      reportedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['reportedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String messageId;

  String messageText;

  DateTime messageCreated;

  String messageCreatedBy;

  int messageCreatedByGender;

  String messageCreatedByCountryCode;

  String messageCreatedByImageUrl;

  String messageCreatedByDisplayName;

  String reportedBy;

  DateTime reportedAt;

  /// Returns a shallow copy of this [Report]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Report copyWith({
    _i1.UuidValue? id,
    String? messageId,
    String? messageText,
    DateTime? messageCreated,
    String? messageCreatedBy,
    int? messageCreatedByGender,
    String? messageCreatedByCountryCode,
    String? messageCreatedByImageUrl,
    String? messageCreatedByDisplayName,
    String? reportedBy,
    DateTime? reportedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Report',
      if (id != null) 'id': id?.toJson(),
      'messageId': messageId,
      'messageText': messageText,
      'messageCreated': messageCreated.toJson(),
      'messageCreatedBy': messageCreatedBy,
      'messageCreatedByGender': messageCreatedByGender,
      'messageCreatedByCountryCode': messageCreatedByCountryCode,
      'messageCreatedByImageUrl': messageCreatedByImageUrl,
      'messageCreatedByDisplayName': messageCreatedByDisplayName,
      'reportedBy': reportedBy,
      'reportedAt': reportedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReportImpl extends Report {
  _ReportImpl({
    _i1.UuidValue? id,
    required String messageId,
    required String messageText,
    required DateTime messageCreated,
    required String messageCreatedBy,
    required int messageCreatedByGender,
    required String messageCreatedByCountryCode,
    required String messageCreatedByImageUrl,
    required String messageCreatedByDisplayName,
    required String reportedBy,
    required DateTime reportedAt,
  }) : super._(
         id: id,
         messageId: messageId,
         messageText: messageText,
         messageCreated: messageCreated,
         messageCreatedBy: messageCreatedBy,
         messageCreatedByGender: messageCreatedByGender,
         messageCreatedByCountryCode: messageCreatedByCountryCode,
         messageCreatedByImageUrl: messageCreatedByImageUrl,
         messageCreatedByDisplayName: messageCreatedByDisplayName,
         reportedBy: reportedBy,
         reportedAt: reportedAt,
       );

  /// Returns a shallow copy of this [Report]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Report copyWith({
    Object? id = _Undefined,
    String? messageId,
    String? messageText,
    DateTime? messageCreated,
    String? messageCreatedBy,
    int? messageCreatedByGender,
    String? messageCreatedByCountryCode,
    String? messageCreatedByImageUrl,
    String? messageCreatedByDisplayName,
    String? reportedBy,
    DateTime? reportedAt,
  }) {
    return Report(
      id: id is _i1.UuidValue? ? id : this.id,
      messageId: messageId ?? this.messageId,
      messageText: messageText ?? this.messageText,
      messageCreated: messageCreated ?? this.messageCreated,
      messageCreatedBy: messageCreatedBy ?? this.messageCreatedBy,
      messageCreatedByGender:
          messageCreatedByGender ?? this.messageCreatedByGender,
      messageCreatedByCountryCode:
          messageCreatedByCountryCode ?? this.messageCreatedByCountryCode,
      messageCreatedByImageUrl:
          messageCreatedByImageUrl ?? this.messageCreatedByImageUrl,
      messageCreatedByDisplayName:
          messageCreatedByDisplayName ?? this.messageCreatedByDisplayName,
      reportedBy: reportedBy ?? this.reportedBy,
      reportedAt: reportedAt ?? this.reportedAt,
    );
  }
}
