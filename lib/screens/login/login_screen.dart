import 'dart:io';

import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/repository/login_repository.dart';
import 'package:chat/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../onboarding_name/onboarding_name_screen.dart';
import '../../onboarding_photo/onboarding_photo_screen.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../onboarding_gender/onboarding_gender_screen.dart';
import 'bloc/login_bloc.dart';
import 'bloc/login_event.dart';
import 'bloc/login_state.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = "/login_screen";

  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LoginRepository loginRepository =
        Provider.of<LoginRepository>(context);
    final FirestoreRepository firestoreRepository =
        Provider.of<FirestoreRepository>(context);
    return BlocProvider(
      create: (BuildContext context) =>
          LoginBloc(loginRepository, firestoreRepository),
      child: const LoginScreenBuilder(),
    );
  }
}

class LoginScreenBuilder extends StatelessWidget {
  const LoginScreenBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoginScreenContent();
  }
}

class LoginScreenContent extends StatelessWidget {
  static const routeName = "/login_screen";

  const LoginScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccessState) {
          if (state.navigation == OnboardingNavigation.DONE) {
            Navigator.pushReplacementNamed(context, HomeScreen.routeName);
          } else if (state.navigation == OnboardingNavigation.PICTURE) {
            Navigator.pushReplacementNamed(
                context, OnboardingPhotoScreen.routeName);
          } else if (state.navigation == OnboardingNavigation.GENDER) {
            Navigator.pushReplacementNamed(
                context, OnboardingGenderScreen.routeName);
          } else if (state.navigation == OnboardingNavigation.NAME) {
            Navigator.pushReplacementNamed(
                context, OnboardingNameScreen.routeName);
          }
        } else if (state is LoginErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login failed"),
            ),
          );
        } else if (state is LoginAbortedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login aborted"),
            ),
          );
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          if (state is LoginBaseState ||
              state is LoginErrorState ||
              state is LoginAbortedState) {
            return showBaseUi(context);
          } else {
            return const Center(
              child: AppSpinner(),
            );
          }
        },
      ),
    ));
  }

  ListView showBaseUi(BuildContext context) {
    return ListView(children: [
      Column(
        children: <Widget>[
          Column(
            children: [
              SignInButton(
                Buttons.Email,
                onPressed: () {
                  BlocProvider.of<LoginBloc>(context)
                      .add(LoginGuestClickedEvent());
                },
                text: FlutterI18n.translate(context, "continue_guest"),
              ),
              const SizedBox(height: 10),
              SignInButton(
                Buttons.Google,
                onPressed: () {
                  BlocProvider.of<LoginBloc>(context)
                      .add(LoginGoogleClickedEvent());
                },
                text: FlutterI18n.translate(context, "continue_google"),
              ),
              const SizedBox(height: 10),
              (Platform.isIOS)
                  ? SignInButton(
                      Buttons.Apple,
                      onPressed: () {
                        BlocProvider.of<LoginBloc>(context)
                            .add(LoginAppleClickedEvent());
                      },
                      text: FlutterI18n.translate(context, "continue_apple"),
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 10),
              SignInButton(
                Buttons.Facebook,
                onPressed: () {
                  BlocProvider.of<LoginBloc>(context)
                      .add(LoginFacebookClickedEvent());
                  //loginWithFacebook(context);
                },
                text: FlutterI18n.translate(context, "continue_facebook"),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  FlutterI18n.translate(context, "terms_intro"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.black),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _launchURL('https://fira-app.com/int-policy');
                },
                child: Text(
                  FlutterI18n.translate(context, "terms"),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    ]);
  }

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
}
