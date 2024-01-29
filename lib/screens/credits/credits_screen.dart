import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:lottie/lottie.dart';
import '../../model/chat_user.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import 'bloc/credits_bloc.dart';
import 'bloc/credits_event.dart';
import 'bloc/credits_state.dart';

class CreditsScreen extends StatelessWidget {
  final BuildContext parentContext;
  final ChatUser user;

  const CreditsScreen(
      {Key? key, required this.parentContext, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          CreditsBloc(context.read<FirestoreRepository>(), user),
      child: CreditsScreenBuilder(parentContext: parentContext),
    );
  }
}

const double _bottomsheetHeight = 400;

class CreditsScreenBuilder extends StatelessWidget {
  final BuildContext parentContext;

  const CreditsScreenBuilder({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreditsBloc, CreditsState>(
      listener: (context, state) {},
      child:
          BlocBuilder<CreditsBloc, CreditsState>(builder: (blocContext, state) {
        if (state is CreditsBaseState) {
          return Container(
            height: _bottomsheetHeight,
            width: double.infinity,
            decoration: getDecoration(),
            child: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.only(
                      left: 30, bottom: 10, top: 20, right: 30),
                  child: Column(
                    children: [
                      Text(
                        FlutterI18n.translate(context, 'get_credits'),
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const Expanded(
                          child: MyLottieAnimation(
                              lowerBound: 0.25, upperBond: 0.35, repeat: true)),
                      //Button with a movie icon
                      ElevatedButton.icon(
                        icon: const Icon(Icons.movie),
                        onPressed: () {
                          BlocProvider.of<CreditsBloc>(blocContext)
                              .add(CreditsShowAdEvent());
                        },
                        label: Text(FlutterI18n.translate(context, 'watch_ad')),
                      )
                    ],
                  )),
            ),
          );
        } else if (state is CreditsSuccessState) {
          return Container(
            height: _bottomsheetHeight,
            width: double.infinity,
            decoration: getDecoration(),
            child: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.only(
                      left: 30, bottom: 10, top: 20, right: 30),
                  child: Column(
                    children: [
                      Text(
                        FlutterI18n.translate(context, 'awesome'),
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const Expanded(
                          child: MyLottieAnimation(
                        lowerBound: 0,
                        upperBond: 1,
                        repeat: false,
                      )),
                      //Button with a movie icon
                      ElevatedButton.icon(
                        icon: const Icon(Icons.monetization_on),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        label:  Text(FlutterI18n.translate(context, 'claim_reward')),
                      )
                    ],
                  )),
            ),
          );
        } else if (state is CreditsFailedState) {
          return Container(
            height: _bottomsheetHeight,
            width: double.infinity,
            decoration: getDecoration(),
            child: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.only(
                      left: 30, bottom: 10, top: 10, right: 30),
                  child: Column(
                    children: [
                      Lottie.asset('assets/lottie/chest.json', animate: false),
                    ],
                  )),
            ),
          );
        } else {
          return Container(
            width: double.infinity,
            height: _bottomsheetHeight,
            decoration: getDecoration(),
            child: const Center(
              child: AppSpinner(),
            ),
          );
        }
      }),
    );
  }

  BoxDecoration getDecoration() {
    return const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)));
  }
}

Future showCreditsScreen(BuildContext parentContext, ChatUser user) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    isScrollControlled: true,
    context: parentContext,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: CreditsScreen(
          parentContext: parentContext,
          user: user,
        ),
      );
    },
  );
}

class MyLottieAnimation extends StatefulWidget {
  final double lowerBound;
  final double upperBond;
  final bool repeat;

  const MyLottieAnimation(
      {super.key,
      required this.lowerBound,
      required this.upperBond,
      required this.repeat});

  @override
  MyLottieAnimationState createState() {
    return MyLottieAnimationState();
  }
}

class MyLottieAnimationState extends State<MyLottieAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        lowerBound: widget.lowerBound,
        upperBound: widget.upperBond);

    // Adjust the duration according to your animation
    _controller.duration = const Duration(seconds: 2);
    _controller.addListener(() {
      if (_controller.isCompleted) {
        if (widget.repeat) {
          _controller.reset();
          _controller.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/lottie/chest.json',
      controller: _controller,
      onLoaded: (composition) {
        _controller.forward();
      },
    );
  }
}
