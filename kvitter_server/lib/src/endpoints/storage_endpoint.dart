import 'dart:math';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class StorageEndpoint extends Endpoint {
  static const _maxFileSize = 2 * 1024 * 1024;
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final _rnd = Random();

  static String _randomString(int length) => String.fromCharCodes(
        Iterable.generate(
          length,
          (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
        ),
      );

  Future<String?> uploadAvatar(Session session, ByteData imageData) async {
    if (imageData.lengthInBytes > _maxFileSize) return null;

    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return null;

    final myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.authUserIdentifier.equals(authId),
    );
    if (myUser == null) return null;

    final path = 'avatars/${myUser.id}.png';
    await session.storage.storeFile(
      storageId: 'public',
      path: path,
      byteData: imageData,
    );
    final uri = await session.storage.getPublicUrl(
      storageId: 'public',
      path: path,
    );
    return uri?.toString();
  }

  Future<String?> uploadChatImage(Session session, ByteData imageData) async {
    if (imageData.lengthInBytes > _maxFileSize) return null;

    final path = 'chat-images/${_randomString(20)}.png';
    await session.storage.storeFile(
      storageId: 'public',
      path: path,
      byteData: imageData,
    );
    final uri = await session.storage.getPublicUrl(
      storageId: 'public',
      path: path,
    );
    return uri?.toString();
  }

  Future<void> deleteAvatar(Session session) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return;

    final myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.authUserIdentifier.equals(authId),
    );
    if (myUser == null) return;

    await session.storage.deleteFile(
      storageId: 'public',
      path: 'avatars/${myUser.id}.png',
    );
  }

  Future<void> deleteUserAvatar(Session session, String userId) async {
    await session.storage.deleteFile(
      storageId: 'public',
      path: 'avatars/$userId.png',
    );
  }
}
