import 'dart:async';
import 'package:chat/repository/firestore_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../model/chat.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/lottie.dart';
import '../hero/hero_screen.dart';
import '../message_holder/bloc/message_holder_bloc.dart';
import '../message_holder/bloc/message_holder_event.dart';
import '../people/people_screen.dart';
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
                            showPeopleScreen(context, chat);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(10),
                          ),
                          child: const Icon(Icons.arrow_back)),
                    ),
                    Expanded(
                        child: Center(
                            child: Text(
                      state.user?.displayName ?? '',
                      style: Theme.of(context).textTheme.displaySmall,
                    ))),
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
                      user.pictureData,
                      size: 110,
                    ),
                  ),
                )),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    BlocProvider.of<MessageHolderBloc>(parentContext)
                        .add(MessageHolderPrivateChatEvent(user));
                  },
                  child: Text(FlutterI18n.translate(context, 'private_chat')),
                )
              ],
            ),
          );
        } else if (state is VisitBaseState && state.user == null) {
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
                  style: const TextStyle(
                      color: AppColors.main,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
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
    context: parentContext,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      return VisitScreen(
          userId: userId,
          parentContext: parentContext,
          chat: chat,
          showBackButton: showBackButton);
    },
  );
}
