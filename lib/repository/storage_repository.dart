import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

import '../utils/log.dart';

class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<Reference?> uploadProfileImage(
      String filePath, String base64Image) async {
    File file = File(filePath);
    String userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      final task = kIsWeb
          ? await _storage.ref('images/$userId.png').putData(
              base64.decode(base64Image),
              SettableMetadata(contentType: 'image/jpeg'))
          : await _storage.ref('images/$userId.png').putFile(file);
      return task.ref;
    } on FirebaseException catch (e) {
      Log.e(e.toString());
    }
    return null;
  }

  Future<Reference?> uploadMessageImage(
      String filePath, String base64Image) async {
    File file = File(filePath);

    try {
      final task = kIsWeb
          ? await _storage.ref('chatImage/${file.path}.png').putData(
          base64.decode(base64Image),
          SettableMetadata(contentType: 'image/jpeg'))
          : await _storage.ref('chatImage/${file.path}.png').putFile(file);
      return task.ref;
    } on FirebaseException catch (e) {
      Log.e(e.toString());
    }
    return null;
  }

  Future<Reference?> deleteImage(String filePath) async {
    try {
      await _storage.refFromURL(filePath).delete();
    } on FirebaseException catch (e) {
      Log.e(e.toString());
    }
    return null;
  }

  Future<void> deleteFolder(String filePath) async {
    Log.d('Deleting images in $filePath');
    await FirebaseStorage.instance.ref(filePath).listAll().then((value) {
      for (var element in value.items) {
        Log.d('$element.fullPath');
        _storage.ref(element.fullPath).delete();
      }
    });
  }

  Future<String> getUserImageUrl(String userId) async {
    return await _storage.ref('images/$userId.png').getDownloadURL();
  }
}
