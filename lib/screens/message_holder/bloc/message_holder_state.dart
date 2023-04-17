import 'package:equatable/equatable.dart';
import '../../../model/chat.dart';

abstract class MessageHolderState extends Equatable {
  @override
  List<Object> get props => [];
}

class MessageHolderLoadingState extends MessageHolderState {}

class MessageHolderBaseState extends MessageHolderState {
  final String chatId;
  final Chat chat;
  final List<Chat> privateChats;
  final int selectedChatIndex;

  MessageHolderBaseState(
      {required this.chat,
      required this.privateChats,
      required this.chatId,
      required this.selectedChatIndex});

  MessageHolderBaseState copyWith(
      {Chat? chat,
      List<Chat>? privateChats,
      String? chatId,
      int? selectedChatIndex}) {
    return MessageHolderBaseState(
        chat: chat ?? this.chat,
        privateChats: privateChats ?? this.privateChats,
        chatId: chatId ?? this.chatId,
        selectedChatIndex: selectedChatIndex ?? this.selectedChatIndex);
  }

  @override
  List<Object> get props => [chat, chatId, privateChats, selectedChatIndex];
}
