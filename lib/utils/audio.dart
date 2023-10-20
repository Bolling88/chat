import 'package:soundpool/soundpool.dart';

import 'log.dart';

final pool = Soundpool.fromOptions(
  options: const SoundpoolOptions(
    streamType: StreamType.notification,
    maxStreams: 2,
    iosOptions: SoundpoolOptionsIos(
      audioSessionCategory: AudioSessionCategory.ambient,
      audioSessionMode: AudioSessionMode.normal,
    ),
  ),
);

Future<void> playNewChatSound() async {
  try {
    pool.loadAndPlayUri(
        'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/audio%2Fstop.mp3?alt=media&token=88032575-9833-4bf5-86fb-554b61820c27');
  } catch (e) {
    Log.e(e);
  }
}

Future<void> playMessageSound() async {
  try {
    pool.loadAndPlayUri(
        'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/audio%2Fblob.ogg?alt=media&token=74f69b46-6b0b-441e-b3e2-0b27da772db7&_gl=1*zc96v9*_ga*OTk4NTkwNzU5LjE2ODI0NTIwNTI.*_ga_CW55HF8NVT*MTY5NzgwOTY4MC4yMDMuMS4xNjk3ODA5NzMxLjkuMC4w');
  } catch (e) {
    Log.e(e);
  }
}
