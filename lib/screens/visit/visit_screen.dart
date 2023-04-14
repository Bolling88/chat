import 'dart:async';
import 'package:chat/repository/data_repository.dart';
import 'package:chat/repository/firestore_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../hero/hero_screen.dart';
import 'bloc/visit_bloc.dart';
import 'bloc/visit_state.dart';

class VisitScreen extends StatelessWidget {
  static const routeName = "/visit_screen";
  final String _userId;

  const VisitScreen(this._userId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          VisitBloc(context.read<FirestoreRepository>(), _userId),
      child: VisitScreenContent(context),
    );
  }
}

class VisitScreenContent extends StatelessWidget {
  final BuildContext mapContext;

  const VisitScreenContent(this.mapContext, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<VisitBloc, VisitState>(
      listener: (context, state) {},
      child: BlocBuilder<VisitBloc, VisitState>(builder: (context, state) {
        if (state is VisitBaseState) {
          return SingleChildScrollView(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 150),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 80),
                        Center(
                            child: Text(
                          state.user.displayName,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey_1),
                        )),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Center(
                      child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, HeroScreen.routeName,
                          arguments:
                              HeroScreenArguments(state.user.pictureData));
                    },
                    child: Hero(
                      tag: "imageHero",
                      child: AppUserImage(
                        state.user.pictureData,
                        size: 110,
                      ),
                    ),
                  )),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox(
            width: double.infinity,
            height: 400,
            child: Center(
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

Future showVisitScreen(BuildContext context, String userId) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      return VisitScreen(userId);
    },
  );
}
