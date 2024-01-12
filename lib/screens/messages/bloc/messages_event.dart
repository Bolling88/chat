import 'package:equatable/equatable.dart';
import 'package:giphy_get/giphy_get.dart';

import '../../../model/chat_user.dart';
import '../../../model/private_chat.dart';
import '../../../model/message.dart';

abstract class MessagesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class MessagesInitialEvent extends MessagesEvent {}

class MessagesSendEvent extends MessagesEvent {}

class MessagesUpdatedEvent extends MessagesEvent {
  final List<Message> messages;

  MessagesUpdatedEvent(this.messages);

  @override
  List<Object> get props => [messages];
}

class MessagesGiphyPickedEvent extends MessagesEvent{
  final GiphyGif gif;

  MessagesGiphyPickedEvent(this.gif);

  @override
  List<Object> get props => [gif];
}

class MessagesChangedEvent extends MessagesEvent {
  final String message;

  MessagesChangedEvent(this.message);

  @override
  List<Object> get props => [message];
}

class MessagesReportMessageEvent extends MessagesEvent {
  final Message message;

  MessagesReportMessageEvent(this.message);

  @override
  List<Object> get props => [message];
}


class MessagesUserUpdatedEvent extends MessagesEvent {
  final ChatUser user;

  MessagesUserUpdatedEvent(this.user);

  @override
  List<Object> get props => [user];
}

class MessagesPrivateChatsUpdatedEvent extends MessagesEvent {
  final PrivateChat privateChats;

  MessagesPrivateChatsUpdatedEvent(this.privateChats);

  @override
  List<Object> get props => [privateChats];
}

class MessagesBannerAdLoadedEvent extends MessagesEvent {}

class MessagesTranslateEvent extends MessagesEvent {
  final Message message;

  MessagesTranslateEvent({required this.message});

  @override
  List<Object> get props => [message];
}

class MessagesMarkedEvent extends MessagesEvent {
  final Message message;
  final bool marked;

  MessagesMarkedEvent({required this.message, required this.marked});

  @override
  List<Object> get props => [message, marked];
}

class MessagesChatUsersInRoomUpdatedEvent extends MessagesEvent {
  final List<ChatUser> chatUsers;

  MessagesChatUsersInRoomUpdatedEvent(this.chatUsers);

  @override
  List<Object> get props => [chatUsers];
}

class MessagesReplyEvent extends MessagesEvent {
  final Message message;

  MessagesReplyEvent({required this.message});

  @override
  List<Object> get props => [message];
}

class MessagesReplyEventClear extends MessagesEvent {
  @override
  List<Object> get props => [];
}
