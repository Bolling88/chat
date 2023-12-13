import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/screens/messages/bloc/messages_bloc.dart';
import 'package:chat/screens/options/options_screen.dart';
import 'package:chat/utils/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../model/chat.dart';
import '../../model/message.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/flag.dart';
import '../../utils/gender.dart';
import '../account/account_screen.dart';
import '../visit/visit_screen.dart';
import 'bloc/messages_event.dart';
import 'my_message_widget.dart';

class AppOtherMessageWidget extends StatelessWidget {
  final Message message;
  final String pictureData;
  final String displayName;
  final String userId;
  final int approvedImage;
  final int gender;
  final String countryCode;
  final Timestamp? birthDate;
  final bool showAge;
  final Chat chat;

  const AppOtherMessageWidget({
    Key? key,
    required this.message,
    required this.pictureData,
    required this.userId,
    required this.displayName,
    required this.gender,
    required this.approvedImage,
    required this.countryCode,
    required this.birthDate,
    required this.showAge,
    required this.chat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 5, top: 5, right: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              showVisitScreen(context, userId, chat, false);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 0, right: 10),
              child: AppUserImage(
                url: pictureData,
                isApproved: ApprovedImage.fromValue(approvedImage),
                gender: gender,
              ),
            ),
          ),
          if (message.chatType == ChatType.giphy)
            giphyMessage(context)
          else
            regularMessage(context),
        ],
      ),
    );
  }

  Expanded regularMessage(BuildContext context) {
    return Expanded(
            child: GestureDetector(
              onTap: (){
                BlocProvider.of<MessagesBloc>(context)
                    .add(MessagesMarkedEvent(message: message, marked: true));
                showOptionsScreen(context, message);
              },
              child: Align(
                alignment: Alignment.bottomLeft,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                        topRight: Radius.circular(10.0),
                      ),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            message.marked
                                ? AppColors.main_3
                                : AppColors.grey_4,
                            message.marked
                                ? AppColors.main_3
                                : AppColors.grey_4
                          ])),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(displayName,
                                textAlign: TextAlign.left,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.merge(TextStyle(
                                        color: getGenderColor(
                                            Gender.fromValue(gender)),
                                        fontWeight: FontWeight.bold))),
                            if (gender != Gender.secret.value)
                              SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: AppLottie(
                                    url: getGenderUrl(gender),
                                    animate: false,
                                  )),
                            const SizedBox(width: 2),
                            if (birthDate != null && showAge)
                              Text(
                                getAge(birthDate),
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.merge(TextStyle(
                                        color: getGenderColor(
                                            Gender.fromValue(gender)),
                                        fontSize: 16)),
                              ),
                            if (birthDate != null) const SizedBox(width: 8),
                            getFlag(countryCode: countryCode, fontSize: 16),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              message.text,
                              textAlign: TextAlign.left,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.merge(
                                    TextStyle(
                                      color: message.marked? AppColors.white: AppColors.grey_1,
                                      fontSize: isOnlyEmojis(message.text)
                                          ? 40
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.fontSize,
                                    ),
                                  ),
                            ),
                            if (message.translation != null &&
                                message.translation?.isNotEmpty == true)
                              Text(
                                message.translation ?? '',
                                textAlign: TextAlign.left,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.merge(
                                      TextStyle(
                                        color: AppColors.main,
                                        fontSize: isOnlyEmojis(message.text)
                                            ? 40
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.fontSize,
                                      ),
                                    ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Widget giphyMessage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showVisitScreen(context, userId, chat, false);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(displayName,
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.merge(TextStyle(
                      color: getGenderColor(
                          Gender.fromValue(gender)),
                      fontWeight: FontWeight.bold))),
              if (gender != Gender.secret.value)
                SizedBox(
                    width: 18,
                    height: 18,
                    child: AppLottie(
                      url: getGenderUrl(gender),
                      animate: false,
                    )),
              const SizedBox(width: 2),
              if (birthDate != null && showAge)
                Text(
                  getAge(birthDate),
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.merge(TextStyle(
                      color: getGenderColor(
                          Gender.fromValue(gender)),
                      fontSize: 16)),
                ),
              if (birthDate != null) const SizedBox(width: 8),
              getFlag(countryCode: countryCode, fontSize: 16),
            ],
          ),
          Align(
                  alignment: Alignment.bottomLeft,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: CachedNetworkImage(
                        imageUrl: message.text,
                        placeholder: (context, url) =>
                            const Center(child: AppSpinner()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

void showReportDialog(BuildContext parentContext, Message message) {
  showDialog(
    context: parentContext,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(FlutterI18n.translate(context, 'report_message')),
        content: Text(FlutterI18n.translate(context, 'report_message_info')),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(FlutterI18n.translate(context, 'no').toUpperCase()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text(FlutterI18n.translate(context, 'message_reported')),
              ));
              BlocProvider.of<MessagesBloc>(parentContext)
                  .add(MessagesReportMessageEvent(message));
            },
            child: Text(FlutterI18n.translate(context, 'yes').toUpperCase()),
          ),
        ],
      );
    },
  );
}

String getGenderUrl(int gender) {
  if (gender == Gender.female.value) {
    return 'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/lottie%2Ffemale.json?alt=media&token=dabc5dd7-3f5e-446a-9f69-1325a343ce90';
  } else if (gender == Gender.male.value) {
    return 'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/lottie%2Fmale.json?alt=media&token=0a7e6edf-2112-471f-b5ef-d07fac83a9b3';
  } else if (gender == Gender.nonBinary.value) {
    return 'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/lottie%2Fnonbinary.json?alt=media&token=c53c9728-aef5-448a-b534-669d5fb6d3e0';
  } else {
    return '';
  }
}
