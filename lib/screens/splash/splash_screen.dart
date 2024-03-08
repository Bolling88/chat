import 'package:chat/screens/message_holder/message_holder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/firestore_repository.dart';
import '../error/error_screen.dart';
import '../loading/loading_screen.dart';
import '../login/bloc/login_state.dart';
import '../login/login_screen.dart';
import 'bloc/splash_bloc.dart';
import 'bloc/splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          SplashBloc(context.read<FirestoreRepository>()),
      child: const SplashScreenBuilder(),
    );
  }
}

class SplashScreenBuilder extends StatelessWidget {
  const SplashScreenBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(listener: (context, state) {
      if (state is SplashLoginState) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      } else if (state is SplashSuccessState) {
        if (state.navigation == OnboardingNavigation.done) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (c, a1, a2) => const MessageHolderScreen(),
              transitionsBuilder: (c, anim, a2, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 2000),
            ),
          );
        }
      }
    }, child: BlocBuilder<SplashBloc, SplashState>(builder: (context, state) {
      if (state is SplashErrorState) {
        return const ErrorScreen();
      } else {
        return const LoadingScreen();
      }
    }));
  }
}
