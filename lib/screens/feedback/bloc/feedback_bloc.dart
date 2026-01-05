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
    on<FeedbackInitialEvent>(_onInitialEvent);
    on<FeedbackSendEvent>(_onSendEvent);

    add(FeedbackInitialEvent());
  }

  void _onInitialEvent(
    FeedbackInitialEvent event,
    Emitter<FeedbackState> emit,
  ) {
    translator = getTranslator();
  }

  Future<void> _onSendEvent(
    FeedbackSendEvent event,
    Emitter<FeedbackState> emit,
  ) async {
    final currentState = state;
    if (currentState is FeedbackBaseState) {
      emit(FeedbackLoadingState());
      final translation = await translator.translate(text: event.feedback, to: 'en');
      _firestoreRepository.postFeedback(translation.translatedText, _chatUser);
      emit(FeedbackDoneState());
    }
  }
}
