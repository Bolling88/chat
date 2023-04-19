import 'package:chat/model/chat.dart';
import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';

class MessageHolderEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class MessageHolderInitialEvent extends MessageHolderEvent {}
class MessageHolderExitChatEvent extends MessageHolderEvent {}

class MessageHolderChatsUpdatedEvent extends MessageHolderEvent {
  final List<Chat> chats;

  MessageHolderChatsUpdatedEvent(this.chats);

  @override
  List<Object> get props => [chats];
}

class MessageHolderPrivateChatEvent extends MessageHolderEvent {
  final ChatUser user;

  MessageHolderPrivateChatEvent(this.user);

  @override
  List<Object> get props => [user];
}

class MessageHolderChatClickedEvent extends MessageHolderEvent {
  final int index;

  MessageHolderChatClickedEvent(this.index);

  @override
  List<Object> get props => [index];
}
