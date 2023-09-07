import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:ui' as UI;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'log.dart';

class AppImageCropper {
  final BuildContext context;

  AppImageCropper(this.context);

  Future<CroppedFile?> cropImage(XFile pickedFile) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [WebUiSettings(context: context)],
      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      aspectRatioPresets: [CropAspectRatioPreset.square],
    );
    return croppedFile;
  }
}
