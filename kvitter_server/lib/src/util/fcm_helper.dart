import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

class FcmHelper {
  static Future<void> sendPush({
    required Session session,
    required String fcmToken,
    required String title,
    required String body,
  }) async {
    try {
      final serverKey = session.passwords['fcmServerKey'];
      if (serverKey == null) {
        session.log('FCM server key not configured', level: LogLevel.warning);
        return;
      }

      final httpClient = HttpClient();
      final request = await httpClient.postUrl(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
      );
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Authorization', 'key=$serverKey');
      request.write(jsonEncode({
        'to': fcmToken,
        'notification': {
          'title': title,
          'body': body,
        },
      }));

      final response = await request.close();
      if (response.statusCode != 200) {
        session.log(
          'FCM push failed: ${response.statusCode}',
          level: LogLevel.warning,
        );
      }
      httpClient.close();
    } catch (e) {
      session.log('FCM push error: $e', level: LogLevel.error);
    }
  }
}
