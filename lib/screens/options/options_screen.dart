import 'package:chat/screens/options/bloc/options_state.dart';
import 'package:chat/screens/options/bloc/options_bloc.dart';
import 'package:chat/screens/report/report_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../model/message.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../credits/credits_screen.dart';
import '../messages/bloc/messages_bloc.dart';
import '../messages/bloc/messages_event.dart';
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
                  message: message.copyWith(
                      translation: state.translation.translatedText)));
          Navigator.of(context).pop();
        } else if (state is OptionsShowCreditsOfferState) {
          showCreditsScreen(context, state.user);
        }
      },
      child:
          BlocBuilder<OptionsBloc, OptionsState>(builder: (blocContext, state) {
        if (state is OptionsBaseState) {
          return SizedBox(
            width: double.infinity,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 30, bottom: 10, top: 10, right: 30),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          BlocProvider.of<MessagesBloc>(parentContext)
                              .add(MessagesReplyEvent(message: message));
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.reply,
                              color: context.main,
                            ),
                            Text(FlutterI18n.translate(context, 'reply'),
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Padding(
                      padding: EdgeInsets.only(
                          top: 11,
                          bottom:
                              (state.user.isPremiumUser || kIsWeb) ? 20 : 0),
                      child: GestureDetector(
                        onTap: () {
                          BlocProvider.of<OptionsBloc>(blocContext)
                              .add(OptionsTranslateEvent(message.text));
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.translate,
                              color: context.main,
                            ),
                            Text(FlutterI18n.translate(context, 'translate'),
                                style: Theme.of(context).textTheme.bodyMedium),
                            if (state.user.isPremiumUser == false &&
                                kIsWeb == false)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(FlutterI18n.translate(context, '1'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                  Icon(
                                    Icons.paid_outlined,
                                    color: context.textColor,
                                    size: 18,
                                  ),
                                  Text(
                                      FlutterI18n.translate(context,
                                          '(${state.user.kvitterCredits.toInt()})'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      child: GestureDetector(
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
                            Icon(
                              Icons.copy,
                              color: context.main,
                            ),
                            Text(FlutterI18n.translate(context, 'copy_text'),
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          showReportScreen(context, message.createdById);
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.report,
                              color: context.main,
                            ),
                            Text(FlutterI18n.translate(context, 'report'),
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          return const SizedBox(
            width: double.infinity,
            height: 100,
            child: Center(
              child: AppSpinner(),
            ),
          );
        }
      }),
    );
  }
}

Future showOptionsScreen(BuildContext parentContext, Message message) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    isScrollControlled: true,
    context: parentContext,
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
