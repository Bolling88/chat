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
  StreamSubscription<QuerySnapshot>? onlineUsersStream;

  PeopleBloc(this._firestoreRepository, this._initialUsers, this._chat)
      : super(PeopleLoadingState()) {
    add(PeopleInitialEvent());
  }

  @override
  Future<void> close() {
    chatStream?.cancel();
    onlineUsersStream?.cancel();
    return super.close();
  }

  @override
  Stream<PeopleState> mapEventToState(PeopleEvent event) async* {
    final currentState = state;
    try {
      if (event is PeopleInitialEvent) {
        if (_initialUsers != null) {
          if(_chat != null){
            //Filter to only show people in the chat
            final filteredUsers = _initialUsers!
                .where((element) => element.currentRoomChatId == _chat?.id)
                .toList();
            yield PeopleBaseState(filteredUsers, filteredUsers, 0);
          }else {
            yield PeopleBaseState(_initialUsers!, _initialUsers!, 0);
          }
        }
        setUpPeopleListener();
      } else if (event is PeopleLoadedEvent) {
        if (currentState is PeopleBaseState) {
          yield getFilteredState(
              PeopleFilterEvent(currentState.genderFilterIndex),
              currentState,
              event.onlineUser);
        } else {
          yield PeopleBaseState(event.onlineUser, event.onlineUser, 0);
        }
      } else if (event is PeopleFilterEvent) {
        if (currentState is PeopleBaseState) {
          //Filter users depending on gender
          yield getFilteredState(
              event, currentState, currentState.allOnlineUsers);
        }
      } else {
        Log.e('PeopleBloc: Not implemented');
        throw UnimplementedError();
      }
    } on Exception catch (error, stacktrace) {
      yield PeopleErrorState();
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
      final users = event.docs
          .map((e) => ChatUser.fromJson(e.id, e.data() as Map<String, dynamic>))
          .toList();

      final filteredUsers = users
          .where((element) => element.id != getUserId())
          .where((element) => element.lastActive.toDate().isAfter(
              DateTime.now().subtract(onlineDuration)))
          .where((element) {
        if (_chat == null) {
          return true;
        } else {
          return element.currentRoomChatId == _chat?.id;
        }
      }).toList();

      final myUser =
          users.where((element) => element.id == getUserId()).firstOrNull;

      if (myUser != null) {
        sortOnlineUsers(filteredUsers, myUser.countryCode);
        add(PeopleLoadedEvent(filteredUsers));
      }
    });
  }
}

void sortOnlineUsers(List<ChatUser> filteredUsers, String countryCode) {
  filteredUsers.sort((a, b) {
    // Check if the user is from the same country as yours
    bool isSameCountryAsMineA = a.countryCode == countryCode;
    bool isSameCountryAsMineB = b.countryCode == countryCode;

    // Handle empty country codes by moving them to the end
    if (a.countryCode.isEmpty) {
      return 1;
    } else if (b.countryCode.isEmpty) {
      return -1;
    }

    // If both users are from the same country as yours, sort by lastActive in descending order
    if (isSameCountryAsMineA && isSameCountryAsMineB) {
      return b.lastActive.compareTo(a.lastActive);
    }

    // Sort users from the same country as yours first
    if (isSameCountryAsMineA) {
      return -1;
    } else if (isSameCountryAsMineB) {
      return 1;
    }

    // If the users are not from the same country, sort by countryCode and then lastActive
    int countryCodeComparison = a.countryCode.compareTo(b.countryCode);
    if (countryCodeComparison != 0) {
      return countryCodeComparison;
    } else {
      return b.lastActive.compareTo(a.lastActive);
    }
  });
}
