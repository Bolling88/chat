import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/utils/app_colors.dart';
import 'package:chat/utils/translate.dart';
import 'package:flutter/material.dart';
import '../repository/firestore_repository.dart';
import '../screens/full_screen_image/full_screen_image_screen.dart';
import 'gender.dart';

class AppSpinner extends StatelessWidget {
  const AppSpinner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}

class AppUserImage extends StatelessWidget {
  final String url;
  final int gender;
  final double? size;
  final List<String> imageReports;
  final ApprovedImage approvalState;

  const AppUserImage({
    required this.url,
    required this.gender,
    required this.imageReports,
    required this.approvalState,
    Key? key,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: shouldBlur(url, imageReports, approvalState)
          ? Blur(
              blur: shouldBlur(url, imageReports, approvalState) ? 6 : 0,
              colorOpacity:
                  shouldBlur(url, imageReports, approvalState) ? 0.5 : 0,
              blurColor: context.white,
              child: getImage(),
            )
          : getImage(),
    );
  }

  CachedNetworkImage getImage() {
    return CachedNetworkImage(
      imageUrl: url.isEmpty
          ? getGenderImageUrl(Gender.fromValue(
              (gender < 0 || gender > 3) ? 3 : gender,
            ))
          : url,
      width: size ?? 48,
      height: size ?? 48,
      fit: BoxFit.cover,
      // placeholder: (context, url) => AppSpinner(),
      errorWidget: (context, url, error) {
        return CachedNetworkImage(
            imageUrl: getGenderImageUrl(Gender.fromValue(
          (gender < 0 || gender > 3) ? 3 : gender,
        )));
      },
    );
  }
}

class AppErrorScreen extends StatelessWidget {
  final String? message;

  const AppErrorScreen({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.white,
      child: Center(
          child: Text(
        message ?? translate(context, 'unknown_error'),
        style: Theme.of(context).textTheme.displayMedium,
      )),
    );
  }
}

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AppSpinner(),
    );
  }
}
