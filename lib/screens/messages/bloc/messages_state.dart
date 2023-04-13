import 'package:chat/model/chat_user.dart';
import 'package:equatable/equatable.dart';

import '../../../model/message_item.dart';

abstract class MessagesState extends Equatable {
  @override
  List<Object> get props => [];
}

class MessagesLoadingState extends MessagesState {}

class MessagesEmptyState extends MessagesState {}

class MessagesErrorState extends MessagesState {}

class MessagesBaseState extends MessagesState {
  final List<MessageItem> messages;
  final Map<String, ChatUser> users;
  final String userId;
  final String currentMessage;

  MessagesBaseState(
      this.messages, this.users, this.userId, this.currentMessage);

  MessagesBaseState copyWith(
      {List<MessageItem>? messages,
      Map<String, ChatUser>? users,
      String? userId,
      String? currentMessage}) {
    return MessagesBaseState(messages ?? this.messages, users ?? this.users,
        userId ?? this.userId, currentMessage ?? this.currentMessage);
  }

  @override
  List<Object> get props => [messages, users, userId, currentMessage];
}
