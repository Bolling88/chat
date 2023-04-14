import 'package:equatable/equatable.dart';
import '../../../model/chat.dart';

abstract class MessageHolderState extends Equatable {
  @override
  List<Object> get props => [];
}

class PartyMessageLoadingState extends MessageHolderState {}

class MessageHolderBaseState extends MessageHolderState {
  final String chatId;
  final Chat chat;

  MessageHolderBaseState(this.chat, this.chatId);

  @override
  List<Object> get props => [chat, chatId];
}
