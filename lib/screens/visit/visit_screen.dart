import 'dart:async';
import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/report/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../model/chat.dart';
import '../../model/chat_user.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/lottie.dart';
import '../../utils/translate.dart';
import '../account/account_screen.dart';
import '../full_screen_image/full_screen_image_screen.dart';
import '../message_holder/bloc/message_holder_bloc.dart';
import '../message_holder/bloc/message_holder_event.dart';
import '../message_holder/message_holder_screen.dart';
import '../messages/message_edit_text_widget.dart';
import 'bloc/visit_bloc.dart';
import 'bloc/visit_event.dart';
import 'bloc/visit_state.dart';

class VisitScreen extends StatelessWidget {
  final String userId;
  final Chat? chat;
  final BuildContext parentContext;
  final bool showBackButton;

  const VisitScreen({
    required this.userId,
    required this.chat,
    required this.parentContext,
    required this.showBackButton,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          VisitBloc(context.read<FirestoreRepository>(), userId, chat),
      child: VisitScreenContent(
          parentContext: parentContext,
          chat: chat,
          showBackButton: showBackButton),
    );
  }
}

const _bottomsheetHeight = 480.0;

class VisitScreenContent extends StatelessWidget {
  final BuildContext parentContext;
  final Chat? chat;
  final bool showBackButton;

  const VisitScreenContent(
      {required this.parentContext,
      required this.chat,
      required this.showBackButton,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitBloc, VisitState>(
      listener: (context, state) {},
      child: BlocBuilder<VisitBloc, VisitState>(builder: (blocContext, state) {
        if (state is VisitBaseState && state.user != null) {
          final user = state.user!;
          return SizedBox(
            height: _bottomsheetHeight,
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Visibility(
                      visible: showBackButton,
                      maintainSize: true,
                      maintainState: true,
                      maintainAnimation: true,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(10),
                          ),
                          child: const Icon(Icons.arrow_back)),
                    ),
                    Expanded(child: Container()),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10),
                        ),
                        child: const Icon(Icons.close))
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    if (user.pictureData.isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute<bool>(
                          builder: (BuildContext context) =>
                              FullScreenImageScreen(
                                  imageUrl: user.pictureData,
                                  userName: user.displayName,
                                  imageReports: user.imageReports,
                                  approvalState: ApprovedImage.fromValue(
                                      user.approvedImage)),
                        ),
                      );
                    }
                  },
                  child: Hero(
                    tag: 'fullscreenImage',
                    child: Center(
                        child: AppUserImage(
                      url: user.pictureData,
                      gender: user.gender,
                      approvalState:
                          ApprovedImage.fromValue(user.approvedImage),
                      imageReports: user.imageReports,
                      size: 110,
                    )),
                  ),
                ),
                Center(
                  child: getProfileRow(
                      displayName: user.displayName,
                      gender: user.gender,
                      countryCode: user.countryCode,
                      birthDate: user.birthDate,
                      showAge: user.showAge,
                      context: context),
                ),
                getRegionText(user, context),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    user.lastActive >
                            DateTime.now()
                                .subtract(onlineDuration)
                                .millisecondsSinceEpoch
                        ? Text(
                            FlutterI18n.translate(context, 'online'),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: context.main),
                          )
                        : Text(FlutterI18n.translate(context, 'offline'),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: context.textColor)),
                    const SizedBox(width: 5),
                    //If lats active is more than $onlineDuration ago, show offline dot
                    getOnlineDot(
                        user.lastActive >
                            DateTime.now()
                                .subtract(onlineDuration)
                                .millisecondsSinceEpoch,
                        context),
                  ],
                ),
                const SizedBox(height: 20),
                if (!state.userBlocked &&
                    !state.myUser.blockedBy.contains(user.id))
                  state.isChatAvailable
                      ? Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: MessageEditTextWidget(
                            currentMessage: '',
                            onTextChanged: (String value) {
                              BlocProvider.of<VisitBloc>(context)
                                  .add(VisitTextChangedEvent(value));
                            },
                            onTapGiphy: () {},
                            onImageTap: () {},
                            hintText: FlutterI18n.translate(
                                context, "write_private_message_hint"),
                            showGiphy: false,
                            showImage: false,
                            onSendTapped: (String message) {
                              if (message.isEmpty) {
                                return;
                              }
                              BlocProvider.of<MessageHolderBloc>(parentContext)
                                  .add(
                                MessageHolderStartPrivateChatEvent(
                                    user, message),
                              );
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<MessageHolderBloc>(parentContext)
                                .add(
                              MessageHolderStartPrivateChatEvent(user, ''),
                            );
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          child: Text(FlutterI18n.translate(
                              context, 'go_to_private_chat')),
                        ),
                if (state.message.isEmpty) const SizedBox(height: 20),
                if (state.message.isEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        state.userBlocked
                            ? Icons.check_circle_outline
                            : Icons.block,
                        color: state.userBlocked ? context.main : context.red,
                        size: 14,
                      ),
                      TextButton(
                        onPressed: () {
                          if (state.userBlocked) {
                            BlocProvider.of<VisitBloc>(blocContext)
                                .add(VisitUnblocUserEvent());
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return getBlockAccountDialog(
                                      blocContext, context);
                                });
                          }
                        },
                        child: Text(
                          translate(
                              context,
                              state.userBlocked
                                  ? 'unblock_user'
                                  : 'block_user'),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: state.userBlocked
                                      ? context.main
                                      : context.red),
                        ),
                      ),
                    ],
                  ),
                if (state.message.isEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.report,
                        color: context.red,
                        size: 14,
                      ),
                      TextButton(
                        onPressed: () {
                          final visitedUserId = state.user?.id;
                          if (visitedUserId != null) {
                            showReportScreen(context, visitedUserId);
                          }
                        },
                        child: Text(
                          translate(context, 'report_user'),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: context.red),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        } else if (state is VisitBaseState &&
            state.user == null &&
            state.userLoaded) {
          return SizedBox(
            width: double.infinity,
            height: _bottomsheetHeight,
            child: Column(
              children: [
                Center(
                    child: SizedBox(
                        height: 200,
                        child: AppLottie(
                            url:
                                'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/lottie%2Fshrug.json?alt=media&token=73407d43-f0b5-4762-9042-12f07b3646e5'))),
                Text(
                  FlutterI18n.translate(context, 'user_offline'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        } else {
          return const SizedBox(
            width: double.infinity,
            height: _bottomsheetHeight,
            child: Center(
              child: AppSpinner(),
            ),
          );
        }
      }),
    );
  }
}

