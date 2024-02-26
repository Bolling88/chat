import 'package:chat/screens/message_holder/message_holder_screen.dart';
import 'package:chat/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_widgets.dart';
import '../login/bloc/login_state.dart';
import '../onboarding_gender/onboarding_gender_screen.dart';
import '../onboarding_photo/onboarding_photo_screen.dart';
import 'bloc/onboarding_age_event.dart';
import 'bloc/onboarding_age_state.dart';
import 'bloc/onboarding_age_bloc.dart';

class OnboardingAgeScreenArguments {
  final bool isEditMode;

  OnboardingAgeScreenArguments({required this.isEditMode});
}

class OnboardingAgeScreen extends StatelessWidget {
  static const routeName = "/onboarding_age_screen";

  const OnboardingAgeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          OnboardingAgeBloc(context.read<FirestoreRepository>()),
      child: const OnboardingAgeScreenContent(),
    );
  }
}

class OnboardingAgeScreenContent extends StatelessWidget {
  const OnboardingAgeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments
        as OnboardingAgeScreenArguments?;
    final isEditMode = args?.isEditMode ?? false;

    return Scaffold(
        body: BlocListener<OnboardingAgeBloc, OnboardingAgeState>(
      listener: (context, state) {
        if (state is OnboardingAgeSuccessState) {
          if (isEditMode) {
            Navigator.of(context).pop();
          } else if (state.navigation == OnboardingNavigation.PICTURE) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacementNamed(
                context, OnboardingPhotoScreen.routeName);
          } else if (state.navigation == OnboardingNavigation.GENDER) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacementNamed(
                context, OnboardingGenderScreen.routeName);
          } else if (state.navigation == OnboardingNavigation.DONE) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacementNamed(
                context, MessageHolderScreen.routeName);
          }
        }
      },
      child: BlocBuilder<OnboardingAgeBloc, OnboardingAgeState>(
        builder: (context, state) {
          if (state is OnboardingAgeBaseState) {
            return showBaseUi(context, state, isEditMode);
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
      BuildContext context, OnboardingAgeBaseState state, bool isEditMode) {
    return Scaffold(
      appBar: isEditMode
          ? AppBar(
              title: Text(
                FlutterI18n.translate(context, "change_age"),
              ),
            )
          : null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                isEditMode
                    ? FlutterI18n.translate(context, "change_age_question_mark")
                    : state.displayName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  isEditMode
                      ? FlutterI18n.translate(context, "age_change_message")
                      : FlutterI18n.translate(context, "how_old_are_you"),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 70, right: 70, top: 30, bottom: 20),
              child: Center(
                child: Text(
                  FlutterI18n.translate(context, "age_button_description"),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 30),
            DatePickerWidget(
              looping: false, // default is not looping
              initialDate: state.birthDate,
              onChange: (DateTime newDate, _) {
                context
                    .read<OnboardingAgeBloc>()
                    .add(OnboardingAgeChangedEvent(newDate));
              },
              pickerTheme:  DateTimePickerTheme(
                backgroundColor: Colors.transparent,
                itemTextStyle: TextStyle(color: context.grey_1, fontSize: 19),
                dividerColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            if (state.showInvalidAgeError)
              Text(
                FlutterI18n.translate(context, "age_error"),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.red,
                    ),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                context
                    .read<OnboardingAgeBloc>()
                    .add(OnboardingAgeContinueClickedEvent());
              },
              child: Text(FlutterI18n.translate(
                  context, isEditMode ? 'save' : "continue")),
            ),
          ],
        ),
      ),
    );
  }
}
