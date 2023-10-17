import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/repository/login_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:lottie/lottie.dart';
import 'package:universal_io/io.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../chat/chat_screen.dart';
import '../message_holder/message_holder_screen.dart';
import '../onboarding_gender/onboarding_gender_screen.dart';
import '../onboarding_name/onboarding_name_screen.dart';
import '../onboarding_photo/onboarding_photo_screen.dart';
import 'bloc/login_bloc.dart';
import 'bloc/login_event.dart';
import 'bloc/login_state.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = "/login_screen";

  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginBloc(
          context.read<LoginRepository>(), context.read<FirestoreRepository>()),
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
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacementNamed(
                context, MessageHolderScreen.routeName);
          } else if (state.navigation == OnboardingNavigation.PICTURE) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacementNamed(
                context, OnboardingPhotoScreen.routeName);
          } else if (state.navigation == OnboardingNavigation.GENDER) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacementNamed(
                context, OnboardingGenderScreen.routeName);
          } else if (state.navigation == OnboardingNavigation.NAME) {
            Navigator.of(context).popUntil((route) => route.isFirst);
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

  Widget showBaseUi(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Lottie.network(
                "https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/lottie%2Fwelcome.json?alt=media&token=8c63f728-d463-4af0-b3cc-41066bea4600",
              ),
            ),
            Text(
              FlutterI18n.translate(context, "app_name"),
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.merge(const TextStyle(color: AppColors.main)),
            ),
            Text(
              FlutterI18n.translate(context, "chat_rooms_intro"),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
                onPressed: () {
                  BlocProvider.of<LoginBloc>(context)
                      .add(LoginGuestClickedEvent());
                },
                icon: const Icon(Icons.person),
                label: Text(
                  FlutterI18n.translate(context, 'continue_guest'),
                  style: Theme.of(context).textTheme.bodyMedium,
                )),
            const SizedBox(height: 20),
            ElevatedButton.icon(
                onPressed: () {
                  BlocProvider.of<LoginBloc>(context)
                      .add(LoginGoogleClickedEvent());
                },
                icon: Image.asset(
                  "assets/img/google.png",
                  height: 24,
                ),
                label: Text(
                  FlutterI18n.translate(context, 'continue_google'),
                  style: Theme.of(context).textTheme.bodyMedium,
                )),
            if (kIsWeb || Platform.isIOS) const SizedBox(height: 20),
            if (kIsWeb || Platform.isIOS)
              ElevatedButton.icon(
                  onPressed: () {
                    BlocProvider.of<LoginBloc>(context)
                        .add(LoginAppleClickedEvent());
                  },
                  icon: Image.asset(
                    "assets/img/apple.png",
                    height: 24,
                  ),
                  label: Text(
                    FlutterI18n.translate(context, 'continue_apple'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  )),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Text(
                FlutterI18n.translate(context, "terms_intro"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/terms_screen");
              },
              child: Text('${FlutterI18n.translate(context, "terms")},',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.merge(
                        const TextStyle(color: AppColors.main),
                      )),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/privacy_screen");
              },
              child: Text(FlutterI18n.translate(context, "privacy"),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.merge(
                        const TextStyle(color: AppColors.main),
                      )),
            ),
            Text(
              FlutterI18n.translate(context, "and"),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/eula_screen");
              },
              child: Text(FlutterI18n.translate(context, "eula"),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.merge(
                        const TextStyle(color: AppColors.main),
                      )),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
