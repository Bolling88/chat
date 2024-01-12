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
import 'bloc/review_bloc.dart';
import 'bloc/review_event.dart';
import 'bloc/review_state.dart';

class ReviewScreen extends StatelessWidget {
  static const routeName = "/review_screen";

  const ReviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          ReviewBloc(context.read<FirestoreRepository>()),
      child: const ReviewScreenBuilder(),
    );
  }
}

class ReviewScreenBuilder extends StatelessWidget {
  const ReviewScreenBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review'),
      ),
      body: BlocListener<ReviewBloc, ReviewState>(
          listener: (context, state) {},
          child: BlocBuilder<ReviewBloc, ReviewState>(
              builder: (blocContext, state) {
            if (state is ReviewErrorState) {
              return const AppErrorScreen();
            } else if (state is ReviewBaseState) {
              return SafeArea(
                child: Column(
                  children: [
                    Text(
                      'Images left to review: ${state.users.length}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    Expanded(
                      child: Center(
                        child: InteractiveViewer(
                            panEnabled: true,
                            // Set it to false
                            minScale: 1,
                            clipBehavior: Clip.none,
                            maxScale: 3,
                            child:
                                Image.network(state.underReview.pictureData)),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: IconButton(
                            iconSize: 60,
                            icon: const Icon(
                              Icons.check,
                              color: AppColors.main,
                            ),
                            onPressed: () {
                              BlocProvider.of<ReviewBloc>(blocContext)
                                  .add(ReviewApproveEvent(state.underReview));
                            },
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            iconSize: 60,
                            onPressed: () {
                              BlocProvider.of<ReviewBloc>(blocContext)
                                  .add(ReviewRejectEvent(state.underReview));
                            },
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              );
            } else if (state is ReviewNothingToApproveState) {
              return const Center(
                child: Text('Nothing to review'),
              );
            } else {
              return const AppLoadingScreen();
            }
          })),
    );
  }

  void exitToLogin(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context, rootNavigator: true)
        .pushReplacementNamed(LoginScreen.routeName);
  }
}
