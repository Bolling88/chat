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

abstract class UserFeedback implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String feedback;

  String createdById;

  String createdByName;

  String createdByCountryCode;

  String createdByCountryName;

  DateTime created;

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
