import 'dart:async';

import 'package:chat/screens/visit/bloc/visit_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat.dart';
import '../../../model/chat_user.dart';
import '../../../repository/firestore_repository.dart';
import 'visit_event.dart';

class VisitBloc extends Bloc<VisitEvent, VisitState> {
  final FirestoreRepository _firestoreRepository;
  final String userId;
  final String chatId;

  ChatUser? user;
  late ChatUser me;

  VisitBloc(this._firestoreRepository, this.userId, this.chatId)
      : super(VisitLoadingState()) {
    add(VisitInitialEvent());
  }

  @override
  Stream<VisitState> mapEventToState(VisitEvent event) async* {
    final currentState = state;
    if (event is VisitInitialEvent) {
      setUpPeopleListener();
      final isChatAvailable = await _firestoreRepository.isPrivateChatAvailable(userId);
      yield VisitBaseState(null, isChatAvailable, false);
    }else if(event is VisitUserLoadedState){
      if(currentState is VisitBaseState){
        yield currentState.copyWith(user: event.user, userLoaded: true);
      }
    } else {
      throw UnimplementedError();
    }
  }

  void setUpPeopleListener() {
    _firestoreRepository.streamChat(chatId, false).listen((event) async {
      final chat = Chat.fromJson(
          event.docs.first.id, event.docs.first.data() as Map<String, dynamic>);
      final users = await _firestoreRepository.getUsersInChat(chat) ?? [];
      final user = users.where((element) => element.id == userId).firstOrNull;
      add(VisitUserLoadedState(user));
    });
  }
}
