import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:ui' as UI;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'log.dart';

Future<CroppedFile?> cropImage(XFile pickedFile) async {
  final CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: pickedFile.path,
    aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    aspectRatioPresets: [CropAspectRatioPreset.square],
  );
  return croppedFile;
}

final Map imageCache = <String, UI.Image>{};

Future<UI.Image?> createImageFromAsset(String imageAssetPath) async {
  try {
    if (imageCache[imageAssetPath] != null) {
      return imageCache[imageAssetPath];
    }

    const int targetWidth = 160;
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    final Uint8List markerImageBytes = assetImageByteData.buffer.asUint8List();
    final Codec markerImageCodec = await instantiateImageCodec(
      markerImageBytes,
      targetWidth: targetWidth,
    );
    final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
    final ByteData? byteData = await frameInfo.image.toByteData(
      format: ImageByteFormat.png,
    );
    final Uint8List? data = byteData?.buffer.asUint8List();
    final Completer<UI.Image> completer = Completer();
    if (data != null) {
      UI.decodeImageFromList(Uint8List.view(data.buffer), (UI.Image img) {
        imageCache[imageAssetPath] = img;
        return completer.complete(img);
      });

      return completer.future;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<UI.Image?> createImageFromUrl(String url) async {
  try {
    if (imageCache[url] != null) return imageCache[url];

    const int targetWidth = 160;
    final File markerImageFile = await DefaultCacheManager().getSingleFile(url);
    final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
    final Codec markerImageCodec = await instantiateImageCodec(
      markerImageBytes,
      targetWidth: targetWidth,
    );
    final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
    final ByteData? byteData = await frameInfo.image.toByteData(
      format: ImageByteFormat.png,
    );
    final Uint8List? data = byteData?.buffer.asUint8List();
    final Completer<UI.Image> completer = Completer();
    if (data != null) {
      UI.decodeImageFromList(Uint8List.view(data.buffer), (UI.Image img) {
        imageCache[url] = img;
        return completer.complete(img);
      });

      return completer.future;
    } else {
      return null;
    }
  } catch (e) {
    Log.e(e);
    return null;
  }
}
