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
import '../hero/hero_screen.dart';
import '../message_holder/bloc/message_holder_bloc.dart';
import '../message_holder/bloc/message_holder_event.dart';
import '../messages/message_edit_text_widget.dart';
import '../messages/other_message_widget.dart';
import 'bloc/visit_bloc.dart';
import 'bloc/visit_state.dart';

class VisitScreen extends StatelessWidget {
  final String userId;
  final Chat chat;
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
          VisitBloc(context.read<FirestoreRepository>(), userId, chat.id),
      child: VisitScreenContent(
          parentContext: parentContext,
          chat: chat,
          showBackButton: showBackButton),
    );
  }
}

const viewHeight = 400.0;

class VisitScreenContent extends StatelessWidget {
  final BuildContext parentContext;
  final Chat chat;
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
      child: BlocBuilder<VisitBloc, VisitState>(builder: (context, state) {
        if (state is VisitBaseState && state.user != null) {
          final user = state.user!;
          return Container(
            height: viewHeight,
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
                    child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, HeroScreen.routeName,
                        arguments: HeroScreenArguments(user.pictureData));
                  },
                  child: Hero(
                    tag: "imageHero",
                    child: AppUserImage(
                      url: user.pictureData,
                      gender: user.gender,
                      size: 110,
                    ),
                  ),
                )),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.user?.displayName ?? '',
                        style: Theme.of(context).textTheme.displaySmall ?.merge(TextStyle(
                            color: getGenderColor(
                                Gender.fromValue(user.gender)))),
                      ),
                      const SizedBox(width: 2),
                      if(user.gender != Gender.secret.value)
                      SizedBox(
                          width: 30,
                          height: 30,
                          child: AppLottie(
                            url: getGenderUrl(user.gender),
                            animate: false,
                          )),
                      getFlag(
                          countryCode:
                          state.user?.countryCode ?? '',
                          fontSize: 30)
                    ],
                  ),
                ),
                Text('${user.city}, ${user.country}',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 40),
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
                              MessageHolderStartPrivateChatEvent(user, message),
                            );
                            Navigator.popUntil(context,
                                ModalRoute.withName('/message_holder_screen'));
                          },
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<MessageHolderBloc>(parentContext).add(
                            MessageHolderStartPrivateChatEvent(user, ''),
                          );
                          Navigator.popUntil(context,
                              ModalRoute.withName('/message_holder_screen'));
                        },
                        child: Text(FlutterI18n.translate(
                            context, 'go_to_private_chat')),
                      )
              ],
            ),
          );
        } else if (state is VisitBaseState &&
            state.user == null &&
            state.userLoaded) {
          return Container(
            width: double.infinity,
            height: viewHeight,
            decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Column(
              children: [
                const Center(
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
            height: viewHeight,
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

class DetailScreen extends StatelessWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: 'profile',
            child: Image.network(
              'https://picsum.photos/250?image=9',
            ),
          ),
        ),
      ),
    );
  }
}

Future showVisitScreen(BuildContext parentContext, String userId, Chat chat,
    bool showBackButton) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    isScrollControlled: true,
    context: parentContext,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: VisitScreen(
            userId: userId,
            parentContext: parentContext,
            chat: chat,
            showBackButton: showBackButton),
      );
    },
  );
}
