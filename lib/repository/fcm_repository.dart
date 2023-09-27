import 'package:chat/model/chat_user.dart';
import 'package:chat/repository/firestore_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../utils/log.dart';

class FcmRepository {
  final FirestoreRepository _firebaseRepository;

  FcmRepository(this._firebaseRepository);

  void setUpPushNotification() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized) {
      Log.d('User granted permission');
      setUpToken();
    } else if(settings.authorizationStatus == AuthorizationStatus.provisional) {
      Log.d('User granted provisional permission');
      setUpToken();
    } else {
      Log.d('User declined or has not accepted permission');
    }

    setUpToken();
  }

  Future<void> setUpToken() async {
    String? fcmToken;
    if (kIsWeb) {
      fcmToken = await FirebaseMessaging.instance
          .getToken(vapidKey: "F_2QYMzyCsTi_pPd2OYiGlLEjm8ibzvS3YJaUzawCkU");
    } else {
      fcmToken = await FirebaseMessaging.instance.getToken();
    }

    if (fcmToken != null) _firebaseRepository.saveFcmTokenOnUser(fcmToken);

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      Log.d('FCM token updated: $fcmToken');
      _firebaseRepository.saveFcmTokenOnUser(fcmToken);
    }).onError((err) {
      Log.e('FCM token error: $err');
    });
  }
}
