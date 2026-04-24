import 'dart:async';

import 'package:chat/repository/supabase_repository.dart';
import 'package:chat/screens/review/bloc/review_event.dart';
import 'package:chat/screens/review/bloc/review_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat_user.dart';
import '../../../utils/log.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final SupabaseRepository _supabaseRepository;

  late StreamSubscription<List<ChatUser>> userStream;

  ReviewBloc(this._supabaseRepository) : super(ReviewLoadingState()) {
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
        _supabaseRepository.approveImage(event.user.id);
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
        _supabaseRepository.rejectImage(event.user.id);
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
    userStream = _supabaseRepository
        .streamUnapprovedImages()
        .handleError(
            (error) => Log.e('Error while listening to review stream: $error'))
        .listen((users) async {
      final filteredUsers = users
          .where((element) => element.pictureData.isNotEmpty)
          .toList()
          .reversed
          .toList();
      add(ReviewUsersChangedEvent(filteredUsers));
    });
  }
}
