import 'package:flutter/material.dart';

extension ColorUtil on BuildContext {
  Color dynamicColor({required int light, required int dark}) {
    return (Theme
        .of(this)
        .brightness == Brightness.light) ? Color(light) : Color(dark);
  }

  Color dynamicColour({required Color light, required Color dark}) {
    return (Theme
        .of(this)
        .brightness == Brightness.light) ? light : dark;
  }

  Color get main =>
      dynamicColour(light: const Color(0xFF30c7c2), dark: const Color(0xFF30c7c2));

  Color get appBar =>
      dynamicColour(light: const Color(0xFF30c7c2), dark: const Color(0xFF002022));

  Color get main_2 =>
      dynamicColour(light: const Color(0xFF199E99), dark: const Color(0xFF199E99));

  Color get main_3 =>
      dynamicColour(light: const Color(0xFF199E99), dark: const Color(0xFF199E99));

  Color get textColor =>
      dynamicColour(light: const Color(0xFF909090), dark: const Color(0xFFFFFFFF));

  Color get grey_3 =>
      dynamicColour(light: const Color(0xFFE3E3E3), dark: const Color(0xFF003735));

  Color get grey_4 =>
      dynamicColour(light: const Color(0xFFf2f2f2), dark: const Color(0xFF006A67));

  Color get grey_5 =>
      dynamicColour(light: const Color(0xFFbfbfbf), dark: const Color(0xFF006A67));

  Color get white =>
      dynamicColour(light: const Color(0xFFFFFFFF), dark: const Color(0xFFFFFFFF));

  Color get black =>
      dynamicColour(light: const Color(0xFF000000), dark: const Color(0xFF000000));

  Color get transparent =>
      dynamicColour(light: const Color(0x00000000), dark: const Color(0x00000000));

  Color get backgroundColor =>
      dynamicColour(light: const Color(0xFFF3FEFF), dark: const Color(0xFF002022));

  Color get purple =>
      dynamicColour(light: const Color(0xFF673AB7), dark: const Color(0xFF673AB7));

  Color get red =>
      dynamicColour(light: const Color(0xFFF44336), dark: const Color(0xFFF44336));

  Color get pink =>
      dynamicColour(light: const Color(0xFFE91E63), dark: const Color(0xFFE91E63));

  Color get blue =>
      dynamicColour(light: const Color(0xFF2196F3), dark: const Color(0xFF2196F3));
}