import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:kvitter_client/kvitter_client.dart';
import 'package:universal_io/io.dart';

import '../utils/log.dart';

class ServerpodStorageRepository {
  final Client _client;

  ServerpodStorageRepository(this._client);

  Future<String?> uploadProfileImage(String filePath, String base64Image) async {
    try {
      ByteData imageData;
      if (kIsWeb) {
        imageData = ByteData.sublistView(Uint8List.fromList(base64.decode(base64Image)));
      } else {
        final bytes = await File(filePath).readAsBytes();
        imageData = ByteData.sublistView(bytes);
      }
      return await _client.storage.uploadAvatar(imageData);
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  Future<String?> uploadMessageImage(String filePath, String base64Image) async {
    try {
      ByteData imageData;
      if (kIsWeb) {
        imageData = ByteData.sublistView(Uint8List.fromList(base64.decode(base64Image)));
      } else {
        final bytes = await File(filePath).readAsBytes();
        imageData = ByteData.sublistView(bytes);
      }
      return await _client.storage.uploadChatImage(imageData);
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  Future<void> deleteImage(String publicUrl) async {
    try {
      await _client.storage.deleteAvatar();
    } catch (e) {
      Log.e(e.toString());
    }
  }

  Future<void> deleteUserAvatar(String userId) async {
    try {
      await _client.storage.deleteUserAvatar(userId);
    } catch (e) {
      Log.e('Error deleting avatar: $e');
    }
  }

  String getUserImageUrl(String userId) {
    return '${_client.host}/storage/avatars/$userId.png';
  }
}
