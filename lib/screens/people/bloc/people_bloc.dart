import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/people/bloc/people_event.dart';
import 'package:chat/screens/people/bloc/people_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat.dart';
import '../../../utils/log.dart';
import 'dart:async';

class PeopleBloc extends Bloc<PeopleEvent, PeopleState> {
  final FirestoreRepository _firestoreRepository;
  final Chat _chat;

  PeopleBloc(this._firestoreRepository, this._chat)
      : super(const PeopleBaseState([])) {
    add(PeopleInitialEvent());
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
    _firestoreRepository.streamChat(_chat.id, false).listen((event) async {
      final chat = Chat.fromJson(
          event.docs.first.id, event.docs.first.data() as Map<String, dynamic>);
      final users = await _firestoreRepository.getUsersInChat(chat) ?? [];
      final filteredUsers = users.where((element) => element.id != getUserId()).toList();
      add(PeopleLoadedEvent(filteredUsers));
    });
  }
}
