import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/people/bloc/people_event.dart';
import 'package:chat/screens/people/bloc/people_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat.dart';
import '../../../model/chat_user.dart';
import '../../../model/room_chat.dart';
import '../../../utils/log.dart';
import 'dart:async';

class PeopleBloc extends Bloc<PeopleEvent, PeopleState> {
  final FirestoreRepository _firestoreRepository;
  final Chat _chat;
  final ChatUser _user;

  StreamSubscription<QuerySnapshot>? chatStream;

  PeopleBloc(this._firestoreRepository, this._chat, this._user)
      : super(PeopleLoadingState()) {
    add(PeopleInitialEvent());
  }

  @override
  Future<void> close() {
    chatStream?.cancel();
    return super.close();
  }

  @override
  Stream<PeopleState> mapEventToState(PeopleEvent event) async* {
    try {
      if (event is PeopleInitialEvent) {
        setUpPeopleListener();
      } else if (event is PeopleLoadedEvent) {
        yield PeopleBaseState(event.chatUsers);
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
    chatStream = _firestoreRepository.streamChat(_chat.id, false).listen((event) async {
      final chat = RoomChat.fromJson(
          event.docs.first.id, event.docs.first.data() as Map<String, dynamic>);
      final users = await _firestoreRepository.getUsersInChat(chat);
      final filteredUsers =
          users.where((element) => element.id != getUserId()).toList();
      //Sort users with the same country code as my users first
      filteredUsers.sort((a, b) {
        if (a.countryCode == _user.countryCode) {
          return -1;
        } else if (b.countryCode == _user.countryCode) {
          return 1;
        } else {
          return 0;
        }
      });
      add(PeopleLoadedEvent(filteredUsers));
    });
  }
}
