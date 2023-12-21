import 'dart:async';
import 'package:chat/model/chat_user.dart';
import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/report/bloc/report_bloc.dart';
import 'package:chat/screens/report/bloc/report_event.dart';
import 'package:chat/screens/report/bloc/report_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/translate.dart';

class ReportScreen extends StatelessWidget {
  final BuildContext parentContext;
  final String userId;

  const ReportScreen({
    required this.parentContext,
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          ReportBloc(context.read<FirestoreRepository>(), userId),
      child: ReportScreenContent(parentContext: parentContext),
    );
  }
}

const _bottomsheetHeight = 480.0;

class ReportScreenContent extends StatelessWidget {
  final BuildContext parentContext;

  const ReportScreenContent({required this.parentContext, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportDoneState) {
          Navigator.pop(context);
        }
      },
      child:
          BlocBuilder<ReportBloc, ReportState>(builder: (blocContext, state) {
        if (state is ReportBaseState) {
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
                      FlutterI18n.translate(context, 'report_user'),
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
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image_not_supported),
                  onPressed: () {
                    BlocProvider.of<ReportBloc>(blocContext)
                        .add(ReportInappropriateImageEvent());
                  },
                  label: Text( FlutterI18n.translate(context, 'inappropriate_image')),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.speaker_notes_off_outlined),
                  onPressed: () {
                    BlocProvider.of<ReportBloc>(blocContext)
                        .add(ReportHatefulLanguageEvent());
                  },
                  label: Text( FlutterI18n.translate(context, 'hateful_language')),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.android),
                  onPressed: () {
                    BlocProvider.of<ReportBloc>(blocContext)
                        .add(ReportBotEvent());
                  },
                  label: Text( FlutterI18n.translate(context, 'likely_bot')),
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

Future showReportScreen(BuildContext parentContext, String userId) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ReportScreen(parentContext: parentContext, userId: userId),
      );
    },
  );
}
