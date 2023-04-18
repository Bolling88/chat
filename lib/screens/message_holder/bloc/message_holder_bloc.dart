import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat.dart';
import '../../../repository/firestore_repository.dart';
import '../../../utils/log.dart';
import 'message_holder_event.dart';
import 'message_holder_state.dart';

class MessageHolderBloc extends Bloc<MessageHolderEvent, MessageHolderState> {
  final FirestoreRepository _firestoreRepository;
  Chat? chat;
  final String? chatId;

  StreamSubscription<QuerySnapshot>? chatsStream;

  MessageHolderBloc(this._firestoreRepository, this.chat, this.chatId)
      : super(MessageHolderLoadingState()) {
    add(MessageHolderInitialEvent());
  }

  @override
  Future<void> close() {
    chatsStream?.cancel();
    return super.close();
  }

  @override
  Stream<MessageHolderState> mapEventToState(MessageHolderEvent event) async* {
    final currentState = state;
    if (event is MessageHolderInitialEvent) {
      chat ??= await _firestoreRepository.getChat(chatId!);
      _firestoreRepository.setLastMessageRead(
          chatId: chat?.id ?? '', isPrivateChat: false);
      yield MessageHolderBaseState(
          chat: chat!,
          chatId: chat?.id ?? '',
          privateChats: const [],
          selectedChatIndex: 0);
      setUpChatsListener();
    } else if (event is MessageHolderPrivateChatEvent) {
      if (currentState is MessageHolderBaseState) {
        await _firestoreRepository.createPrivateChat(event.user);
      }
    } else if (event is MessageHolderChatsUpdatedEvent) {
      if (currentState is MessageHolderBaseState) {
        yield currentState.copyWith(privateChats: event.chats);
      }
    } else if (event is MessageHolderChatClickedEvent) {
      if (currentState is MessageHolderBaseState) {
        if (event.index == 0) {
          _firestoreRepository.setLastMessageRead(
              chatId: currentState.chatId, isPrivateChat: false);
        } else {
          _firestoreRepository.setLastMessageRead(
              chatId: currentState.privateChats[event.index - 1].id,
              isPrivateChat: true);
        }
        yield currentState.copyWith(selectedChatIndex: event.index);
      }
    } else {
      throw UnimplementedError();
    }
  }

  void setUpChatsListener() async {
    Log.d('Setting up chats stream');
    chatsStream = _firestoreRepository.streamPrivateChats().listen((data) {
      Log.d("Got private chats");
      final chats = data.docs
          .map((e) => Chat.fromJson(e.id, e.data() as Map<String, dynamic>))
          .toList()
          .reversed
          .toList();
      Log.d("Chats: ${chats.length}");
      add(MessageHolderChatsUpdatedEvent(chats));
    });
  }
}
