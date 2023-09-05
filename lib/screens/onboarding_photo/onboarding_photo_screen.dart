import 'dart:io';

import 'package:chat/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../repository/firestore_repository.dart';
import '../../repository/storage_repository.dart';
import '../../utils/app_widgets.dart';
import '../chat/chat_screen.dart';
import '../login/bloc/login_state.dart';
import '../onboarding_gender/onboarding_gender_screen.dart';
import 'bloc/onboarding_photo_bloc.dart';
import 'bloc/onboarding_photo_event.dart';
import 'bloc/onboarding_photo_state.dart';

class OnboardingPhotoScreen extends StatelessWidget {
  static const routeName = "/onboarding_photo_screen";

  const OnboardingPhotoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => OnboardingPhotoBloc(
          context.read<FirestoreRepository>(),
          context.read<StorageRepository>()),
      child: const OnboardingPhotoScreenContent(),
    );
  }
}

class OnboardingPhotoScreenContent extends StatelessWidget {
  const OnboardingPhotoScreenContent({super.key});

  @override
  Widget build(BuildContext appContext) {
    return Scaffold(
        body: BlocListener<OnboardingPhotoBloc, OnboardingPhotoState>(
      listener: (context, state) {
        if (state is OnboardingPhotoRedoState) {
          _showBottomSheet(appContext);
        } else if (state is OnboardingPhotoSuccessState) {
          if (state.navigation == OnboardingNavigation.PICTURE) {
            Navigator.pushReplacementNamed(
                context, OnboardingPhotoScreen.routeName);
          } else if (state.navigation == OnboardingNavigation.GENDER) {
            Navigator.pushReplacementNamed(
                context, OnboardingGenderScreen.routeName);
          } else if (state.navigation == OnboardingNavigation.DONE) {
            Navigator.pushReplacementNamed(context, ChatScreen.routeName);
          }
        }
      },
      child: BlocBuilder<OnboardingPhotoBloc, OnboardingPhotoState>(
        builder: (context, state) {
          if (state is OnboardingPhotoBaseState) {
            return showBaseUi(context, state);
          } else if (state is OnboardingPhotoDoneState) {
            return showPhotoTakenUi(context, state);
          } else {
            return const Center(
              child: AppSpinner(),
            );
          }
        },
      ),
    ));
  }

  Widget showBaseUi(BuildContext context, OnboardingPhotoBaseState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              '${state.name},',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 44,
                color: AppColors.main,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Center(
            child: Text(
              FlutterI18n.translate(context, "say_cheese"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 44,
                color: AppColors.grey_1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 70, right: 70, top: 20, bottom: 20),
            child: Center(
              child: Text(
                FlutterI18n.translate(context, "lets_take_picture"),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.grey_1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<OnboardingPhotoBloc>(context)
                  .add(OnboardingPhotoCameraClickedEvent());
            },
            child: Text(FlutterI18n.translate(context, "take_a_picture")),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<OnboardingPhotoBloc>(context)
                  .add(OnboardingPhotoGalleryClickedEvent());
            },
            child: Text(FlutterI18n.translate(context, "select_from_images")),
          ),
          const SizedBox(height: 20),
          Text(FlutterI18n.translate(context, 'or')),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<OnboardingPhotoBloc>(context)
                  .add(OnboardingPhotoSkipEvent());
            },
            child: Text(FlutterI18n.translate(context, "skip_this_step")),
          )
        ],
      ),
    );
  }

  Widget showPhotoTakenUi(
      BuildContext context, OnboardingPhotoDoneState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          Center(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(70.0),
                  child: (state.filePath.isNotEmpty)
                      ? SizedBox(
                          width: 140,
                          height: 140,
                          child: CircleAvatar(
                              backgroundImage: FileImage(
                                  File.fromUri(Uri.parse(state.filePath)))))
                      : const Icon(Icons.camera_alt_outlined))),
          const SizedBox(height: 20),
          Center(
            child: Text(
              FlutterI18n.translate(context, "you_look_good"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 44,
                color: AppColors.main,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Center(
            child: Text(
              FlutterI18n.translate(context, "as_always"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 44,
                color: AppColors.grey_1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 70, right: 70, top: 20, bottom: 20),
            child: Center(
              child: Text(
                FlutterI18n.translate(context, "continue_if_happy"),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.grey_1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<OnboardingPhotoBloc>(context)
                  .add(OnboardingPhotoContinueClickedEvent());
            },
            child: Text(FlutterI18n.translate(context, "continue")),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () {
              BlocProvider.of<OnboardingPhotoBloc>(context)
                  .add(OnboardingPhotoRedoClickedEvent());
            },
            child: Text(FlutterI18n.translate(context, "take_new_picture"),
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.main)),
          )
        ],
      ),
    );
  }

  void _showBottomSheet(BuildContext appContext) async {
    await showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      context: appContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Text(
              FlutterI18n.translate(context, "select_source"),
              style: const TextStyle(
                  color: AppColors.grey_1,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
            const SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                getOptionWidget(
                    appContext,
                    FlutterI18n.translate(context, "camera"),
                    '',
                    const Icon(Icons.camera_alt, size: 30, color: Colors.black),
                    20,
                    8, () async {
                  Navigator.of(appContext).pop();
                  BlocProvider.of<OnboardingPhotoBloc>(appContext)
                      .add(OnboardingPhotoCameraClickedEvent());
                }),
                getOptionWidget(
                    appContext,
                    FlutterI18n.translate(context, "images"),
                    '',
                    const Icon(Icons.image, size: 30, color: Colors.black),
                    8,
                    20, () {
                  Navigator.of(appContext).pop();
                  BlocProvider.of<OnboardingPhotoBloc>(appContext)
                      .add(OnboardingPhotoGalleryClickedEvent());
                }),
              ],
            ),
            const SizedBox(height: 152),
          ],
        );
      },
    );
    BlocProvider.of<OnboardingPhotoBloc>(appContext)
        .add(OnboardingPhotoBottomSheetClosedEvent());
  }
}

Flexible getOptionWidget(
    BuildContext context,
    String title,
    String message,
    Icon icon,
    double paddingLeft,
    double paddingRight,
    VoidCallback onPressed) {
  return Flexible(
    child: Padding(
      padding: EdgeInsets.only(left: paddingLeft, right: paddingRight),
      child: Column(
        children: [
          SizedBox(
            width: 116,
            height: 116,
            child: ElevatedButton(
              style: ButtonStyle(
                elevation: MaterialStateProperty.all<double>(2.0),
                backgroundColor:
                    MaterialStateProperty.all<Color>(AppColors.white),
                overlayColor: MaterialStateProperty.resolveWith(
                  (states) {
                    return states.contains(MaterialState.pressed)
                        ? AppColors.main
                        : null;
                  },
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              child: Center(
                child: icon,
              ),
              onPressed: onPressed,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 128,
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                    color: AppColors.grey_1,
                    fontWeight: FontWeight.w600,
                    fontSize: 11),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 128,
            child: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.grey_1,
                    fontWeight: FontWeight.w400,
                    fontSize: 11),
              ),
            ),
          )
        ],
      ),
    ),
  );
}
