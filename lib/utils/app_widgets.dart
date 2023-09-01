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

class AppOtherMessageWidget extends StatelessWidget {
  final Message message;
  final String pictureData;
  final String displayName;
  final String userId;

  const AppOtherMessageWidget({
    Key? key,
    required this.message,
    required this.pictureData,
    required this.userId,
    required this.displayName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 10, top: 10, right: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              showVisitScreen(context, userId);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 0, right: 20),
              child: AppUserImage(pictureData),
            ),
          ),
          Flexible(
            child: (message.chatType == ChatType.giphy)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: CachedNetworkImage(
                      imageUrl: message.text,
                      placeholder: (context, url) =>
                          const Center(child: AppSpinner()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  )
                : Stack(
                    children: [
                      DecoratedBox(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            ),
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [AppColors.grey_1, AppColors.grey_2])),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayName,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color: AppColors.grey_1,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                message.text,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    color: AppColors.grey_1,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class AppMyMessageWidget extends StatelessWidget {
  final Message message;
  final String pictureData;

  const AppMyMessageWidget(
    this.message, {
    Key? key,
    required this.pictureData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            const EdgeInsets.only(left: 40, bottom: 10, top: 10, right: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            (message.chatType == ChatType.giphy)
                ? Flexible(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: CachedNetworkImage(
                        imageUrl: message.text,
                        placeholder: (context, url) =>
                            const Center(child: AppSpinner()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  )
                : Flexible(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Stack(
                        children: [
                          DecoratedBox(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0),
                                  topLeft: Radius.circular(10.0),
                                ),
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.main,
                                      AppColors.main_2
                                    ])),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                message.text,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: AppUserImage(pictureData),
            )
          ],
        ));
  }
}
