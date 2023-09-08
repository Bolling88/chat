import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../chat/chat_screen.dart';
import '../login/bloc/login_state.dart';
import '../onboarding_gender/onboarding_gender_screen.dart';
import '../onboarding_photo/onboarding_photo_screen.dart';
import 'bloc/onboarding_name_bloc.dart';
import 'bloc/onboarding_name_event.dart';
import 'bloc/onboarding_name_state.dart';

class OnboardingNameScreen extends StatelessWidget {
  static const routeName = "/onboarding_name_screen";

  const OnboardingNameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          OnboardingNameBloc(context.read<FirestoreRepository>()),
      child: const OnboardingNameScreenContent(),
    );
  }
}

class OnboardingNameScreenContent extends StatelessWidget {
  const OnboardingNameScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocListener<OnboardingNameBloc, OnboardingNameState>(
      listener: (context, state) {
        if (state is OnboardingNameSuccessState) {
          if (state.navigation == OnboardingNavigation.PICTURE) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacementNamed(
                context, OnboardingPhotoScreen.routeName);
          } else if (state.navigation == OnboardingNavigation.GENDER) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacementNamed(
                context, OnboardingGenderScreen.routeName);
          } else if (state.navigation == OnboardingNavigation.DONE) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacementNamed(context, ChatScreen.routeName);
          }
        }
      },
      child: BlocBuilder<OnboardingNameBloc, OnboardingNameState>(
        builder: (context, state) {
          if (state is OnboardingNameBaseState) {
            return showBaseUi(context, state);
          } else {
            return const Center(
              child: AppSpinner(),
            );
          }
        },
      ),
    ));
  }

  Widget showBaseUi(BuildContext context, OnboardingNameBaseState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              FlutterI18n.translate(context, "hey_you"),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Text(
                FlutterI18n.translate(context, "nice_see_you_here"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 70, right: 70, top: 30, bottom: 20),
            child: Center(
              child: Text(
                FlutterI18n.translate(context, "nice_see_you_here_info"),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SizedBox(
              width: 220,
              height: 60,
              child: TextFormField(
                  initialValue: state.displayName,
                  keyboardType: TextInputType.name,
                  maxLines: 1,
                  maxLength: 15,
                  autofocus: false,
                  autocorrect: false,
                  style: const TextStyle(color: AppColors.main, fontSize: 15),
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: AppColors.main,
                  onChanged: (text) {
                    BlocProvider.of<OnboardingNameBloc>(context)
                        .add(OnboardingNameChangedEvent(text));
                  },
                  decoration: InputDecoration(
                      filled: true,
                      errorText: state.isNameTaken
                          ? FlutterI18n.translate(context, "name_taken")
                          : null,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: const BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          )),
                      fillColor: AppColors.white,
                      hintStyle: const TextStyle(color: AppColors.grey_1),
                      contentPadding:
                          const EdgeInsets.only(left: 15, right: 15),
                      hintText:
                          FlutterI18n.translate(context, "write_firstname"))),
            ),
          ),
          const SizedBox(height: 10),
          (state.displayName.isNotEmpty &&
                  !state.isNameTaken &&
                  !state.isValidatingName)
              ? ElevatedButton(
                  onPressed: () {
                    BlocProvider.of<OnboardingNameBloc>(context)
                        .add(OnboardingNameContinueClickedEvent());
                  },
                  child: Text(FlutterI18n.translate(context, "continue")),
                )
              : (state.isValidatingName)
                  ? const ElevatedButton(
                      onPressed: null,
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator()),
                    )
                  : ElevatedButton(
                      onPressed: null,
                      child: Text(FlutterI18n.translate(context, "continue")),
                    )
        ],
      ),
    );
  }
}
