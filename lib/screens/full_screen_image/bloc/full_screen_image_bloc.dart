import 'dart:async';

import 'package:chat/screens/full_screen_image/bloc/full_screen_image_event.dart';
import 'package:chat/screens/full_screen_image/bloc/full_screen_image_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/firestore_repository.dart';
import '../full_screen_image_screen.dart';

class FullScreenImageBloc
    extends Bloc<FullScreenImageEvent, FullScreenImageState> {
  final List<String> imageReports;
  final ApprovedImage approvalState;
  final String url;

  FullScreenImageBloc(this.imageReports, this.approvalState, this.url)
      : super(FullScreenImageBaseState(
            shouldBlur(url, imageReports, approvalState), false)) {
    add(FullScreenImageInitialEvent());
  }

  @override
  Stream<FullScreenImageState> mapEventToState(
      FullScreenImageEvent event) async* {
    if (event is FullScreenImageInitialEvent) {
    } else if (event is FullScreenImageUnblurEvent) {
      yield FullScreenImageBaseState(false, true);
    }else if(event is FullScreenImageBlurEvent){
      yield FullScreenImageBaseState(true, false);
    } else {
      throw UnimplementedError();
    }
  }
}
