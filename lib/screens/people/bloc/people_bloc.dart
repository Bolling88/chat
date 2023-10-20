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
  final Chat? _chat;
  final ChatUser _user;
  final List<ChatUser>? _initialUsers;

  StreamSubscription<QuerySnapshot>? chatStream;
  StreamSubscription<QuerySnapshot>? onlineUsersStream;

  PeopleBloc(this._firestoreRepository, this._chat, this._user, this._initialUsers)
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
    try {
      if (event is PeopleInitialEvent) {
        if(_initialUsers == null) {
          setUpPeopleListener();
        } else {
          yield PeopleBaseState(_initialUsers!);
        }
      } else if (event is PeopleLoadedEvent) {
        yield PeopleBaseState(event.onlineUser);
      } else {
        Log.e('PeopleBloc: Not implemented');
        throw UnimplementedError();
      }
    } on Exception catch (error, stacktrace) {
      yield PeopleErrorState();
      Log.e('PeopleErrorState: $error', stackTrace: stacktrace);
    }
  }

  void setUpPeopleListener() {
    final currentChat = _chat;
    onlineUsersStream = _firestoreRepository.streamOnlineUsers().listen((event) async {
      final users = event.docs
          .map((e) => ChatUser.fromJson(e.id, e.data() as Map<String, dynamic>))
          .toList();

      final filteredUsers = users.where((element) => element.id != getUserId()).toList();

      filteredUsers.sort((a, b) {
        // Check if the user is from the same country as yours
        bool isSameCountryAsMineA = a.countryCode == _user.countryCode;
        bool isSameCountryAsMineB = b.countryCode == _user.countryCode;

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


      if (currentChat != null) {
        // add(PeopleLoadedEvent(filteredUsers
        //     .where((element) => element.currentRoomChatId == currentChat.id)
        //     .toList()));
        add(PeopleLoadedEvent(filteredUsers));
      } else {
        add(PeopleLoadedEvent(filteredUsers));
      }
    });
  }
}
