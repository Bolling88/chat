import 'dart:async';

import '../model/chat.dart';

class ChatClickedRepository {
  //Listen to chat clicked events
  final StreamController<Chat> _chatClickedController = StreamController<Chat>.broadcast();
  Stream<Chat> listenToChatClicked() {
    return _chatClickedController.stream;
  }

  //Add chat clicked event
  void addChatClicked(Chat chat) {
    _chatClickedController.sink.add(chat);
  }

  close() {
    _chatClickedController.close();
  }
}