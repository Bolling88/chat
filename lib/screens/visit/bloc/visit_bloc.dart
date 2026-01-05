import 'dart:async';

import 'package:chat/screens/visit/bloc/visit_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat.dart';
import '../../../model/chat_user.dart';
import '../../../repository/firestore_repository.dart';
import 'visit_event.dart';

class VisitBloc extends Bloc<VisitEvent, VisitState> {
  final FirestoreRepository _firestoreRepository;
  final String userId;
  final Chat? chat;

  ChatUser? user;
  late ChatUser me;
  StreamSubscription<QuerySnapshot>? userStream;

  VisitBloc(this._firestoreRepository, this.userId, this.chat)
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
    final myUser = await _firestoreRepository.getUser();
    final isChatAvailable =
        await _firestoreRepository.isPrivateChatAvailable(userId);
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
      _firestoreRepository.blockUser(currentState.user!.id);
      final privateChat =
          await _firestoreRepository.getPrivateChat(currentState.user!.id);
      if (privateChat != null) {
        await _firestoreRepository.leavePrivateChat(privateChat);
      }
      emit(currentState.copyWith(userBlocked: true));
    }
  }

  Future<void> _onVisitUnblocUserEvent(
      VisitUnblocUserEvent event, Emitter<VisitState> emit) async {
    final currentState = state;
    if (currentState is VisitBaseState) {
      emit(VisitLoadingState());
      _firestoreRepository.unblockUser(currentState.user!.id);
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
    userStream = _firestoreRepository.streamUserById(userId).listen(
      (event) async {
        if (event.docs.isEmpty) {
          add(VisitUserLoadedState(null));
          return;
        } else {
          final Map<String, dynamic> userData =
              event.docs.first.data() as Map<String, dynamic>;

          // Convert Timestamp to int (milliseconds since epoch)
          if (userData.containsKey('lastActive') &&
              userData['lastActive'] is Timestamp) {
            userData['lastActive'] =
                (userData['lastActive'] as Timestamp).millisecondsSinceEpoch;
          }

          final user = ChatUser.fromJson(event.docs.first.id, userData);
          add(VisitUserLoadedState(user));
        }
      },
      onError: (error, stackTrace) {
        // Log error and emit loaded state with null user
        add(VisitUserLoadedState(null));
      },
    );
  }
}
