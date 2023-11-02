import "dart:developer";

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import "package:flutter/foundation.dart";

class Log {
  static void d(String message, {bool display = false}) {
    if (kReleaseMode) {
      //Do not print any logs on release builds
    } else {
      log(message);
    }
  }

  static void e(dynamic exception, {StackTrace? stackTrace}) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(exception, stackTrace);
    } else {
      log(exception.toString());
      if (stackTrace != null) {
        log(stackTrace.toString());
      }
    }
  }
}
