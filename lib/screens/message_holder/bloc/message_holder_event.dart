import 'package:chat/model/room_chat.dart';
import 'package:equatable/equatable.dart';

import '../../../model/chat.dart';
import '../../../model/chat_user.dart';
import '../../../model/private_chat.dart';

class MessageHolderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class MessageHolderInitialEvent extends MessageHolderEvent {}
class MessageHolderChangeChatRoomEvent extends MessageHolderEvent {}
class MessageHolderShowRateDialogEvent extends MessageHolderEvent {}
class MessageHolderNewChatAddedEvent extends MessageHolderEvent {
  final Chat chat;

  MessageHolderNewChatAddedEvent(this.chat);

  @override
  List<Object?> get props => [chat];
}
class MessageHolderClosePrivateChatEvent extends MessageHolderEvent {
  final PrivateChat? privateChat;

  MessageHolderClosePrivateChatEvent(this.privateChat);

  @override
  List<Object?> get props => [privateChat];
}

class MessageHolderPrivateChatsUpdatedEvent extends MessageHolderEvent {
  final List<PrivateChat> privateChats;

  MessageHolderPrivateChatsUpdatedEvent(this.privateChats);

  @override
  List<Object> get props => [privateChats];
}

class MessageHolderRoomChatUpdatedEvent extends MessageHolderEvent {
  final RoomChat chat;

  MessageHolderRoomChatUpdatedEvent(this.chat);

  @override
  List<Object> get props => [chat];
}

class MessageHolderStartPrivateChatEvent extends MessageHolderEvent {
  final ChatUser user;
  final String message;

  MessageHolderStartPrivateChatEvent(this.user, this.message);

  @override
  List<Object> get props => [user, message];
}

class MessageHolderUserUpdatedEvent extends MessageHolderEvent {
  final ChatUser user;

  MessageHolderUserUpdatedEvent(this.user);

  @override
  List<Object> get props => [user];
}

class MessageHolderChatClickedEvent extends MessageHolderEvent {
  final int index;
  final Chat? chat;

  MessageHolderChatClickedEvent(this.index, this.chat);

  @override
  List<Object?> get props => [index, chat];
}

class MessageHolderUsersUpdatedEvent extends MessageHolderEvent {
  final List<ChatUser> users;

  MessageHolderUsersUpdatedEvent(this.users);

  @override
  List<Object?> get props => [users];
}

class MessageHolderLikeAppEvent extends MessageHolderEvent {
  MessageHolderLikeAppEvent();
}

class MessageHolderRateNeverAppEvent extends MessageHolderEvent {
  MessageHolderRateNeverAppEvent();
}

class MessageHolderShowOnlineUsersInChatEvent extends MessageHolderEvent {
  final Chat chat;
  MessageHolderShowOnlineUsersInChatEvent(this.chat);
}
