import 'package:chat/utils/cloud_translation/google_cloud_translation.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

import '../log.dart';

const androidTranslateKey = 'AIzaSyDA_Ok3f2_H3bWZhKgiVzrPR6s5nYE4YKY';
const iOSTranslateKey = 'AIzaSyDrYtpHeq3jcb2SSqr4Da9wC-GYfXOd6ko';
const webTranslateKey = 'AIzaSyChD4747kdf9R6l5WehknJfXeTgPmUK34o';

Translation getTranslator(){
  return Translation(apiKey: kIsWeb? webTranslateKey : Platform.isIOS? iOSTranslateKey : androidTranslateKey, onError: (error) {
    Log.e('Translation error: $error');
  });
}