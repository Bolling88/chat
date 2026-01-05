import 'dart:async';

import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/review/bloc/review_event.dart';
import 'package:chat/screens/review/bloc/review_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat_user.dart';
import '../../../utils/log.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final FirestoreRepository _firestoreRepository;

  late StreamSubscription<QuerySnapshot<Object?>> userStream;

  ReviewBloc(this._firestoreRepository) : super(ReviewLoadingState()) {
    on<ReviewInitialEvent>(_onReviewInitialEvent);
    on<ReviewUsersChangedEvent>(_onReviewUsersChangedEvent);
    on<ReviewApproveEvent>(_onReviewApproveEvent);
    on<ReviewRejectEvent>(_onReviewRejectEvent);

    add(ReviewInitialEvent());
  }

  @override
  Future<void> close() {
    userStream.cancel();
    return super.close();
  }

  void _onReviewInitialEvent(
      ReviewInitialEvent event, Emitter<ReviewState> emit) {
    try {
      setUpProfilePickListener();
    } on Exception catch (error, stacktrace) {
      emit(ReviewErrorState());
      Log.e('ReviewErrorState: $error', stackTrace: stacktrace);
    }
  }

  void _onReviewUsersChangedEvent(
      ReviewUsersChangedEvent event, Emitter<ReviewState> emit) {
    final currentState = state;
    try {
      if (event.users.isEmpty) {
        emit(ReviewNothingToApproveState());
      } else {
        if (currentState is ReviewBaseState) {
          emit(currentState.copyWith(users: event.users));
        } else {
          emit(ReviewBaseState(
              users: event.users, underReview: event.users.first));
        }
      }
    } on Exception catch (error, stacktrace) {
      emit(ReviewErrorState());
      Log.e('ReviewErrorState: $error', stackTrace: stacktrace);
    }
  }

  void _onReviewApproveEvent(
      ReviewApproveEvent event, Emitter<ReviewState> emit) {
    final currentState = state;
    try {
      if (currentState is ReviewBaseState) {
        _firestoreRepository.approveImage(event.user.id);
        final ChatUser? user = currentState.users
            .where((element) => element.id != event.user.id)
            .firstOrNull;
        if (user == null) {
          emit(ReviewNothingToApproveState());
        } else {
          emit(currentState.copyWith(
              users: currentState.users
                  .where((element) => element.id != event.user.id)
                  .toList(),
              underReview: user));
        }
      }
    } on Exception catch (error, stacktrace) {
      emit(ReviewErrorState());
      Log.e('ReviewErrorState: $error', stackTrace: stacktrace);
    }
  }

  void _onReviewRejectEvent(
      ReviewRejectEvent event, Emitter<ReviewState> emit) {
    final currentState = state;
    try {
      if (currentState is ReviewBaseState) {
        _firestoreRepository.rejectImage(event.user.id);
        final ChatUser? user = currentState.users
            .where((element) => element.id != event.user.id)
            .firstOrNull;
        if (user == null) {
          emit(ReviewNothingToApproveState());
        } else {
          emit(currentState.copyWith(
              users: currentState.users
                  .where((element) => element.id != event.user.id)
                  .toList(),
              underReview: user));
        }
      }
    } on Exception catch (error, stacktrace) {
      emit(ReviewErrorState());
      Log.e('ReviewErrorState: $error', stackTrace: stacktrace);
    }
  }

  void setUpProfilePickListener() async {
    Log.d('Setting up private chats stream');
    userStream = _firestoreRepository
        .streamUnapprovedImages()
        .handleError(
            (error) => Log.e('Error while listening to review stream: $error'))
        .listen((event) async {
      final users = event.docs
          .map((e) {
        final data = e.data() as Map<String, dynamic>;

        // Serialize timestamp if it exists in the data
        if (data.containsKey('lastActive') && data['lastActive'] is Timestamp) {
          data['lastActive'] = (data['lastActive'] as Timestamp).millisecondsSinceEpoch;
        }

        return ChatUser.fromJson(e.id, data);
      })
          .where((element) => element.pictureData.isNotEmpty)
          .toList()
          .reversed
          .toList();
      add(ReviewUsersChangedEvent(users));
    });
  }
}
