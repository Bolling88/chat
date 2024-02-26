//a bloc builder widget class for creating a chat
import 'package:chat/repository/subscription_repository.dart';
import 'package:chat/screens/account/bloc/account_bloc.dart';
import 'package:chat/screens/account/bloc/account_event.dart';
import 'package:chat/screens/account/bloc/account_state.dart';
import 'package:chat/screens/login/login_screen.dart';
import 'package:chat/screens/profile/profile_screen.dart';
import 'package:chat/screens/review/review_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:lottie/lottie.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/flag.dart';
import '../../utils/gender.dart';
import '../../utils/lottie.dart';
import '../../utils/translate.dart';
import '../feedback/feedback_screen.dart';
import '../premium/premium_screen.dart';

class AccountScreen extends StatelessWidget {
  static const routeName = "/account_screen";

  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AccountBloc(
          context.read<FirestoreRepository>(),
          context.read<SubscriptionRepository>()),
      child: const AccountScreenBuilder(),
    );
  }
}

class AccountScreenBuilder extends StatelessWidget {
  const AccountScreenBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          translate(context, 'Account'),
        ),
      ),
      body: BlocListener<AccountBloc, AccountState>(listener: (context, state) {
        if (state is AccountLogoutState) {
          exitToLogin(context);
        }
      }, child:
          BlocBuilder<AccountBloc, AccountState>(builder: (blocContext, state) {
        if (state is AccountErrorState) {
          return const AppErrorScreen();
        } else if (state is AccountBaseState) {
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
                    size: 60,
                    imageReports: [],
                  ),
                  onTap: () {
                    Navigator.pushNamed(blocContext, ProfileScreen.routeName);
                  },
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(blocContext, ProfileScreen.routeName);
                    },
                    child: getProfileRow(
                      displayName: state.user.displayName,
                      gender: state.user.gender,
                      countryCode: state.user.countryCode,
                      birthDate: state.user.birthDate,
                      showAge: state.user.showAge,
                      context: context,
                    )),
                if (state.user.isPremiumUser)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/lottie/premium.json',
                          animate: true,
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60),
                      Text(
                        FlutterI18n.translate(context, 'premium_user'),
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(fontSize: 20),
                      )
                    ],
                  )
                else if (!kIsWeb)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.block),
                      onPressed: () {
                        Navigator.pushNamed(
                            blocContext, PremiumScreen.routeName);
                      },
                      label: Text(translate(context, 'remove_ads')),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.pushNamed(blocContext, ProfileScreen.routeName);
                  },
                  label: Text(translate(context, 'edit_profile')),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.feedback),
                  onPressed: () {
                    showFeedbackScreen(blocContext, state.user);
                  },
                  label: Text(translate(context, 'leave_feedback')),
                ),
                const SizedBox(height: 20),
                if (state.user.isAdmin)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.admin_panel_settings),
                    onPressed: () {
                      Navigator.pushNamed(blocContext, ReviewScreen.routeName);
                    },
                    label: const Text('Review Account pictures'),
                  ),
                Expanded(
                    child: AppLottie(
                        url:
                            'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/lottie%2Fprofile.json?alt=media&token=98471dde-f589-46ea-b2d8-7821a7dc31b9')),
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
            BlocProvider.of<AccountBloc>(context).add(AccountLogoutEvent());
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
          style: TextStyle(color: context.red)),
      content: Text(translate(context, 'delete_account_info')),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            BlocProvider.of<AccountBloc>(blocContext)
                .add(AccountDeleteAccountEvent());
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

Row getProfileRow({
  required String displayName,
  required int gender,
  required String countryCode,
  required Timestamp? birthDate,
  required bool showAge,
  required BuildContext context,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(displayName,
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.displaySmall?.merge(TextStyle(
              color: getGenderColor(context, Gender.fromValue(gender)),
              fontSize: 26))),
      getGenderIcon(context, Gender.fromValue(gender)),
      const SizedBox(width: 2),
      //Show age
      if (birthDate != null && showAge)
        Text(
          getAge(birthDate),
          style: Theme.of(context).textTheme.displaySmall?.merge(TextStyle(
              color: getGenderColor(context, Gender.fromValue(gender)),
              fontSize: 26)),
        ),
      if (birthDate != null) const SizedBox(width: 8),
      getFlag(countryCode: countryCode, fontSize: 30),
    ],
  );
}

String getAge(Timestamp? birthDate) {
  if (birthDate == null) {
    return '';
  }
  DateTime date = birthDate.toDate();
  DateTime now = DateTime.now();
  int age = now.year - date.year;
  int month1 = now.month;
  int month2 = date.month;
  if (month2 > month1) {
    age--;
  } else if (month1 == month2) {
    int day1 = now.day;
    int day2 = date.day;
    if (day2 > day1) {
      age--;
    }
  }
  return age.toString();
}
