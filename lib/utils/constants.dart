import 'package:flutter/material.dart';

const String giphyKey = "aW7gn21ohWo8eKWuH8o8yDpOnWQFRKKk";
const int photoQuality = 50;

enum ScreenSize { small, large }

ScreenSize getSize(BuildContext context) {
  double deviceWidth = MediaQuery.of(context).size.width;
  if (deviceWidth >= 855) {
    return ScreenSize.large;
  } else {
    return ScreenSize.small;
  }
}
