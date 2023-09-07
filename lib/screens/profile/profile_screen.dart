//a bloc builder widget class for creating a chat
import 'package:chat/screens/login/login_screen.dart';
import 'package:chat/utils/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/dialogs.dart';
import '../../utils/translate.dart';
import '../onboarding_photo/onboarding_photo_screen.dart';
import 'bloc/profile_bloc.dart';
import 'bloc/profile_event.dart';
import 'bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = "/profile_screen";

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          ProfileBloc(context.read<FirestoreRepository>()),
      child: const ProfileScreenBuilder(),
    );
  }
}

class ProfileScreenBuilder extends StatelessWidget {
  const ProfileScreenBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          translate(context, 'profile'),
        ),
      ),
      body: BlocListener<ProfileBloc, ProfileState>(listener: (context, state) {
        if (state is ProfileLogoutState) {
          exitToLogin(context);
        }
      }, child:
          BlocBuilder<ProfileBloc, ProfileState>(builder: (blocContext, state) {
        if (state is ProfileErrorState) {
          return const AppErrorScreen();
        } else if (state is ProfileBaseState) {
          return SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.user.pictureData != null &&
                      state.user.pictureData != 'nan')
                    const SizedBox(height: 20),
                  if (state.user.pictureData != null &&
                      state.user.pictureData != 'nan')
                    GestureDetector(
                      child: AppUserImage(
                        state.user.pictureData,
                        size: 120,
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                            blocContext, OnboardingPhotoScreen.routeName);
                      },
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                      Navigator.pushNamed(
                          blocContext, OnboardingPhotoScreen.routeName);
                    },
                    label: Text(translate(context, 'change_image')),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return getSignOutDialog(blocContext);
                          });
                    },
                    label: Text(translate(context, 'sign_out')),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return getDeleteAccountDialog(blocContext, context);
                          });
                    },
                    label: Text(translate(context, 'delete_account')),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const AppLoadingScreen();
        }
      })),
    );
  }

  AlertDialog getSignOutDialog(BuildContext context) {
    return AlertDialog(
      title: Text(translate(context, 'sign_out')),
      content: Text(translate(context, 'sign_out_info')),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            BlocProvider.of<ProfileBloc>(context).add(ProfileLogoutEvent());
          },
          child: Text(translate(context, 'yes')),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(translate(context, 'no')),
        ),
      ],
    );
  }

  AlertDialog getDeleteAccountDialog(
      BuildContext blocContext, BuildContext context) {
    return AlertDialog(
      title: Text(translate(context, 'delete_account')),
      content: Text(translate(context, 'delete_account_info')),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            BlocProvider.of<ProfileBloc>(blocContext)
                .add(ProfileDeleteAccountEvent());
          },
          child: Text(translate(context, 'yes')),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(translate(context, 'no')),
        ),
      ],
    );
  }

  void exitToLogin(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context, rootNavigator: true)
        .pushReplacementNamed(LoginScreen.routeName);
  }
}
