import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../error/error_screen.dart';
import '../loading/loading_screen.dart';
import 'bloc/Home_state.dart';
import 'bloc/home_bloc.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = "/home_screen";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => HomeBloc(),
      child: const HomeScreenBuilder(),
    );
  }
}

class HomeScreenBuilder extends StatelessWidget {
  const HomeScreenBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {},
        child: BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
          if (state is HomeErrorState) {
            return const ErrorScreen();
          } else {
            return const LoadingScreen();
          }
        }));
  }
}
