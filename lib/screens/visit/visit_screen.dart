import 'dart:async';
import 'package:chat/repository/firestore_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../hero/hero_screen.dart';
import '../message_holder/bloc/message_holder_bloc.dart';
import '../message_holder/bloc/message_holder_event.dart';
import 'bloc/visit_bloc.dart';
import 'bloc/visit_state.dart';

class VisitScreen extends StatelessWidget {
  final String _userId;
  final BuildContext parentContext;

  const VisitScreen(this._userId, {required this.parentContext, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          VisitBloc(context.read<FirestoreRepository>(), _userId),
      child: VisitScreenContent(parentContext),
    );
  }
}

const viewHeight = 400.0;

class VisitScreenContent extends StatelessWidget {
  final BuildContext parentContext;

  const VisitScreenContent(this.parentContext, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitBloc, VisitState>(
      listener: (context, state) {},
      child: BlocBuilder<VisitBloc, VisitState>(builder: (context, state) {
        if (state is VisitBaseState) {
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
                const SizedBox(height: 20),
                Center(
                    child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, HeroScreen.routeName,
                        arguments: HeroScreenArguments(state.user.pictureData));
                  },
                  child: Hero(
                    tag: "imageHero",
                    child: AppUserImage(
                      state.user.pictureData,
                      size: 110,
                    ),
                  ),
                )),
                const SizedBox(height: 20),
                Center(
                    child: Text(
                  state.user.displayName,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey_1),
                )),
                const SizedBox(height: 40),
                AppButton(
                    height: 50,
                    width: 200,
                    text: FlutterI18n.translate(context, 'private_chat'),
                    onTap: () {
                      Navigator.pop(context);
                      BlocProvider.of<MessageHolderBloc>(parentContext)
                          .add(MessageHolderPrivateChatEvent(state.user));
                    })
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

Future showVisitScreen(BuildContext parentContext, String userId) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    context: parentContext,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      return VisitScreen(userId, parentContext: parentContext);
    },
  );
}