Text getRegionText(ChatUser user, BuildContext context) {
  final regionName = user.regionName;
  final countryName = user.country;
  final cityName = user.city;
  final region = (regionName.isNotEmpty) ? regionName : cityName;

  if (region.isEmpty && countryName.isEmpty) {
    return Text(FlutterI18n.translate(context, 'unknown_location'),
        style: Theme.of(context).textTheme.bodyMedium);
  }

  if (region.isNotEmpty) {
    return Text('$region, ${user.country}',
        style: Theme.of(context).textTheme.bodyMedium);
  } else {
    return Text(countryName, style: Theme.of(context).textTheme.bodyMedium);
  }
}

AlertDialog getBlockAccountDialog(
    BuildContext blocContext, BuildContext context) {
  return AlertDialog(
    title: Text(translate(context, 'block_user')),
    content: Text(translate(context, 'block_user_info')),
    actions: [
      TextButton(
        onPressed: () {
          BlocProvider.of<VisitBloc>(blocContext).add(VisitBlocUserEvent());
          Navigator.of(context).pop();
        },
        child: Text(translate(context, 'yes').toUpperCase()),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(translate(context, 'no').toUpperCase()),
      ),
    ],
  );
}

Future showVisitScreen(BuildContext parentContext, String userId, Chat? chat,
    bool showBackButton) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    isScrollControlled: true,
    context: parentContext,
    builder: (BuildContext context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: VisitScreen(
            userId: userId,
            parentContext: parentContext,
            chat: chat,
            showBackButton: showBackButton),
      );
    },
  );
}
