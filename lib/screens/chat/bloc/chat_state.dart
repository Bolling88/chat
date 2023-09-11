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

  ChatBaseState(this.chats);

  @override
  List<Object?> get props => [chats];
}
