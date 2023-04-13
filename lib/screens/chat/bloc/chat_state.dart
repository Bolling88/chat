import 'package:equatable/equatable.dart';
import '../../../model/chat.dart';
import '../../../model/chat_user.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatLoadingState extends ChatState {}

class ChatEmptyState extends ChatState {}

class ChatBaseState extends ChatState {
  final List<Chat> chats;
  final Map<String, ChatUser> users;

  ChatBaseState(this.chats, this.users);

  @override
  List<Object?> get props => [chats, users];
}
