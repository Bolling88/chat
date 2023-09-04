import 'dart:async';

import 'package:chat/screens/visit/bloc/visit_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat.dart';
import '../../../model/chat_user.dart';
import '../../../repository/data_repository.dart';
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
    if (event is VisitInitialEvent) {
      setUpPeopleListener();
      yield VisitBaseState(null);
    }else if(event is VisitUserLoadedState){
      yield VisitBaseState(event.user);
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
