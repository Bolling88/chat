import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

logEvent(String eventName) async {
  await FirebaseAnalytics.instance.logEvent(name: 'eventName', parameters: {
    'platform': kIsWeb
        ? 'web'
        : Platform.isIOS
            ? 'ios'
            : 'android'
  });
}
