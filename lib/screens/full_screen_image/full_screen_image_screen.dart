import 'package:blur/blur.dart';
import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/full_screen_image/bloc/full_screen_image_bloc.dart';
import 'package:chat/screens/full_screen_image/bloc/full_screen_image_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../utils/app_colors.dart';
import 'bloc/full_screen_image_event.dart';

class FullScreenImageScreen extends StatelessWidget {
  final String imageUrl;
  final String userName;
  final List<String> imageReports;
  final ApprovedImage approvalState;

  const FullScreenImageScreen(
      {super.key,
      required this.imageUrl,
      required this.userName,
      required this.imageReports,
      required this.approvalState});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          FullScreenImageBloc(imageReports, approvalState, imageUrl),
      child: FullScreenImageScreenContent(
          imageUrl: imageUrl,
          userName: userName,
          imageReports: imageReports,
          approvalState: approvalState),
    );
  }
}

class FullScreenImageScreenContent extends StatelessWidget {
  final String imageUrl;
  final String userName;
  final List<String> imageReports;
  final ApprovedImage approvalState;

  const FullScreenImageScreenContent(
      {super.key,
      required this.imageUrl,
      required this.userName,
      required this.imageReports,
      required this.approvalState});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FullScreenImageBloc, FullScreenImageState>(
        listener: (context, state) {},
        child: BlocBuilder<FullScreenImageBloc, FullScreenImageState>(
            builder: (blocContext, state) {
          if (state is FullScreenImageBaseState) {
            return Scaffold(
              appBar: AppBar(title: Text(userName)),
              backgroundColor: AppColors.black,
              body: Hero(
                tag: 'fullscreenImage',
                child: Stack(
                  children: [
                    Center(
                        child: InteractiveViewer(
                            panEnabled: true,
                            // Set it to false
                            minScale: 1,
                            clipBehavior: Clip.none,
                            maxScale: 3,
                            child: Image.network(imageUrl).blurred(
                              blur: state.shouldBlur ? 10 : 0,
                              colorOpacity: state.shouldBlur ? 0.5 : 0,
                              blurColor: AppColors.white,
                            ))),
                    if (state.shouldBlur)
                      SafeArea(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Expanded(
                                child: Container(),
                              ),
                              const Icon(Icons.visibility_off),
                              Text(
                                FlutterI18n.translate(
                                    blocContext, 'sensitive_content'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.white),
                              ),
                              Expanded(
                                child: Container(),
                              ),
                              ElevatedButton.icon(
                                  onPressed: () {
                                    BlocProvider.of<FullScreenImageBloc>(
                                            blocContext)
                                        .add(FullScreenImageUnblurEvent());
                                  },
                                  icon: const Icon(Icons.remove_red_eye),
                                  label: Text(FlutterI18n.translate(
                                      blocContext, 'show_image'))),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    if (state.showHideButton)
                      SafeArea(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Expanded(
                                child: Container(),
                              ),
                              ElevatedButton.icon(
                                  onPressed: () {
                                    BlocProvider.of<FullScreenImageBloc>(
                                            blocContext)
                                        .add(FullScreenImageBlurEvent());
                                  },
                                  icon: const Icon(Icons.visibility_off),
                                  label: Text(FlutterI18n.translate(
                                      blocContext, 'hide_image'))),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
            );
          } else {
            throw UnimplementedError();
          }
        }));
  }
}

bool shouldBlur(
    String? url, List<String> imageReport, ApprovedImage approvalState) {
  return ((approvalState == ApprovedImage.notApproved ||
              approvalState == ApprovedImage.notReviewed ||
              approvalState == ApprovedImage.notSet) ||
          imageReport.isNotEmpty) &&
      url != null &&
      url.isNotEmpty;
}
