import 'dart:async';
import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/feedback/bloc/feedback_bloc.dart';
import 'package:chat/screens/feedback/bloc/feedback_event.dart';
import 'package:chat/screens/feedback/bloc/feedback_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/translate.dart';
import '../messages/message_edit_text_widget.dart';

class FeedbackScreen extends StatelessWidget {
  final BuildContext parentContext;

  const FeedbackScreen({
    required this.parentContext,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          FeedbackBloc(context.read<FirestoreRepository>()),
      child: FeedbackScreenContent(parentContext: parentContext),
    );
  }
}

const _bottomsheetHeight = 450.0;

class FeedbackScreenContent extends StatelessWidget {
  final BuildContext parentContext;

  const FeedbackScreenContent({required this.parentContext, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<FeedbackBloc, FeedbackState>(
      listener: (context, state) {},
      child: BlocBuilder<FeedbackBloc, FeedbackState>(
          builder: (blocContext, state) {
        if (state is FeedbackBaseState) {
          return Container(
            height: _bottomsheetHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Visibility(
                      visible: false,
                      maintainSize: true,
                      maintainState: true,
                      maintainAnimation: true,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(10),
                          ),
                          child: const Icon(Icons.arrow_back)),
                    ),
                    Expanded(
                        child: Center(
                            child: Text(
                      FlutterI18n.translate(context, 'leave_feedback'),
                      style: Theme.of(context).textTheme.displaySmall,
                    ))),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10),
                        ),
                        child: const Icon(Icons.close))
                  ],
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    FlutterI18n.translate(context, 'feedback_summary'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: MessageEditTextWidget(
                    currentMessage: '',
                    onTextChanged: (String value) {},
                    onTapGiphy: () {},
                    hintText:
                        FlutterI18n.translate(context, "write_feedback_hint"),
                    showGiphy: false,
                    onSendTapped: (String message) {
                      if (message.isEmpty) {
                        return;
                      }
                      BlocProvider.of<FeedbackBloc>(context)
                          .add(FeedbackSendEvent(message));
                      SnackBar snackBar = SnackBar(
                        content: Text(translate(context, 'feedback_sent')),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            width: double.infinity,
            height: _bottomsheetHeight,
            decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: const Center(
              child: AppSpinner(),
            ),
          );
        }
      }),
    );
  }
}

Future showFeedbackScreen(BuildContext parentContext) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: FeedbackScreen(parentContext: parentContext),
      );
    },
  );
}
