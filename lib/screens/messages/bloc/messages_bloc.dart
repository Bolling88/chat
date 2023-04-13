import 'dart:async';

import 'package:chat/model/chat_user.dart';
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
  final String chatId;
  final bool isPartyChat;
  DocumentSnapshot? _lastMessageSnapshot;
  Map<String, ChatUser> contributorMap = {};
  List<ChatUser> contributors = [];
  final FirestoreRepository _firestoreRepository;
  final secondsInFiveMins = 300;

  StreamSubscription<QuerySnapshot>? messagesStream;
  StreamSubscription<QuerySnapshot>? chatsStream;

  MessagesBloc(this.chatId, this._firestoreRepository,
      {this.isPartyChat = false})
      : super(MessagesLoadingState()) {
    add(MessagesInitialEvent());
  }

  @override
  Future<void> close() {
    messagesStream?.cancel();
    chatsStream?.cancel();
    return super.close();
  }

  @override
  Stream<MessagesState> mapEventToState(MessagesEvent event) async* {
    Log.d(event.toString());
    final currentState = state;
    if (event is MessagesInitialEvent) {
      final chat = await _firestoreRepository.getChat(chatId);
      if(chat != null) {
        Log.d("Fetching users in this chat: ${chat.users}");
        await updateUsers(chat);
        final data = await _firestoreRepository.getMessages(chatId);
        if (data.docs.isNotEmpty) {
          Log.d("New documents: ${data.docs.length}");
          _lastMessageSnapshot = data.docs.last;
          final initialMessages =
          data.docs.map((e) => Message.fromJson(e.id, e.data() as Map<String, dynamic>)).toList();

          yield MessagesBaseState(getMessagesWithDates(initialMessages),
              contributorMap, FirebaseAuth.instance.currentUser!.uid, "");
        } else {
          yield MessagesBaseState(
              [], contributorMap, FirebaseAuth.instance.currentUser!.uid, "");
        }
        setUpMessagesListener(chatId);
        setUpChatsListener(chatId);
      }else{
        yield MessagesErrorState();
      }
    } else if (event is MessagesSendEvent) {
      if (currentState is MessagesBaseState) {
        if (currentState.currentMessage.isNotEmpty) {
          await _firestoreRepository.postMessage(
              chatId,
              contributorMap[FirebaseAuth.instance.currentUser!.uid]!,
              currentState.currentMessage);
          yield currentState.copyWith(currentMessage: "");
        }
      }
    } else if (event is MessagesChangedEvent) {
      if (currentState is MessagesBaseState) {
        yield currentState.copyWith(currentMessage: event.message);
      }
    } else if (event is MessageChatUpdatedEvent) {
      if (currentState is MessagesBaseState) {
        if (event.chat.users.length > contributors.length) {
          //A new user have joined or left the chat, re-fetch users
          await updateUsers(event.chat);
          yield currentState.copyWith(users: contributorMap);
        } else {
          //Nothing of interest have changed
        }
      }
    } else if (event is MessagesUpdatedEvent) {
      Log.d("Got more messages event");
      if (currentState is MessagesBaseState &&
          (currentState.messages.isEmpty ||
              event.messages.last.id !=
                  currentState.messages.first.message!.id)) {
        Log.d("New message id: ${event.messages.last.id}");
        final List<MessageItem> updatedList = [...currentState.messages];
        updatedList.insertAll(0, getMessagesWithDates(event.messages as List<Message>));
        Log.d("Total messages: ${updatedList.length}");
        yield currentState.copyWith(messages: updatedList);
      }
    } else if (event is MessagesGiphyPickedEvent) {
      Log.d("Got giphy event");
      if (currentState is MessagesBaseState) {
        final String giphyUrl = event.gif.images?.downsized?.url ?? "";
        await _firestoreRepository.postMessage(chatId,
            contributorMap[FirebaseAuth.instance.currentUser!.uid]!, giphyUrl,
            isGiphy: true);
        yield currentState.copyWith(currentMessage: "");
      }
    } else if (event is MessagesFetchMoreEvent) {
      final lastMessage = _lastMessageSnapshot;
      if (currentState is MessagesBaseState && lastMessage != null) {
        final data =
            await _firestoreRepository.getMoreMessages(chatId, lastMessage);
        if (data.docs.isNotEmpty) {
          Log.d("New documents: ${data.docs.length}");
          _lastMessageSnapshot = data.docs.last;
          final messages =
              data.docs.map((e) => Message.fromJson(e.id, e.data() as Map<String, dynamic>)).toList();
          final List<MessageItem> updatedList = [...currentState.messages];
          updatedList.addAll(getMessagesWithDates(messages));
          Log.d("Total messages: ${updatedList.length}");
          yield currentState.copyWith(messages: updatedList);
          //Adding this so that we can load more, since we are filtering away duplicates in transform
          add(MessagesFetchedEvent());
        } else {
          Log.d("Got all the documents");
        }
      }
    } else if (event is MessagesFetchedEvent) {
      //Do nothing
    } else {
      yield MessagesErrorState();
      Log.e("Error in messages");
    }
  }

  Future updateUsers(Chat chat) async {
    if (chat.contributors.isEmpty) {
      contributorMap = <String, ChatUser>{};
      return;
    }
    contributors = await _firestoreRepository.getUsers(chat.contributors);
    Log.d("Got users: ${contributors.toString()}");
    contributorMap = <String, ChatUser>{};

    for (var user in contributors) {
      contributorMap[user.id] = user;
    }

    //Add deleted users, if any
    for(var userId in chat.contributors){
      if(!contributorMap.containsKey(userId)){
        contributorMap[userId] = ChatUser.asUnknown(userId);
      }
    }
  }

  void setUpMessagesListener(String chatId) async {
    Log.d('Setting up message stream');
    messagesStream =
        _firestoreRepository.streamMessages(chatId, 1).listen((data) {
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

  void setUpChatsListener(String chatId) async {
    Log.d('Setting up chat stream');
    chatsStream = _firestoreRepository.streamChat(chatId).listen((data) {
      Log.d("Got updated chat");
      if (data.docs.isNotEmpty) {
        final json = data.docs.first;
        final newChat = Chat.fromJson(chatId, json.data() as Map<String, dynamic>);
        add(MessageChatUpdatedEvent(newChat));
      }
    });
  }

  List<MessageItem> getMessagesWithDates(List<Message> messages) {
    final List<MessageItem> datedList = [];
    if(messages.length == 1){
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
              secondsInFiveMins) {
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

  @override
  Stream<Transition<MessagesEvent, MessagesState>> transformEvents(
      Stream<MessagesEvent> events, transitionFn) {
    return super.transformEvents(
      events.distinct(),
      transitionFn,
    );
  }
}
