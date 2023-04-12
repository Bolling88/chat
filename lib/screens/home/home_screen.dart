import 'package:chat/screens/home/bloc/home_bloc.dart';
import 'package:chat/screens/home/bloc/home_state.dart';
import 'package:chat/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/login_repository.dart';
import '../../utils/custom_side_menu.dart';
import '../error/error_screen.dart';
import '../login/login_screen.dart';

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
    PageController page = PageController();
    return BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {},
        child: BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
          if (state is HomeBaseState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Chat'),
                backgroundColor: AppColors.main,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Navigator.of(context).pop();
                      FirebaseAuth.instance.signOut().then((value) => {
                            Navigator.pushNamedAndRemoveUntil(context,
                                LoginScreen.routeName, (route) => false)
                          });
                    },
                  )
                ],
              ),
              body: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        getChatButton(true),
                        getChatButton(false),
                        getChatButton(false)
                      ],
                    ),
                    Expanded(
                      child: PageView(
                        controller: page,
                        children: const [
                          Center(
                            child: Text('Dashboard'),
                          ),
                          Center(
                            child: Text('Lina'),
                          ),
                          Center(
                            child: Text('Erik'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const ErrorScreen();
          }
        }));
  }

  Container getChatButton(bool isActive) {
    return Container(
      width: 50.0,
      height: 50.0,
      child: const Center(child: Text('Hem')),
      decoration: BoxDecoration(
        color: isActive ? AppColors.main : AppColors.grey_1,
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
      ),
    );
  }
}
