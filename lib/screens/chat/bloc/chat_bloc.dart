import 'dart:async';

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
    _firestoreRepository.streamChats(isPrivateChat: false).listen((event) {
      final List<Chat> chats = event.docs
          .map((e) => Chat.fromJson(e.id, e.data() as Map<String, dynamic>))
          .toList()
          .sorted((a, b) => b.created.compareTo(a.created))
          .reversed
          .toList();
      add(ChatUpdatedEvent(chats));
    });
  }
}

class ChatsAndUser {
  final ChatUser user;
  final List<Chat> chats;

  ChatsAndUser(this.user, this.chats);
}
