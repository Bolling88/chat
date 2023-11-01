import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat.dart';
import '../../../model/chat_user.dart';
import '../../../repository/firestore_repository.dart';
import 'feedback_event.dart';
import 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final FirestoreRepository _firestoreRepository;

  FeedbackBloc(this._firestoreRepository) : super(FeedbackBaseState()) {
    add(FeedbackInitialEvent());
  }

  @override
  Stream<FeedbackState> mapEventToState(FeedbackEvent event) async* {
    final currentState = state;
    if (event is FeedbackInitialEvent) {

    } else if (event is FeedbackSendEvent) {
      if (currentState is FeedbackBaseState) {
        _firestoreRepository.postFeedback(event.feedback);
      }
    } else {
      throw UnimplementedError();
    }
  }
}
