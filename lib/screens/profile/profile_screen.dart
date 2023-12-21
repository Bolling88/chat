//a bloc builder widget class for creating a chat
import 'package:chat/screens/login/login_screen.dart';
import 'package:chat/screens/onboarding_name/onboarding_name_screen.dart';
import 'package:chat/screens/review/review_screen.dart';
import 'package:chat/utils/gender.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/flag.dart';
import '../../utils/lottie.dart';
import '../../utils/translate.dart';
import '../account/account_screen.dart';
import '../feedback/feedback_screen.dart';
import '../messages/other_message_widget.dart';
import '../onboarding_age/onboarding_age_screen.dart';
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
      body: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {},
          child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (blocContext, state) {
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
                        approvalState: ApprovedImage.approved,
                        imageReports: const [],
                        size: 120,
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                            blocContext, OnboardingPhotoScreen.routeName,
                            arguments: OnboardingPhotoScreenArguments(
                                isEditMode: true));
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            blocContext, OnboardingNameScreen.routeName,
                            arguments: OnboardingNameScreenArguments(
                                isEditMode: true));
                      },
                      child: getProfileRow(
                        displayName: state.user.displayName,
                        gender: state.user.gender,
                        countryCode: state.user.countryCode,
                        birthDate: state.user.birthDate,
                        showAge: state.user.showAge,
                        context: context,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () {
                        Navigator.pushNamed(
                            blocContext, OnboardingPhotoScreen.routeName,
                            arguments: OnboardingPhotoScreenArguments(
                                isEditMode: true));
                      },
                      label: Text(translate(context, 'change_image')),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.pushNamed(
                            blocContext, OnboardingNameScreen.routeName,
                            arguments: OnboardingNameScreenArguments(
                                isEditMode: true));
                      },
                      label: Text(translate(context, 'change_name')),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.psychology_rounded),
                      onPressed: () {
                        Navigator.pushNamed(
                            blocContext, OnboardingGenderScreen.routeName,
                            arguments: OnboardingGenderScreenArguments(
                                isEditMode: true));
                      },
                      label: Text(translate(context, 'change_gender')),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.psychology_rounded),
                      onPressed: () {
                        Navigator.pushNamed(
                            blocContext, OnboardingAgeScreen.routeName,
                            arguments:
                                OnboardingAgeScreenArguments(isEditMode: true));
                      },
                      label: Text(translate(context, 'change_age')),
                    ),
                    const SizedBox(height: 20),
                    if(state.user.birthDate != null)
                    GestureDetector(
                      onTap: () {
                        BlocProvider.of<ProfileBloc>(context).add(
                            ProfileShowAgeChangedEvent(
                                !(state.user.showAge)));
                      },
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Checkbox(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          value: state.user.showAge,
                          onChanged: (newValue) {
                            BlocProvider.of<ProfileBloc>(context).add(
                                ProfileShowAgeChangedEvent(newValue ?? true));
                          },
                        ),
                        Text(FlutterI18n.translate(context, 'show_age')),
                      ]),
                    ),
                    Expanded(
                        child: AppLottie(
                            url:
                                'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/lottie%2Fowl.json?alt=media&token=66af91c7-1926-4abd-94e7-aa519acd7674')),
                  ],
                ),
              );
            } else {
              return const AppLoadingScreen();
            }
          })),
    );
  }
}
