import 'package:chat/model/room_chat.dart';
import 'package:equatable/equatable.dart';

import '../../../model/chat.dart';
import '../../../model/chat_user.dart';
import '../../../model/private_chat.dart';

class MessageHolderEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class MessageHolderInitialEvent extends MessageHolderEvent {}
class MessageHolderExitChatEvent extends MessageHolderEvent {}
class MessageHolderClosePrivateChatEvent extends MessageHolderEvent {}

class MessageHolderPrivateChatsUpdatedEvent extends MessageHolderEvent {
  final List<PrivateChat> privateChats;

  MessageHolderPrivateChatsUpdatedEvent(this.privateChats);

  @override
  List<Object> get props => [privateChats];
}

class MessageHolderChatUpdatedEvent extends MessageHolderEvent {
  final RoomChat chat;

  MessageHolderChatUpdatedEvent(this.chat);

  @override
  List<Object> get props => [chat];
}

class MessageHolderPrivateChatEvent extends MessageHolderEvent {
  final ChatUser user;

  MessageHolderPrivateChatEvent(this.user);

  @override
  List<Object> get props => [user];
}

class MessageHolderChatClickedEvent extends MessageHolderEvent {
  final int index;
  final Chat chat;

  MessageHolderChatClickedEvent(this.index, this.chat);

  @override
  List<Object> get props => [index, chat];
}
