import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import '../../../model/room_chat.dart';
import '../../../model/chat_user.dart';
import '../../../repository/firestore_repository.dart';
import '../../../repository/network_repository.dart';
import '../../../utils/log.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirestoreRepository _firestoreRepository;
  late ChatUser user;

  ChatBloc(this._firestoreRepository) : super(ChatLoadingState()) {
    add(ChatInitialEvent());
  }

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    if (event is ChatInitialEvent) {
      setUpDataListener();
    } else if (event is ChatUpdatedEvent) {
      final chats = event.chats;
      if (chats.isEmpty) {
        yield ChatEmptyState();
      } else {
        Set<String> userIds = {};
        for (var chat in chats) {
          userIds.addAll(chat.users);
        }

        yield ChatBaseState(chats);
      }
    } else {
      throw UnimplementedError();
    }
  }

  void setUpDataListener() async {
    Log.d("Setting up data listener");
    //String countryCode= WidgetsBinding.instance.platformDispatcher.locale.countryCode?.toUpperCase() ?? 'US';
    String countryCode = await getCountry();
    Log.d('Current country Code: $countryCode');
    _firestoreRepository.streamChats(countryCode).listen((event) {
      final List<RoomChat> chats = event.docs
          .map((e) => RoomChat.fromJson(e.id, e.data() as Map<String, dynamic>))
          .toList()
          .sorted((a, b) => b.chatName.compareTo(a.chatName))
          .reversed
          .toList();

      add(ChatUpdatedEvent(chats));
    });
  }
}

class ChatsAndUser {
  final ChatUser user;
  final List<RoomChat> chats;

  ChatsAndUser(this.user, this.chats);
}
