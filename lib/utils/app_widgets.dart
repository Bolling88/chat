import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/utils/translate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';

import '../model/chat_user.dart';
import '../model/message.dart';
import '../repository/data_repository.dart';
import '../repository/firestore_repository.dart';
import '../screens/messages/bloc/messages_bloc.dart';
import '../screens/messages/bloc/messages_event.dart';
import '../screens/visit/visit_screen.dart';
import 'app_colors.dart';

class AppSpinner extends StatelessWidget {
  const AppSpinner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.main));
  }
}

class AppUserImage extends StatelessWidget {
  final String url;
  final double? size;

  const AppUserImage(this.url, {Key? key, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size ?? 48,
        height: size ?? 48,
        fit: BoxFit.cover,
        // placeholder: (context, url) => AppSpinner(),
        errorWidget: (context, url, error) =>
            const Icon(Icons.account_circle_rounded),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String text;
  final double? width;
  final bool? wrapText;
  final double? height;
  final GestureTapCallback onTap;

  const AppButton(
      {Key? key,
      required this.text,
      required this.onTap,
      this.width,
      this.wrapText,
      this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: height ?? 40,
          width: (wrapText != null && wrapText == true)
              ? null
              : width ?? double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            gradient: const LinearGradient(
              colors: [
                AppColors.main,
                AppColors.main_2,
              ],
            ),
          ),
          child: Material(
            color: Colors.white.withOpacity(0.0),
            child: InkWell(
              splashColor: AppColors.white.withOpacity(0.2),
              onTap: onTap,
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 4, left: 20, right: 20),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class AppButtonDisabled extends StatelessWidget {
  final String text;
  final double? width;
  final GestureTapCallback? onTap;
  final bool? wrapText;
  final double? height;

  const AppButtonDisabled(
      {Key? key,
      required this.text,
      this.width,
      this.onTap,
      this.wrapText,
      this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (wrapText != null && wrapText == true)
          ? null
          : width ?? double.infinity,
      height: height ?? 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        gradient: const LinearGradient(
          colors: [
            AppColors.grey_1,
            AppColors.grey_2,
          ],
        ),
      ),
      child: Material(
        color: Colors.white.withOpacity(0.0),
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.white,
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class AppVectorImageButton extends StatelessWidget {
  final String assetName;
  final GestureTapCallback onTap;
  final Color? tint;

  const AppVectorImageButton(
      {Key? key, required this.assetName, required this.onTap, this.tint})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child:
          SvgPicture.asset(assetName, semanticsLabel: assetName, color: tint),
    );
  }
}

class AppErrorScreen extends StatelessWidget {
  const AppErrorScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Center(
          child: Text(
            translate(context, 'unknown_error'),
            style: const TextStyle(color: AppColors.white),
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
    return Container(
      color: AppColors.white,
      child: const Center(
        child: AppSpinner(),
      ),
    );
  }
}
