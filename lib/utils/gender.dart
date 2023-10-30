import 'dart:ui';

import 'package:chat/utils/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../repository/firestore_repository.dart';

String getGenderImageUrl(Gender gender) {
  if (gender == Gender.female) {
    return 'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/genders%2Fwoman.png?alt=media&token=e0400e5d-3735-453f-98fd-93cfbe6d163b';
  } else if (gender == Gender.male) {
    return 'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/genders%2Fman.png?alt=media&token=79537759-e1dd-4883-8f4b-268d1c118d74';
  } else if (gender == Gender.nonBinary) {
    return 'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/genders%2Fnonbinary.png?alt=media&token=8e034272-586b-462a-892d-81b7ce234bde';
  } else {
    return 'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/genders%2Fsecret.png?alt=media&token=4a468f0c-16a6-4cc8-92c9-eaf78c0482c1';
  }
}

//Get gender name string
String getGenderName(BuildContext context, Gender gender){
  switch (gender) {
    case Gender.female:
      return FlutterI18n.translate(context, 'female');
    case Gender.male:
      return FlutterI18n.translate(context, 'male');
    case Gender.nonBinary:
      return FlutterI18n.translate(context, 'non_binary');
    case Gender.secret:
      return FlutterI18n.translate(context, 'unknown');
  }
}

Color getGenderColor(Gender gender) {
  switch (gender) {
    case Gender.female:
      return AppColors.pink;
    case Gender.male:
      return AppColors.main;
    case Gender.nonBinary:
      return AppColors.purple;
    case Gender.secret:
      return AppColors.blue;
  }
}
