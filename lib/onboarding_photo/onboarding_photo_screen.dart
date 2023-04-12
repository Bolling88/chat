import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_map_test/constants.dart';
import 'package:flutter_map_test/repository/firestore_repository.dart';
import 'package:flutter_map_test/repository/storage_repository.dart';
import 'package:flutter_map_test/screens/login/bloc/login_state.dart';
import 'package:flutter_map_test/screens/onboarding_gender/onboarding_gender_screen.dart';
import 'package:flutter_map_test/screens/onboarding_photo/bloc/onboarding_photo_bloc.dart';
import 'package:flutter_map_test/screens/onboarding_photo/bloc/onboarding_photo_event.dart';
import 'package:flutter_map_test/screens/onboarding_photo/bloc/onboarding_photo_state.dart';
import 'package:flutter_map_test/screens/tabs/tabs_screen.dart';
import 'package:flutter_map_test/utils/app_widgets.dart';
import 'package:flutter_svg/svg.dart';

import '../invited/invited_screen.dart';

class OnboardingPhotoScreen extends StatelessWidget {
  static const routeName = "/onboarding_photo_screen";
  final FirestoreRepository firestoreRepository;
  final StorageRepository _storageRepository;

  const OnboardingPhotoScreen(this.firestoreRepository, this._storageRepository, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          OnboardingPhotoBloc(firestoreRepository, _storageRepository),
      child: OnboardingPhotoScreenContent(),
    );
  }
}

class OnboardingPhotoScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext appContext) {
    return Scaffold(
        body: BlocListener<OnboardingPhotoBloc, OnboardingPhotoState>(
      listener: (context, state) {
        if(state is OnboardingPhotoRedoState){
          _showBottomSheet(appContext);
        }
        else if (state is OnboardingPhotoSuccessState) {
          if (state.navigation == OnboardingNavigation.PICTURE) {
            Navigator.pushReplacementNamed(
                context, OnboardingPhotoScreen.routeName);
          } else if (state.navigation == OnboardingNavigation.GENDER) {
            Navigator.pushReplacementNamed(
                context, OnboardingGenderScreen.routeName);
          } else if (state.navigation == OnboardingNavigation.DONE) {
            Navigator.pushReplacementNamed(context, TabsScreen.routeName);
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
            return Center(
              child: AppSpinner(),
            );
          }
        },
      ),
    ));
  }

  Stack showBaseUi(BuildContext context, OnboardingPhotoBaseState state) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.1,
              child: Center(
                child: Container(
                    transform: Matrix4.translationValues(-100.0, 250.0, 0.0),
                    child: SvgPicture.asset("images/gfx_blob-blue.svg")),
              ),
            ),
          ],
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  '${state.name},',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 44,
                    color: AppColors.pink_main,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Center(
                child: Text(
                  FlutterI18n.translate(context, "say_cheese"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 44,
                    color: AppColors.grey5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(left: 70, right: 70, top: 20, bottom: 20),
                child: Center(
                  child: Text(FlutterI18n.translate(context, "lets_take_picture"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.grey7,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              AppButton(
                onTap: () async {
                  BlocProvider.of<OnboardingPhotoBloc>(context)
                      .add(OnboardingPhotoCameraClickedEvent());
                },
                width: 220,
                text: FlutterI18n.translate(context, "take_a_picture"),
              ),
              SizedBox(height: 20),
              AppButton(
                onTap: () async {
                  BlocProvider.of<OnboardingPhotoBloc>(context)
                      .add(OnboardingPhotoGalleryClickedEvent());
                },
                width: 220,
                text: FlutterI18n.translate(context, "select_from_images"),
              )
            ],
          ),
        ),
      ],
    );
  }

  Stack showPhotoTakenUi(BuildContext context, OnboardingPhotoDoneState state) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.1,
              child: Center(
                child: Container(
                    transform: Matrix4.translationValues(160.0, 350.0, 0.0),
                    child: SvgPicture.asset("images/gfx_blob-purple.svg")),
              ),
            ),
          ],
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Center(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(70.0),
                      child: (state.filePath.isNotEmpty)
                          ? Container(
                              width: 140,
                              height: 140,
                              child: CircleAvatar(
                                  backgroundImage:
                                      new FileImage(File(state.filePath))))
                          : Icon(Icons.camera_alt_outlined))),
              SizedBox(height: 20),
              Center(
                child: Text(
                  FlutterI18n.translate(context, "you_look_good"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 44,
                    color: AppColors.pink_main,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Center(
                child: Text(FlutterI18n.translate(context, "as_always"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 44,
                    color: AppColors.grey5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(left: 70, right: 70, top: 20, bottom: 20),
                child: Center(
                  child: Text(FlutterI18n.translate(context, "continue_if_happy"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.grey7,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              AppButton(
                onTap: () async {
                  BlocProvider.of<OnboardingPhotoBloc>(context)
                      .add(OnboardingPhotoContinueClickedEvent());
                },
                width: 220,
                text: FlutterI18n.translate(context, "continue"),
              ),
              SizedBox(height: 20),
              TextButton(onPressed: (){
                BlocProvider.of<OnboardingPhotoBloc>(context)
                    .add(OnboardingPhotoRedoClickedEvent());
              }, child: Text(FlutterI18n.translate(context, "take_new_picture"), style: TextStyle(fontWeight: FontWeight.w600, color:  AppColors.pink4)),)
            ],
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(BuildContext appContext) async {
    await showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      context: appContext,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 24),
            Text(
              FlutterI18n.translate(context, "add_album"),
              style: TextStyle(
                  color: AppColors.grey5,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
            SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                getOptionWidget(
                    appContext,
                    FlutterI18n.translate(context, "camera"),
                    '',
                    'images/upload_camera.svg',
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
                    'images/upload_images.svg',
                    8,
                    20, () {
                  Navigator.of(appContext).pop();
                  BlocProvider.of<OnboardingPhotoBloc>(appContext)
                      .add(OnboardingPhotoGalleryClickedEvent());
                }),
              ],
            ),
            SizedBox(height: 152),
          ],
        );
      },
    );
    BlocProvider.of<OnboardingPhotoBloc>(appContext)
        .add(OnboardingPhotoBottomSheetClosedEvent());
  }
}
