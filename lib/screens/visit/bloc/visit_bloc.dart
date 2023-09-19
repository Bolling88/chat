import 'dart:async';

import 'package:chat/model/private_chat.dart';
import 'package:chat/screens/visit/bloc/visit_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat.dart';
import '../../../model/room_chat.dart';
import '../../../model/chat_user.dart';
import '../../../repository/firestore_repository.dart';
import 'visit_event.dart';

class VisitBloc extends Bloc<VisitEvent, VisitState> {
  final FirestoreRepository _firestoreRepository;
  final String userId;
  final Chat chat;

  ChatUser? user;
  late ChatUser me;
  StreamSubscription<QuerySnapshot>? chatStream;

  VisitBloc(this._firestoreRepository, this.userId, this.chat)
      : super(VisitLoadingState()) {
    add(VisitInitialEvent());
  }

  @override
  Future<void> close() {
    chatStream?.cancel();
    return super.close();
  }

  @override
  Stream<VisitState> mapEventToState(VisitEvent event) async* {
    final currentState = state;
    if (event is VisitInitialEvent) {
      final myUser = await _firestoreRepository.getUser();
      setUpPeopleListener();
      final isChatAvailable =
          await _firestoreRepository.isPrivateChatAvailable(userId);
      yield VisitBaseState(
          user: null,
          myUser: myUser!,
          isChatAvailable: isChatAvailable,
          userLoaded: false,
          userBlocked: false);
    } else if (event is VisitUserLoadedState) {
      if (currentState is VisitBaseState) {
        yield currentState.copyWith(
            user: event.user,
            userLoaded: true,
            userBlocked: event.user?.isUserBlocked());
      }
    } else if (event is VisitBlocUserEvent) {
      if (currentState is VisitBaseState) {
        yield VisitLoadingState();
        _firestoreRepository.blockUser(currentState.user!.id);
        final privateChat =
            await _firestoreRepository.getPrivateChat(currentState.user!.id);
        if (privateChat != null) {
           await _firestoreRepository.leavePrivateChat(privateChat);
        }
        yield currentState.copyWith(userBlocked: true);
      }
    }else if(event is VisitUnblocUserEvent){
      if (currentState is VisitBaseState) {
        yield VisitLoadingState();
        _firestoreRepository.unblockUser(currentState.user!.id);
        yield currentState.copyWith(userBlocked: false);
      }
    } else {
      throw UnimplementedError();
    }
  }

  void setUpPeopleListener() {
    chatStream = _firestoreRepository
        .streamChat(chat.id, chat is PrivateChat)
        .listen((event) async {
      final chat = RoomChat.fromJson(
          event.docs.first.id, event.docs.first.data() as Map<String, dynamic>);
      final users = await _firestoreRepository.getUsersInChat(chat);
      final user = users.where((element) => element.id == userId).firstOrNull;
      add(VisitUserLoadedState(user));
    });
  }
}
