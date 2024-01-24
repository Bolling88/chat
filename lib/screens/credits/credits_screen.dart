import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../model/message.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import 'bloc/credits_bloc.dart';
import 'bloc/credits_event.dart';
import 'bloc/credits_state.dart';

class CreditsScreen extends StatelessWidget {
  final BuildContext parentContext;

  const CreditsScreen({Key? key, required this.parentContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          CreditsBloc(context.read<FirestoreRepository>()),
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
                  padding:
                      const EdgeInsets.only(left: 30, bottom: 10, top: 10, right: 30),
                  child: Column(
                    children: [
                      Text(
                        'Get 10 Kvitter Credits',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      MyLottieAnimation(),
                      //Button with a movie icon
                      ElevatedButton.icon(
                        icon: const Icon(Icons.movie),
                        onPressed: () {
                          BlocProvider.of<CreditsBloc>(blocContext).add(CreditsShowAdEvent());
                        },
                        label: const Text('Get 10 Kvitter Credits'),
                      )
                    ],
                  )),
            ),
          );
        }else if(state is CreditsSuccessState){
          return Container(
            height: _bottomsheetHeight,
            width: double.infinity,
            decoration: getDecoration(),
            child: SafeArea(
              child: Padding(
                  padding:
                  const EdgeInsets.only(left: 30, bottom: 10, top: 10, right: 30),
                  child: Column(
                    children: [
                      Lottie.asset('assets/lottie/chest.json', animate: false),
                    ],
                  )),
            ),
          );
        }else if(state is CreditsFailedState){
          return Container(
            height: _bottomsheetHeight,
            width: double.infinity,
            decoration: getDecoration(),
            child: SafeArea(
              child: Padding(
                  padding:
                  const EdgeInsets.only(left: 30, bottom: 10, top: 10, right: 30),
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
            height: 100,
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

Future showCreditsScreen(BuildContext parentContext) async {
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
        ),
      );
    },
  );
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MyLottieAnimation extends StatefulWidget {
  @override
  _MyLottieAnimationState createState() => _MyLottieAnimationState();
}

class _MyLottieAnimationState extends State<MyLottieAnimation> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // Adjust the duration according to your animation
    _controller.duration = Duration(seconds: 1);
    _controller.addListener(() {
      if (_controller.isCompleted) {
        _controller.reset();
        _controller.forward();
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
      'assets/lottie_animation.json',
      controller: _controller,
      onLoaded: (composition) {
        // Set the range of frames here
        final startProgress = composition.startFrame / composition.endFrame;
        final endProgress = 60 / composition.endFrame; // 60 is the end frame you want

        _controller.lowerBound = startProgress;
          ..lowerBound = startProgress
          ..upperBound = endProgress
          ..forward();
      },
    );
  }
}

