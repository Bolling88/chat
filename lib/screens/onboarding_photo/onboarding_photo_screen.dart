import 'package:chat/screens/message_holder/message_holder_screen.dart';
import 'package:chat/utils/app_colors.dart';
import 'package:chat/utils/image_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:universal_io/io.dart';
import '../../repository/firestore_repository.dart';
import '../../repository/storage_repository.dart';
import '../../utils/app_widgets.dart';
import '../login/bloc/login_state.dart';
import '../onboarding_gender/onboarding_gender_screen.dart';
import 'bloc/onboarding_photo_bloc.dart';
import 'bloc/onboarding_photo_event.dart';
import 'bloc/onboarding_photo_state.dart';

class OnboardingPhotoScreenArguments {
  final bool isEditMode;

  OnboardingPhotoScreenArguments({required this.isEditMode});
}

class OnboardingPhotoScreen extends StatelessWidget {
  static const routeName = "/onboarding_photo_screen";

  const OnboardingPhotoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppImageCropper appImageCropper = AppImageCropper(context);
    return BlocProvider(
      create: (BuildContext context) => OnboardingPhotoBloc(
          context.read<FirestoreRepository>(),
          context.read<StorageRepository>(),
          appImageCropper),
      child: const OnboardingPhotoScreenContent(),
    );
  }
}

class OnboardingPhotoScreenContent extends StatelessWidget {
  const OnboardingPhotoScreenContent({super.key});

  @override
  // ignore: avoid_renaming_method_parameters
  Widget build(BuildContext appContext) {
    final args = ModalRoute.of(appContext)?.settings.arguments
        as OnboardingPhotoScreenArguments?;
    final isEditMode = args?.isEditMode ?? false;

    return Scaffold(
        appBar: isEditMode
            ? AppBar(
                title: Text(
                  FlutterI18n.translate(appContext, "change_photo"),
                ),
              )
            : null,
        body: BlocListener<OnboardingPhotoBloc, OnboardingPhotoState>(
          listener: (context, state) {
            if (state is OnboardingPhotoRedoState) {
              showCameraOrImageBottomSheet(
                  parentContext: appContext,
                  onCameraPressed: () async {
                    Navigator.of(appContext).pop();
                    BlocProvider.of<OnboardingPhotoBloc>(appContext)
                        .add(OnboardingPhotoCameraClickedEvent());
                  },
                  onGalleryPressed: () async {
                    Navigator.of(appContext).pop();
                    BlocProvider.of<OnboardingPhotoBloc>(appContext)
                        .add(OnboardingPhotoGalleryClickedEvent());
                  });
            } else if (state is OnboardingPhotoSuccessState) {
              if (state.navigation == OnboardingNavigation.picture) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacementNamed(
                    context, OnboardingPhotoScreen.routeName);
              } else if (state.navigation == OnboardingNavigation.gender) {
                if (isEditMode) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.pushReplacementNamed(
                      context, OnboardingGenderScreen.routeName);
                }
              } else if (state.navigation == OnboardingNavigation.done) {
                if (isEditMode) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.pushReplacementNamed(
                      context, MessageHolderScreen.routeName);
                }
              }
            }
          },
          child: BlocBuilder<OnboardingPhotoBloc, OnboardingPhotoState>(
            builder: (context, state) {
              if (state is OnboardingPhotoBaseState) {
                return showBaseUi(context, state, isEditMode);
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

  Widget showBaseUi(
      BuildContext context, OnboardingPhotoBaseState state, bool isEditMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              '${state.user.displayName},',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          Center(
            child: Text(FlutterI18n.translate(context, "say_cheese"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 70, right: 70, top: 20, bottom: 10),
            child: Center(
              child: Text(
                FlutterI18n.translate(context, "lets_take_picture"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 70, right: 70, top: 0, bottom: 20),
            child: Center(
              child: Text(
                FlutterI18n.translate(context, "review_info"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: 30),
          if (!kIsWeb)
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<OnboardingPhotoBloc>(context)
                    .add(OnboardingPhotoCameraClickedEvent());
              },
              child: Text(FlutterI18n.translate(context, "take_a_picture")),
            ),
          if (!kIsWeb) const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<OnboardingPhotoBloc>(context)
                  .add(OnboardingPhotoGalleryClickedEvent());
            },
            child: Text(FlutterI18n.translate(context, "select_from_images")),
          ),
          const SizedBox(height: 20),
          if (isEditMode && state.user.pictureData.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<OnboardingPhotoBloc>(context)
                    .add(OnboardingPhotoRemoveEvent());
              },
              child: Text(FlutterI18n.translate(context, "delete_photo")),
            ),
          if (!isEditMode) Text(FlutterI18n.translate(context, 'or')),
          if (!isEditMode) const SizedBox(height: 20),
          if (!isEditMode)
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
                          width: 140, height: 140, child: getAvatar(state))
                      : const Icon(Icons.camera_alt_outlined))),
          const SizedBox(height: 20),
          Center(
            child: Text(FlutterI18n.translate(context, "you_look_good"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge),
          ),
          Center(
            child: Text(FlutterI18n.translate(context, "as_always"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 70, right: 70, top: 20, bottom: 20),
            child: Center(
              child: Text(FlutterI18n.translate(context, "continue_if_happy"),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
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
                style: Theme.of(context).textTheme.bodyMedium),
          )
        ],
      ),
    );
  }

  CircleAvatar getAvatar(OnboardingPhotoDoneState state) {
    final image = kIsWeb
        ? NetworkImage(state.filePath)
        : FileImage(File.fromUri(Uri.parse(state.filePath)));
    return CircleAvatar(backgroundImage: image as ImageProvider<Object>);
  }
}

void showCameraOrImageBottomSheet(
    {required BuildContext parentContext,
    required VoidCallback onCameraPressed,
    required VoidCallback onGalleryPressed}) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    isScrollControlled: true,
    context: parentContext,
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
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              getOptionWidget(
                  parentContext,
                  FlutterI18n.translate(context, "camera"),
                  '',
                  const Icon(Icons.camera_alt, size: 30, color: Colors.black),
                  20,
                  8,
                  onCameraPressed),
              getOptionWidget(
                  parentContext,
                  FlutterI18n.translate(context, "images"),
                  '',
                  const Icon(Icons.image, size: 30, color: Colors.black),
                  8,
                  20, onGalleryPressed),
            ],
          ),
          const SizedBox(height: 152),
        ],
      );
    },
  ).whenComplete(() {
    if (parentContext.mounted) {
      BlocProvider.of<OnboardingPhotoBloc>(parentContext)
          .add(OnboardingPhotoBottomSheetClosedEvent());
    }
  });
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
                elevation: WidgetStateProperty.all<double>(2.0),
                backgroundColor:
                    WidgetStateProperty.all<Color>(context.white),
                overlayColor: WidgetStateProperty.resolveWith(
                  (states) {
                    return states.contains(WidgetState.pressed)
                        ? context.main
                        : null;
                  },
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              onPressed: onPressed,
              child: Center(
                child: icon,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 128,
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
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
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        ],
      ),
    ),
  );
}
