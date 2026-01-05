import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/people/bloc/people_event.dart';
import 'package:chat/screens/people/bloc/people_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat.dart';
import '../../../model/chat_user.dart';
import '../../../utils/log.dart';
import 'dart:async';

class PeopleBloc extends Bloc<PeopleEvent, PeopleState> {
  final FirestoreRepository _firestoreRepository;
  final List<ChatUser>? _initialUsers;
  final Chat? _chat;

  StreamSubscription<QuerySnapshot>? chatStream;
  StreamSubscription<List<ChatUser>>? onlineUsersStream;

  PeopleBloc(this._firestoreRepository, this._initialUsers, this._chat)
      : super(PeopleLoadingState()) {
    on<PeopleInitialEvent>(_onPeopleInitialEvent);
    on<PeopleLoadedEvent>(_onPeopleLoadedEvent);
    on<PeopleFilterEvent>(_onPeopleFilterEvent);

    add(PeopleInitialEvent());
  }

  @override
  Future<void> close() {
    chatStream?.cancel();
    onlineUsersStream?.cancel();
    return super.close();
  }

  void _onPeopleInitialEvent(
      PeopleInitialEvent event, Emitter<PeopleState> emit) {
    try {
      if (_initialUsers != null) {
        if (_chat != null) {
          //Filter to only show people in the chat
          final filteredUsers = _initialUsers
              .where((element) => element.currentRoomChatId == _chat.id)
              .toList();
          emit(PeopleBaseState(filteredUsers, filteredUsers, 0));
        } else {
          emit(PeopleBaseState(_initialUsers, _initialUsers, 0));
        }
      }
      setUpPeopleListener();
    } on Exception catch (error, stacktrace) {
      emit(PeopleErrorState());
      Log.e('PeopleErrorState: $error', stackTrace: stacktrace);
    }
  }

  void _onPeopleLoadedEvent(
      PeopleLoadedEvent event, Emitter<PeopleState> emit) {
    final currentState = state;
    try {
      if (currentState is PeopleBaseState) {
        emit(getFilteredState(
            PeopleFilterEvent(currentState.genderFilterIndex),
            currentState,
            event.onlineUser));
      } else {
        emit(PeopleBaseState(event.onlineUser, event.onlineUser, 0));
      }
    } on Exception catch (error, stacktrace) {
      emit(PeopleErrorState());
      Log.e('PeopleErrorState: $error', stackTrace: stacktrace);
    }
  }

  void _onPeopleFilterEvent(
      PeopleFilterEvent event, Emitter<PeopleState> emit) {
    final currentState = state;
    try {
      if (currentState is PeopleBaseState) {
        //Filter users depending on gender
        emit(getFilteredState(
            event, currentState, currentState.allOnlineUsers));
      }
    } on Exception catch (error, stacktrace) {
      emit(PeopleErrorState());
      Log.e('PeopleErrorState: $error', stackTrace: stacktrace);
    }
  }

  PeopleBaseState getFilteredState(PeopleFilterEvent event,
      PeopleBaseState currentState, List<ChatUser> onlinePeople) {
    if (event.filter == 0) {
      return currentState.copyWith(
          allOnlineUsers: onlinePeople,
          filteredUsers: onlinePeople,
          genderFilterIndex: event.filter);
    } else if (Gender.fromValue(event.filter - 1) == Gender.female) {
      return currentState.copyWith(
          allOnlineUsers: onlinePeople,
          filteredUsers: onlinePeople
              .where((element) =>
                  Gender.fromValue(element.gender) == Gender.female)
              .toList(),
          genderFilterIndex: event.filter);
    } else if (Gender.fromValue(event.filter - 1) == Gender.male) {
      return currentState.copyWith(
          allOnlineUsers: onlinePeople,
          filteredUsers: onlinePeople
              .where(
                  (element) => Gender.fromValue(element.gender) == Gender.male)
              .toList(),
          genderFilterIndex: event.filter);
    } else if (Gender.fromValue(event.filter - 1) == Gender.nonBinary) {
      return currentState.copyWith(
          allOnlineUsers: onlinePeople,
          filteredUsers: onlinePeople
              .where((element) =>
                  Gender.fromValue(element.gender) == Gender.nonBinary)
              .toList(),
          genderFilterIndex: event.filter);
    } else if (Gender.fromValue(event.filter - 1) == Gender.secret) {
      return currentState.copyWith(
          allOnlineUsers: onlinePeople,
          filteredUsers: onlinePeople
              .where((element) =>
                  Gender.fromValue(element.gender) == Gender.secret)
              .toList(),
          genderFilterIndex: event.filter);
    } else {
      return currentState.copyWith(
          allOnlineUsers: onlinePeople,
          filteredUsers: onlinePeople,
          genderFilterIndex: event.filter);
    }
  }

  void setUpPeopleListener() {
    onlineUsersStream =
        _firestoreRepository.onlineUsersStream.listen((event) async {
          if(_chat == null){
            add(PeopleLoadedEvent(event));
          }else {
            final filteredUsers = event.where((element) {
              return element.currentRoomChatId == _chat.id;
                        }).toList();
            add(PeopleLoadedEvent(filteredUsers));
          }
    });
  }
}
