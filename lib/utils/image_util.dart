import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AppImageCropper {
  final BuildContext context;

  AppImageCropper(this.context);

  Future<CroppedFile?> cropImage(XFile pickedFile) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        WebUiSettings(context: context, zoomable: true, scalable: true, rotatable: true),
      ],
      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );
    return croppedFile;
  }
}
