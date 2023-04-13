import 'package:equatable/equatable.dart';
import '../../../model/chat.dart';

abstract class PartyMessagesState extends Equatable {
  @override
  List<Object> get props => [];
}

class PartyMessageLoadingState extends PartyMessagesState {}

class PartyMessagesBaseState extends PartyMessagesState {
  final String chatId;
  final Chat chat;

  PartyMessagesBaseState(this.chat, this.chatId);

  @override
  List<Object> get props => [chat, chatId];
}
