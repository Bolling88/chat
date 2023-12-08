import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat_user.dart';
import '../../../repository/firestore_repository.dart';
import '../../../utils/cloud_translation/google_cloud_translation.dart';
import '../../../utils/cloud_translation/translator.dart';
import 'feedback_event.dart';
import 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FirestoreRepository _firestoreRepository;
  final ChatUser _chatUser;
  late Translation translator;

  FeedbackBloc(this._firestoreRepository, this._chatUser) : super(FeedbackBaseState()) {
    add(FeedbackInitialEvent());
  }

  @override
  Stream<FeedbackState> mapEventToState(FeedbackEvent event) async* {
    final currentState = state;
    if (event is FeedbackInitialEvent) {
      translator = getTranslator();
    } else if (event is FeedbackSendEvent) {
      if (currentState is FeedbackBaseState) {
        yield FeedbackLoadingState();
        final translation = await translator.translate(text: event.feedback, to: 'en');
        _firestoreRepository.postFeedback(translation.translatedText, _chatUser);
        yield FeedbackDoneState();
      }
    } else {
      throw UnimplementedError();
    }
  }
}
