import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../error/error_screen.dart';
import '../home/home_screen.dart';
import '../loading/loading_screen.dart';
import '../login/login_screen.dart';
import 'bloc/splash_bloc.dart';
import 'bloc/splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => SplashBloc(),
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
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      } else if (state is SplashSuccessState) {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
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
