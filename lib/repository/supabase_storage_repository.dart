import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:universal_io/io.dart';

import '../utils/auth_util.dart';
import '../utils/log.dart';

class SupabaseStorageRepository {
  final SupabaseClient _client = Supabase.instance.client;

  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String _getRandomString(int length) => String.fromCharCodes(
      Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<String?> uploadProfileImage(String filePath, String base64Image) async {
    final userId = getUserId();
    final path = '$userId.png';

    try {
      if (kIsWeb) {
        await _client.storage.from('avatars').uploadBinary(
          path,
          base64.decode(base64Image),
          fileOptions: const FileOptions(upsert: true, contentType: 'image/png'),
        );
      } else {
        await _client.storage.from('avatars').upload(
          path,
          File(filePath),
          fileOptions: const FileOptions(upsert: true, contentType: 'image/png'),
        );
      }
      return _client.storage.from('avatars').getPublicUrl(path);
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  Future<String?> uploadMessageImage(String filePath, String base64Image) async {
    final fileName = _getRandomString(20);
    final path = '$fileName.png';

    try {
      if (kIsWeb) {
        await _client.storage.from('chat-images').uploadBinary(
          path,
          base64.decode(base64Image),
          fileOptions: const FileOptions(contentType: 'image/png'),
        );
      } else {
        await _client.storage.from('chat-images').upload(
          path,
          File(filePath),
          fileOptions: const FileOptions(contentType: 'image/png'),
        );
      }
      return _client.storage.from('chat-images').getPublicUrl(path);
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  Future<void> deleteImage(String publicUrl) async {
    try {
      final uri = Uri.parse(publicUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf('avatars') != -1
          ? pathSegments.indexOf('avatars')
          : pathSegments.indexOf('chat-images');
      if (bucketIndex == -1) return;
      final bucket = pathSegments[bucketIndex];
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      await _client.storage.from(bucket).remove([filePath]);
    } catch (e) {
      Log.e(e.toString());
    }
  }

  Future<void> deleteUserAvatar(String userId) async {
    try {
      await _client.storage.from('avatars').remove(['$userId.png']);
    } catch (e) {
      Log.e('Error deleting avatar: $e');
    }
  }

  String getUserImageUrl(String userId) {
    return _client.storage.from('avatars').getPublicUrl('$userId.png');
  }
}
