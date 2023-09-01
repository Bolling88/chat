import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import '../../../model/chat.dart';
import '../../../model/chat_user.dart';
import '../../../repository/firestore_repository.dart';
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

  void setUpDataListener() {
    Log.d("Setting up data listener");
    String deviceLanguage= Platform.localeName.substring(0,2);
    Log.d('Current Language Code: $deviceLanguage');
    _firestoreRepository.streamChats().listen((event) {
      final List<Chat> chats = event.docs
          .map((e) => Chat.fromJson(e.id, e.data() as Map<String, dynamic>))
          .toList()
          .sorted((a, b) => b.chatName.compareTo(a.chatName))
          .reversed
          .toList();
      Chat? sameLanguageChat;
      Chat? enLanguageChat;

      for (final chat in chats) {
        if (chat.languageCode == deviceLanguage) {
          sameLanguageChat = chat;
          break; // Found a chat with the same language code, no need to continue
        }
        if (chat.languageCode == 'en') {
          enLanguageChat = chat;
        }
      }

      chats.removeWhere((chat) => chat.languageCode == deviceLanguage);
      chats.removeWhere((chat) => chat.languageCode == 'en');

      // If a chat with the same language code was found, add it to the beginning
      if (sameLanguageChat != null) {
        chats.insert(0, sameLanguageChat);
      }
      if (enLanguageChat != null) {
        chats.insert(0, enLanguageChat);
      }

      add(ChatUpdatedEvent(chats));
    });
  }
}

class ChatsAndUser {
  final ChatUser user;
  final List<Chat> chats;

  ChatsAndUser(this.user, this.chats);
}
