import 'dart:async';

import 'package:chat/screens/visit/bloc/visit_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat.dart';
import '../../../model/chat_user.dart';
import '../../../repository/serverpod_repository.dart';
import 'visit_event.dart';

class VisitBloc extends Bloc<VisitEvent, VisitState> {
  final ServerpodRepository _serverpodRepository;
  final String userId;
  final Chat? chat;

  ChatUser? user;
  late ChatUser me;
  StreamSubscription<ChatUser?>? userStream;

  VisitBloc(this._serverpodRepository, this.userId, this.chat)
      : super(VisitLoadingState()) {
    on<VisitInitialEvent>(_onVisitInitialEvent);
    on<VisitUserLoadedState>(_onVisitUserLoadedState);
    on<VisitBlocUserEvent>(_onVisitBlocUserEvent);
    on<VisitUnblocUserEvent>(_onVisitUnblocUserEvent);
    on<VisitTextChangedEvent>(_onVisitTextChangedEvent);

    add(VisitInitialEvent());
  }

  @override
  Future<void> close() {
    userStream?.cancel();
    return super.close();
  }

  Future<void> _onVisitInitialEvent(
      VisitInitialEvent event, Emitter<VisitState> emit) async {
    final myUser = await _serverpodRepository.getUser();
    final isChatAvailable =
        await _serverpodRepository.isPrivateChatAvailable(userId);
    // Emit initial state BEFORE setting up listener to avoid race condition
    emit(VisitBaseState(
        user: null,
        myUser: myUser!,
        isChatAvailable: isChatAvailable,
        userLoaded: false,
        userBlocked: false,
        message: ''));
    // Now set up listener - events will be processed correctly
    setUpPeopleListener();
  }

  void _onVisitUserLoadedState(
      VisitUserLoadedState event, Emitter<VisitState> emit) {
    final currentState = state;
    if (currentState is VisitBaseState) {
      if (event.user != null) {
        emit(currentState.copyWith(
            user: event.user,
            userLoaded: true,
            userBlocked: event.user?.isUserBlocked()));
      } else {
        //User most likely deleted his account
        emit(currentState.copyWith(
            user: null, userLoaded: true, userBlocked: false));
      }
    }
  }

  Future<void> _onVisitBlocUserEvent(
      VisitBlocUserEvent event, Emitter<VisitState> emit) async {
    final currentState = state;
    if (currentState is VisitBaseState) {
      emit(VisitLoadingState());
      _serverpodRepository.blockUser(currentState.user!.id);
      final privateChat =
          await _serverpodRepository.getPrivateChat(currentState.user!.id);
      if (privateChat != null) {
        await _serverpodRepository.leavePrivateChat(privateChat);
      }
      emit(currentState.copyWith(userBlocked: true));
    }
  }

  Future<void> _onVisitUnblocUserEvent(
      VisitUnblocUserEvent event, Emitter<VisitState> emit) async {
    final currentState = state;
    if (currentState is VisitBaseState) {
      emit(VisitLoadingState());
      _serverpodRepository.unblockUser(currentState.user!.id);
      emit(currentState.copyWith(userBlocked: false));
    }
  }

  void _onVisitTextChangedEvent(
      VisitTextChangedEvent event, Emitter<VisitState> emit) {
    final currentState = state;
    if (currentState is VisitBaseState) {
      emit(currentState.copyWith(message: event.message));
    }
  }

  void setUpPeopleListener() {
    userStream = _serverpodRepository.streamUserById(userId).listen(
      (user) async {
        add(VisitUserLoadedState(user));
      },
      onError: (error, stackTrace) {
        // Log error and emit loaded state with null user
        add(VisitUserLoadedState(null));
      },
    );
  }
}
