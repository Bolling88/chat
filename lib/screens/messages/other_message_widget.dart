import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/screens/messages/bloc/messages_bloc.dart';
import 'package:chat/screens/options/options_screen.dart';
import 'package:chat/utils/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/chat.dart';
import '../../model/message.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_widgets.dart';
import '../../utils/flag.dart';
import '../../utils/gender.dart';
import '../account/account_screen.dart';
import '../full_screen_image/full_screen_image_screen.dart';
import '../visit/visit_screen.dart';
import 'bloc/messages_event.dart';
import 'my_message_widget.dart';

class AppOtherMessageWidget extends StatelessWidget {
  final Message message;
  final String pictureData;
  final String displayName;
  final String userId;
  final List<String> imageReports;
  final int approvedImage;
  final int gender;
  final String countryCode;
  final Timestamp? birthDate;
  final bool showAge;
  final Chat chat;
  final double paddingRight;
  final double paddingLeft;

  const AppOtherMessageWidget({
    Key? key,
    required this.message,
    required this.pictureData,
    required this.userId,
    required this.imageReports,
    required this.displayName,
    required this.gender,
    required this.approvedImage,
    required this.countryCode,
    required this.birthDate,
    required this.showAge,
    required this.chat,
    this.paddingRight = 40,
    this.paddingLeft = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: paddingLeft, bottom: 5, top: 5, right: paddingRight),
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
                approvalState: ApprovedImage.fromValue(approvedImage),
                imageReports: imageReports,
                gender: gender,
              ),
            ),
          ),
          getMessageContent(context),
        ],
      ),
    );
  }

  Widget getMessageContent(BuildContext context) {
    switch (message.chatType) {
      case ChatType.message:
        return getMessageWidget(context);
      case ChatType.joined:
        return Container();
      case ChatType.left:
        return Container();
      case ChatType.giphy:
        return getImageWidget(
            context: context,
            shouldBlur: false,
            onTap: () {
              showVisitScreen(context, userId, chat, false);
            });
      case ChatType.date:
        return Container();
      case ChatType.image:
        return getImageWidget(
            context: context,
            shouldBlur: !chat.isPrivateChat(),
            onTap: () {
              if (message.text.isNotEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute<bool>(
                    builder: (BuildContext context) => FullScreenImageScreen(
                        imageUrl: message.text,
                        userName: message.createdByName,
                        imageReports: message.imageReports,
                        approvalState: chat.isPrivateChat()
                            ? ApprovedImage.approved
                            : ApprovedImage.notApproved),
                  ),
                );
              }
            });
    }
  }

  Widget getMessageWidget(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          BlocProvider.of<MessagesBloc>(context)
              .add(MessagesMarkedEvent(message: message, marked: true));
          showOptionsScreen(context, message);
        },
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Material(
            type: MaterialType.card,
            elevation: 1,
            color: message.marked ? context.main_3 : context.grey_4,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0.0),
                    topRight: Radius.circular(5.0),
                    bottomRight: Radius.circular(5.0),
                    bottomLeft: Radius.circular(5.0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
                  child: getPostedByName(
                    context: context,
                    displayName: displayName,
                    gender: gender,
                    countryCode: countryCode,
                    showAge: showAge,
                    birthDate: birthDate,
                  ),
                ),
                if (message.replyId.isNotEmpty)
                  IgnorePointer(
                    child: Transform.scale(
                      scale: 0.8,
                      child: AppOtherMessageWidget(
                        message: Message(
                            id: '',
                            text: message.replyText,
                            createdById: message.replyCreatedById,
                            createdByName: message.replyCreatedByName,
                            createdByGender: message.replyCreatedByGender,
                            createdByCountryCode:
                                message.replyCreatedByCountryCode,
                            createdByImageUrl: message.replyCreatedByImageUrl,
                            chatType: message.replyChatType,
                            approvedImage: message.replyApprovedImage,
                            created: message.replyCreated ?? Timestamp.now(),
                            showAge: message.replyShowAge,
                            marked: false,
                            imageReports: message.replyImageReports),
                        pictureData: message.replyCreatedByImageUrl,
                        gender: message.replyCreatedByGender,
                        userId: message.replyCreatedById,
                        imageReports: message.replyImageReports,
                        displayName: message.replyCreatedByName,
                        approvedImage: message.replyApprovedImage,
                        countryCode: message.replyCreatedByCountryCode,
                        birthDate: message.replyBirthDate,
                        showAge: message.replyShowAge,
                        chat: chat,
                        paddingLeft: 0,
                        paddingRight: 0,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    message.text,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyMedium?.merge(
                          TextStyle(
                            color: message.marked
                                ? context.white
                                : context.textColor,
                            fontSize: isOnlyEmojis(message.text)
                                ? 40
                                : Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.fontSize,
                          ),
                        ),
                  ),
                ),
                if (message.translation != null &&
                    message.translation?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      message.translation ?? '',
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodyMedium?.merge(
                            TextStyle(
                              color: context.main,
                              fontSize: isOnlyEmojis(message.text)
                                  ? 40
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.fontSize,
                            ),
                          ),
                    ),
                  ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getImageWidget(
      {required BuildContext context,
      required bool shouldBlur,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
            child: getPostedByName(
              context: context,
              displayName: displayName,
              gender: gender,
              countryCode: countryCode,
              showAge: showAge,
              birthDate: birthDate,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.bottomLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: SizedBox(
                width: 200,
                height: 200,
                child: Blur(
                  blur: shouldBlur ? 6 : 0,
                  colorOpacity: shouldBlur ? 0.5 : 0,
                  blurColor: context.white,
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
          ),
        ],
      ),
    );
  }
}

Widget getPostedByName({
  required BuildContext context,
  required String displayName,
  required int gender,
  required String countryCode,
  required bool showAge,
  Timestamp? birthDate,
}) {
  return Wrap(
    alignment: WrapAlignment.start,
    runAlignment: WrapAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(displayName,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodySmall?.merge(TextStyle(
                color: getGenderColor(context, Gender.fromValue(gender)),
                fontWeight: FontWeight.bold))),
      ),
      if (gender != Gender.secret.value)
        getGenderIcon(context, Gender.fromValue(gender), size: 18),
      const SizedBox(width: 2),
      if (birthDate != null && showAge)
        Text(
          getAge(birthDate),
          style: Theme.of(context).textTheme.displaySmall?.merge(TextStyle(
              color: getGenderColor(context, Gender.fromValue(gender)),
              fontSize: 16)),
        ),
      if (birthDate != null && showAge) const SizedBox(width: 8),
      getFlag(countryCode: countryCode, fontSize: 16),
    ],
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
