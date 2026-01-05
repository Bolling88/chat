import 'package:flutter/services.dart';
import 'log.dart';

/// Audio utility for notification sounds.
///
/// soundpool package was removed due to AGP 8 incompatibility.
/// If you need sound functionality, consider using `audioplayers` or `just_audio` package.

Future<void> playNewChatSound() async {
  try {
    HapticFeedback.vibrate();
    // Sound functionality disabled - soundpool incompatible with AGP 8
    // To re-enable, add audioplayers or just_audio package and implement sound playback
  } catch (e) {
    Log.e(e);
  }
}

Future<void> playMessageSound() async {
  try {
    HapticFeedback.vibrate();
    // Sound functionality disabled - soundpool incompatible with AGP 8
    // To re-enable, add audioplayers or just_audio package and implement sound playback
  } catch (e) {
    Log.e(e);
  }
}
