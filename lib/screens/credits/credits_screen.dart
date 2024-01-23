import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../model/message.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import 'bloc/credits_bloc.dart';
import 'bloc/credits_state.dart';

class CreditsScreen extends StatelessWidget {
  final BuildContext parentContext;

  const CreditsScreen({Key? key, required this.parentContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          CreditsBloc(context.read<FirestoreRepository>()),
      child: CreditsScreenBuilder(parentContext: parentContext),
    );
  }
}

class CreditsScreenBuilder extends StatelessWidget {
  final BuildContext parentContext;

  const CreditsScreenBuilder({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreditsBloc, CreditsState>(
      listener: (context, state) {},
      child:
          BlocBuilder<CreditsBloc, CreditsState>(builder: (blocContext, state) {
        if (state is CreditsBaseState) {
          return Container(
            width: double.infinity,
            decoration: getDecoration(),
            child: SafeArea(
              child: Padding(
                  padding:
                      EdgeInsets.only(left: 30, bottom: 10, top: 10, right: 30),
                  child: Column(
                    children: [
                      Lottie.asset('assets/lottie/chest.json',
                          width: 200, height: 200),
                    ],
                  )),
            ),
          );
        } else {
          return Container(
            width: double.infinity,
            height: 100,
            decoration: getDecoration(),
            child: const Center(
              child: AppSpinner(),
            ),
          );
        }
      }),
    );
  }

  BoxDecoration getDecoration() {
    return const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)));
  }
}

Future showCreditsScreen(BuildContext parentContext) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    isScrollControlled: true,
    context: parentContext,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: CreditsScreen(
          parentContext: parentContext,
        ),
      );
    },
  );
}
