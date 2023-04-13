import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../home/home_screen.dart';
import '../login/bloc/login_state.dart';
import 'bloc/onboarding_gender_bloc.dart';
import 'bloc/onboarding_gender_event.dart';
import 'bloc/onboarding_gender_state.dart';

class OnboardingGenderScreen extends StatelessWidget {
  static const routeName = "/onboarding_gender_screen";

  const OnboardingGenderScreen({Key? key})
      : super(key: key);

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
            Navigator.pushReplacementNamed(context, HomeScreen.routeName);
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

  Stack showBaseUi(BuildContext context, OnboardingGenderBaseState state) {
    return Stack(
      children: [
        Opacity(
          opacity: 0.2,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
                transform: Matrix4.translationValues(-100.0, 0.0, 0.0),
                child: SvgPicture.asset("images/gfx_blob-yellow.svg")),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                  style: const TextStyle(
                    fontSize: 44,
                    color: AppColors.main,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    FlutterI18n.translate(context, "before_we_are_done"),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 44,
                      color: AppColors.grey_1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 70, right: 70, top: 20, bottom: 20),
                child: Center(
                  child: Text(
                    FlutterI18n.translate(context, "choose_what_identifies_as"),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.grey_1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              AppButton(
                onTap: () async {
                  BlocProvider.of<OnboardingGenderBloc>(context)
                      .add(OnboardingGenderFemaleClickedEvent());
                },
                width: 220,
                text: FlutterI18n.translate(context, "i_am_woman"),
              ),
              const SizedBox(height: 20),
              AppButton(
                onTap: () async {
                  BlocProvider.of<OnboardingGenderBloc>(context)
                      .add(OnboardingGenderMaleClickedEvent());
                },
                width: 220,
                text: FlutterI18n.translate(context, "i_am_man"),
              ),
              const SizedBox(height: 20),
              AppButton(
                onTap: () async {
                  BlocProvider.of<OnboardingGenderBloc>(context)
                      .add(OnboardingGenderNonBinaryClickedEvent());
                },
                width: 220,
                text: FlutterI18n.translate(context, "i_am_non_binary"),
              )
            ],
          ),
        ),
      ],
    );
  }
}
