import 'dart:async';
import 'package:chat/repository/firestore_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../model/chat.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/flag.dart';
import '../../utils/gender.dart';
import '../../utils/lottie.dart';
import '../../utils/translate.dart';
import '../message_holder/bloc/message_holder_bloc.dart';
import '../message_holder/bloc/message_holder_event.dart';
import '../messages/message_edit_text_widget.dart';
import '../messages/other_message_widget.dart';
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

const bottomsheetHeight = 450.0;

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
          return Container(
            height: bottomsheetHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
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
                Center(
                    child: AppUserImage(
                  url: user.pictureData,
                  gender: user.gender,
                  size: 110,
                )),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.user?.displayName ?? '',
                        style: Theme.of(context).textTheme.displaySmall?.merge(
                            TextStyle(
                                color: getGenderColor(
                                    Gender.fromValue(user.gender)))),
                      ),
                      const SizedBox(width: 2),
                      if (user.gender != Gender.secret.value)
                        SizedBox(
                            width: 30,
                            height: 30,
                            child: AppLottie(
                              url: getGenderUrl(user.gender),
                              animate: false,
                            )),
                      getFlag(
                          countryCode: state.user?.countryCode ?? '',
                          fontSize: 30)
                    ],
                  ),
                ),
                Text('${user.city}, ${user.country}',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 40),
                if (!state.userBlocked &&
                    !state.myUser.blockedBy.contains(user.id))
                  state.isChatAvailable
                      ? Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: MessageEditTextWidget(
                            currentMessage: '',
                            onTextChanged: (String value) {},
                            onTapGiphy: () {},
                            hintText: FlutterI18n.translate(
                                context, "write_private_message_hint"),
                            showGiphy: false,
                            onSendTapped: (String message) {
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
                TextButton(
                  onPressed: () {
                    if (state.userBlocked) {
                      BlocProvider.of<VisitBloc>(blocContext)
                          .add(VisitUnblocUserEvent());
                    } else {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return getBlockAccountDialog(blocContext, context);
                          });
                    }
                  },
                  child: Text(translate(context,
                      state.userBlocked ? 'unblock_user' : 'block_user')),
                ),
              ],
            ),
          );
        } else if (state is VisitBaseState &&
            state.user == null &&
            state.userLoaded) {
          return Container(
            width: double.infinity,
            height: bottomsheetHeight,
            decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
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
          return Container(
            width: double.infinity,
            height: bottomsheetHeight,
            decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: const Center(
              child: AppSpinner(),
            ),
          );
        }
      }),
    );
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
        child: Text(translate(context, 'yes')),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(translate(context, 'no')),
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
    backgroundColor: AppColors.transparent,
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
