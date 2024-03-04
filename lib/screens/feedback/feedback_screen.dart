import 'dart:async';
import 'package:chat/model/chat_user.dart';
import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/feedback/bloc/feedback_bloc.dart';
import 'package:chat/screens/feedback/bloc/feedback_event.dart';
import 'package:chat/screens/feedback/bloc/feedback_state.dart';
import 'package:chat/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../utils/app_widgets.dart';
import '../../utils/translate.dart';
import '../messages/message_edit_text_widget.dart';

class FeedbackScreen extends StatelessWidget {
  final BuildContext parentContext;
  final ChatUser user;

  const FeedbackScreen({
    required this.parentContext,
    required this.user,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          FeedbackBloc(context.read<FirestoreRepository>(), user),
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
      listener: (context, state) {
        if (state is FeedbackDoneState) {
          SnackBar snackBar = SnackBar(
            content: Text(translate(context, 'feedback_sent')),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.pop(context);
        }
      },
      child: BlocBuilder<FeedbackBloc, FeedbackState>(
          builder: (blocContext, state) {
        if (state is FeedbackBaseState) {
          return SizedBox(
            height: _bottomsheetHeight,
            width: double.infinity,
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
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox(
            width: double.infinity,
            height: _bottomsheetHeight,
            child: Center(
              child: AppSpinner(),
            ),
          );
        }
      }),
    );
  }
}

Future showFeedbackScreen(BuildContext parentContext, ChatUser user) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    context: parentContext,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: FeedbackScreen(parentContext: parentContext, user: user),
      );
    },
  );
}
