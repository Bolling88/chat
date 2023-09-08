import 'package:chat/screens/chat/chat_screen.dart';
import 'package:chat/utils/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../login/bloc/login_state.dart';
import 'bloc/onboarding_gender_bloc.dart';
import 'bloc/onboarding_gender_event.dart';
import 'bloc/onboarding_gender_state.dart';

class OnboardingGenderScreen extends StatelessWidget {
  static const routeName = "/onboarding_gender_screen";

  const OnboardingGenderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          OnboardingGenderBloc(context.read<FirestoreRepository>()),
      child: const OnboardingGenderScreenContent(),
    );
  }
}

class OnboardingGenderScreenContent extends StatelessWidget {
  const OnboardingGenderScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocListener<OnboardingGenderBloc, OnboardingGenderState>(
      listener: (context, state) {
        if (state is OnboardingGenderSuccessState) {
          if (state.navigation == OnboardingNavigation.DONE) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacementNamed(context, ChatScreen.routeName);
          }
        }
      },
      child: BlocBuilder<OnboardingGenderBloc, OnboardingGenderState>(
        builder: (context, state) {
          if (state is OnboardingGenderBaseState) {
            return showBaseUi(context, state);
          } else {
            return const Center(
              child: AppSpinner(),
            );
          }
        },
      ),
    ));
  }

  Widget showBaseUi(BuildContext context, OnboardingGenderBaseState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.filePath.isNotEmpty && state.filePath != "nan")
            Center(
                child: AppUserImage(
              state.filePath,
              size: 110,
            )),
          const SizedBox(height: 20),
          Center(
            child: Text(
              FlutterI18n.translate(context, "one_more_thing"),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Text(
                FlutterI18n.translate(context, "before_we_are_done"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 70, right: 70, top: 30, bottom: 20),
            child: Center(
              child: Text(
                FlutterI18n.translate(context, "choose_what_identifies_as"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 30),
          getGenderButton(
              context: context,
              title: FlutterI18n.translate(context, "i_am_woman"),
              url:
                  'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/lottie%2Ffemale.json?alt=media&token=dabc5dd7-3f5e-446a-9f69-1325a343ce90'),
          const SizedBox(height: 20),
          getGenderButton(
              context: context,
              title: FlutterI18n.translate(context, "i_am_man"),
              url:
              'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/lottie%2Fmale.json?alt=media&token=0a7e6edf-2112-471f-b5ef-d07fac83a9b3'),
          const SizedBox(height: 20),
          getGenderButton(
              context: context,
              title: FlutterI18n.translate(context, "i_am_non_binary"),
              url:
                  'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/lottie%2Fnon_binary.json?alt=media&token=8c63f728-d463-4af0-b3cc-41066bea4600'),
        ],
      ),
    );
  }

  ElevatedButton getGenderButton(
      {required BuildContext context, required String url, required String title}) {
    return ElevatedButton(
      onPressed: () {
        BlocProvider.of<OnboardingGenderBloc>(context)
            .add(OnboardingGenderNonBinaryClickedEvent());
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          SizedBox(
            width: 20,
            height: 20,
            child: AppLottie(url: url),
          )
        ],
      ),
    );
  }
}
