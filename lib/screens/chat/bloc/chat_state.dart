import 'package:equatable/equatable.dart';
import '../../../model/room_chat.dart';
import '../../../model/chat_user.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatLoadingState extends ChatState {}

class ChatEmptyState extends ChatState {}

class ChatBaseState extends ChatState {
  final List<RoomChat> chats;
  final Map<String, List<ChatUser>> onlineUsers;

  ChatBaseState(this.chats, this.onlineUsers);

  ChatBaseState copyWith(
      {List<RoomChat>? chats,
      Map<String, List<ChatUser>>? onlineUsers,
      ChatUser? user}) {
    return ChatBaseState(chats ?? this.chats, onlineUsers ?? this.onlineUsers);
  }

  @override
  List<Object?> get props => [chats, onlineUsers];
}
