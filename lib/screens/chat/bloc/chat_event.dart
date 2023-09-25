import 'package:equatable/equatable.dart';
import '../../../model/chat_user.dart';
import '../../../model/room_chat.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitialEvent extends ChatEvent {}

class ChatUpdatedEvent extends ChatEvent {
  final List<RoomChat> chats;

  ChatUpdatedEvent(this.chats);

  @override
  List<Object?> get props => [chats];
}

class ChatOnlineUsersUpdatedEvent extends ChatEvent {
  final Map<String, List<ChatUser>> onlineUsers;

  ChatOnlineUsersUpdatedEvent(this.onlineUsers);

  @override
  List<Object?> get props => [onlineUsers];
}
