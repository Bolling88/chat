import 'dart:async';

import 'package:chat/model/chat_user.dart';
import 'package:chat/model/private_chat.dart';
import 'package:chat/repository/fcm_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat.dart';
import '../../../model/message.dart';
import '../../../model/message_item.dart';
import '../../../repository/firestore_repository.dart';
import '../../../utils/log.dart';
import '../../../utils/time_util.dart';
import 'messages_event.dart';
import 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final Chat chat;
  final bool isPrivateChat;
  DocumentSnapshot? _lastMessageSnapshot;
  final FirestoreRepository _firestoreRepository;
  final secondsInFiveMinutes = 300;
  late final ChatUser _chatUser;

  StreamSubscription<QuerySnapshot>? messagesStream;

  MessagesBloc(this.chat, this._firestoreRepository,
      {required this.isPrivateChat})
      : super(MessagesLoadingState()) {
    add(MessagesInitialEvent());
  }

  @override
  Future<void> close() {
    postLeftMessage();
    messagesStream?.cancel();
    return super.close();
  }

  @override
  Stream<MessagesState> mapEventToState(MessagesEvent event) async* {
    Log.d(event.toString());
    final currentState = state;
    if (event is MessagesInitialEvent) {
      _chatUser = (await _firestoreRepository.getUser())!;
      postJoinedMessage();
      final data =
          await _firestoreRepository.getMessages(chat.id, isPrivateChat);
      if (data.docs.isNotEmpty) {
        Log.d("New documents: ${data.docs.length}");
        _lastMessageSnapshot = data.docs.last;
        final initialMessages = data.docs
            .map(
                (e) => Message.fromJson(e.id, e.data() as Map<String, dynamic>))
            .toList();

        yield MessagesBaseState(getMessagesWithDates(initialMessages),
            FirebaseAuth.instance.currentUser!.uid, "");
      } else {
        yield MessagesBaseState(const [], getUserId(), "");
      }
      setUpMessagesListener(chat.id);
    } else if (event is MessagesSendEvent) {
      if (currentState is MessagesBaseState) {
        if (currentState.currentMessage.isNotEmpty) {
          await _firestoreRepository.postMessage(
              chatId: chat.id,
              user: _chatUser,
              chatType: ChatType.message,
              message: currentState.currentMessage,
              isPrivateChat: isPrivateChat,
              fcmToken: getFcmToken());
          yield currentState.copyWith(currentMessage: "");
        }
      }
    } else if (event is MessagesChangedEvent) {
      if (currentState is MessagesBaseState) {
        yield currentState.copyWith(currentMessage: event.message);
      }
    } else if (event is MessagesUpdatedEvent) {
      Log.d("Got more messages event");
      if (currentState is MessagesBaseState &&
          (currentState.messages.isEmpty ||
              event.messages.last.id !=
                  currentState.messages.first.message!.id)) {
        Log.d("New message id: ${event.messages.last.id}");
        final List<MessageItem> updatedList = [...currentState.messages];
        updatedList.insertAll(0, getMessagesWithDates(event.messages));
        Log.d("Total messages: ${updatedList.length}");
        yield currentState.copyWith(messages: updatedList);
      }
    } else if (event is MessagesGiphyPickedEvent) {
      Log.d("Got giphy event");
      if (currentState is MessagesBaseState) {
        final String giphyUrl = event.gif.images?.downsized?.url ?? "";
        await _firestoreRepository.postMessage(
            chatId: chat.id,
            user: _chatUser,
            chatType: ChatType.giphy,
            message: giphyUrl,
            isPrivateChat: isPrivateChat,
            fcmToken: getFcmToken(),
            isGiphy: true);
        yield currentState.copyWith(currentMessage: "");
      }
    } else if (event is MessagesReportMessageEvent) {
      _firestoreRepository.reportMessage(event.message);
    } else {
      yield MessagesErrorState();
      Log.e("Error in messages");
    }
  }

  void postJoinedMessage() {
    _firestoreRepository.postMessage(
        chatId: chat.id,
        user: _chatUser,
        chatType: ChatType.joined,
        message: _chatUser.displayName,
        isPrivateChat: isPrivateChat);
  }

  void postLeftMessage() {
    _firestoreRepository.postMessage(
        chatId: chat.id,
        user: _chatUser,
        chatType: ChatType.left,
        message: _chatUser.displayName,
        isPrivateChat: isPrivateChat);
  }

  void setUpMessagesListener(String chatId) async {
    Log.d('Setting up message stream');
    messagesStream = _firestoreRepository
        .streamMessages(chatId, isPrivateChat, 1)
        .listen((data) {
      Log.d("Got messages");
      //Only add last document as snapshot if this is initial fetch.
      if (_lastMessageSnapshot == null && data.docs.isNotEmpty) {
        _lastMessageSnapshot = data.docs.last;
      }
      final messages = data.docs
          .map((e) => Message.fromJson(e.id, e.data() as Map<String, dynamic>))
          .toList()
          .reversed
          .toList();
      if (messages.isNotEmpty) add(MessagesUpdatedEvent(messages));
    });
  }

  List<MessageItem> getMessagesWithDates(List<Message> messages) {
    final List<MessageItem> datedList = [];
    if (messages.length == 1) {
      //If this is a new message after entering the chat, don't bother with dates
      datedList.add(MessageItem(messages.last, null));
      return datedList;
    }

    if (messages.isNotEmpty) {
      for (int i = 1; i <= messages.length - 1; i++) {
        final current = messages[i];
        if (i < messages.length - 1) {
          final next = messages[i + 1];
          if (current.created.seconds - next.created.seconds >=
              secondsInFiveMinutes) {
            datedList.add(MessageItem(current, null));
            datedList.add(MessageItem(null, getMessageDate(current.created)));
          } else {
            datedList.add(MessageItem(current, null));
          }
        } else {
          //datedList.add(MessageItem(current, null));
        }
      }
      datedList.add(MessageItem(messages.last, null));
      datedList.add(MessageItem(null, getMessageDate(messages.last.created)));
    }
    return datedList;
  }

  String getFcmToken() {
    if (chat is PrivateChat) {
      final privateChat = chat as PrivateChat;
      if (privateChat.initiatedBy == getUserId()) {
        return privateChat.otherUserFcmToken;
      } else {
        return privateChat.initiatedByFcmToken;
      }
    } else {
      return '';
    }
  }

  @override
  Stream<Transition<MessagesEvent, MessagesState>> transformEvents(
      Stream<MessagesEvent> events, transitionFn) {
    return super.transformEvents(
      events.distinct(),
      transitionFn,
    );
  }
}
