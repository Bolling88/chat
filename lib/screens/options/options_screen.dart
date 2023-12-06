import 'package:chat/screens/options/bloc/options_state.dart';
import 'package:chat/screens/options/bloc/options_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../model/message.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../messages/bloc/messages_bloc.dart';
import '../messages/bloc/messages_event.dart';
import '../messages/other_message_widget.dart';
import 'bloc/options_event.dart';

class OptionsScreen extends StatelessWidget {
  final Message message;
  final BuildContext parentContext;

  const OptionsScreen(
      {Key? key, required this.message, required this.parentContext})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          OptionsBloc(context.read<FirestoreRepository>()),
      child:
          OptionsScreenBuilder(message: message, parentContext: parentContext),
    );
  }
}

class OptionsScreenBuilder extends StatelessWidget {
  final _bottomsheetHeight = 100.0;
  final Message message;
  final BuildContext parentContext;

  const OptionsScreenBuilder(
      {super.key, required this.message, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OptionsBloc, OptionsState>(
      listener: (context, state) {
        if (state is OptionsTranslationDoneState) {
          BlocProvider.of<MessagesBloc>(parentContext).add(
              MessagesTranslateEvent(
                  message: message.copyWith(translation: state.translation.translatedText)));
          Navigator.of(context).pop();
        }
      },
      child:
          BlocBuilder<OptionsBloc, OptionsState>(builder: (blocContext, state) {
        if (state is OptionsBaseState) {
          return Container(
            height: _bottomsheetHeight,
            width: double.infinity,
            decoration: getDecoration(),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 30, bottom: 10, top: 10, right: 30),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Column(
                        children: [
                          const Icon(
                            Icons.reply,
                            color: AppColors.main,
                          ),
                          Text(FlutterI18n.translate(context, 'reply'),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        BlocProvider.of<OptionsBloc>(blocContext).add(
                            OptionsTranslateEvent( message.text));
                      },
                      child: Column(
                        children: [
                          const Icon(
                            Icons.translate,
                            color: AppColors.main,
                          ),
                          Text(FlutterI18n.translate(context, 'translate'),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: message.text));
                        Navigator.of(context).pop();
                        //Show a snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(FlutterI18n.translate(
                                context, 'copied_to_clipboard')),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const Icon(
                            Icons.copy,
                            color: AppColors.main,
                          ),
                          Text(FlutterI18n.translate(context, 'copy_text'),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        showReportDialog(parentContext, message);
                      },
                      child: Column(
                        children: [
                          const Icon(
                            Icons.report,
                            color: AppColors.main,
                          ),
                          Text(FlutterI18n.translate(context, 'report'),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium),
                        ],
                      ),
                    )
                  ],
                ),
              ),
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

Future showOptionsScreen(BuildContext parentContext, Message message) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    isScrollControlled: true,
    context: parentContext,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: OptionsScreen(
          parentContext: parentContext,
          message: message,
        ),
      );
    },
  ).whenComplete(() => BlocProvider.of<MessagesBloc>(parentContext)
      .add(MessagesMarkedEvent(message: message, marked: false)));
}
