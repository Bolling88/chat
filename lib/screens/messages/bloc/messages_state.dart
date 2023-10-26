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
  final ChatUser myUser;
  final String currentMessage;

  MessagesBaseState(this.messages, this.myUser, this.currentMessage);

  MessagesBaseState copyWith(
      {List<MessageItem>? messages,
      String? userId,
      ChatUser? myUser,
      String? currentMessage}) {
    return MessagesBaseState(messages ?? this.messages, myUser ?? this.myUser,
        currentMessage ?? this.currentMessage);
  }

  @override
  List<Object> get props => [messages, myUser, currentMessage];
}
