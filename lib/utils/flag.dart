import 'package:flutter/material.dart';

Text getFlag({required String countryCode, required double fontSize}) {
  return Text(
    countryCode.toUpperCase().replaceAllMapped(RegExp(r'[A-Z]'),
        (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 127397)),
    style: TextStyle(fontSize: fontSize),
  );
}
