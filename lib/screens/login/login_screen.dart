import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/error_screen.dart';
import '../loading/loading_screen.dart';
import 'bloc/login_bloc.dart';
import 'bloc/login_state.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = "/login_screen";
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => LoginBloc(),
      child: const LoginScreenBuilder(),
    );
  }
}

class LoginScreenBuilder extends StatelessWidget {
  const LoginScreenBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {},
        child: BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
          if (state is LoginErrorState) {
            return const ErrorScreen();
          } else {
            return const LoadingScreen();
          }
        }));
  }
}
