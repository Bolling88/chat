import 'dart:async';

import '../model/chat.dart';

class ChatClickedRepository {
  //Listen to chat clicked events
  StreamController<Chat>? _chatClickedController;
  Stream<Chat> listenToChatClicked() {
    _chatClickedController ??= StreamController<Chat>.broadcast();
    return _chatClickedController!.stream;
  }

  //Add chat clicked event
  void addChatClicked(Chat chat) {
    _chatClickedController?.sink.add(chat);
  }

  close() {
    _chatClickedController?.close();
    _chatClickedController = null;
  }
}