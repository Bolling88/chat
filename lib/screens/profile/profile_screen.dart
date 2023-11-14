//a bloc builder widget class for creating a chat
import 'package:chat/screens/login/login_screen.dart';
import 'package:chat/screens/onboarding_name/onboarding_name_screen.dart';
import 'package:chat/utils/gender.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/flag.dart';
import '../../utils/lottie.dart';
import '../../utils/translate.dart';
import '../feedback/feedback_screen.dart';
import '../messages/other_message_widget.dart';
import '../onboarding_gender/onboarding_gender_screen.dart';
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
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  child: AppUserImage(
                    url: state.user.pictureData,
                    gender: state.user.gender,
                    size: 120,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                        blocContext, OnboardingPhotoScreen.routeName,
                        arguments:
                            OnboardingPhotoScreenArguments(isEditMode: true));
                  },
                ),
                const SizedBox(height: 20),
                GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                          blocContext, OnboardingNameScreen.routeName,
                          arguments:
                              OnboardingNameScreenArguments(isEditMode: true));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.user.displayName,
                            textAlign: TextAlign.left,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.merge(TextStyle(
                                    color: getGenderColor(
                                        Gender.fromValue(state.user.gender))))),
                        if (state.user.gender != Gender.secret.value)
                          SizedBox(
                              width: 30,
                              height: 30,
                              child: AppLottie(
                                url: getGenderUrl(state.user.gender),
                                animate: false,
                              )),
                        const SizedBox(width: 2),
                        getFlag(
                            countryCode: state.user.countryCode, fontSize: 30),
                      ],
                    )),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    Navigator.pushNamed(
                        blocContext, OnboardingPhotoScreen.routeName,
                        arguments:
                            OnboardingPhotoScreenArguments(isEditMode: true));
                  },
                  label: Text(translate(context, 'change_image')),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushNamed(
                        blocContext, OnboardingNameScreen.routeName,
                        arguments:
                            OnboardingNameScreenArguments(isEditMode: true));
                  },
                  label: Text(translate(context, 'change_name')),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.psychology_rounded),
                  onPressed: () {
                    Navigator.pushNamed(
                        blocContext, OnboardingGenderScreen.routeName,
                        arguments:
                        OnboardingGenderScreenArguments(isEditMode: true));
                  },
                  label: Text(translate(context, 'change_gender')),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.feedback),
                  onPressed: () {
                    showFeedbackScreen(blocContext, state.user);
                  },
                  label: Text(translate(context, 'leave_feedback')),
                ),
                Expanded(child: Container()),
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
                TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return getDeleteAccountDialog(blocContext, context);
                        });
                  },
                  child: Text(translate(context, 'delete_account')),
                ),
                const SizedBox(height: 20),
              ],
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
          child: Text(translate(context, 'yes').toUpperCase()),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(translate(context, 'no').toUpperCase()),
        ),
      ],
    );
  }

  AlertDialog getDeleteAccountDialog(
      BuildContext blocContext, BuildContext context) {
    return AlertDialog(
      title: Text(translate(context, 'delete_account'),
          style: const TextStyle(color: AppColors.red)),
      content: Text(translate(context, 'delete_account_info')),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            BlocProvider.of<ProfileBloc>(blocContext)
                .add(ProfileDeleteAccountEvent());
          },
          child: Text(translate(context, 'yes').toUpperCase()),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(translate(context, 'no').toUpperCase()),
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
