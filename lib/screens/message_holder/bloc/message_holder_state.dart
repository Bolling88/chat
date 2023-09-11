import 'package:chat/model/private_chat.dart';
import 'package:equatable/equatable.dart';
import '../../../model/chat.dart';
import '../../../model/room_chat.dart';

abstract class MessageHolderState extends Equatable {
  @override
  List<Object> get props => [];
}

class MessageHolderLoadingState extends MessageHolderState {}

class MessageHolderBaseState extends MessageHolderState {
  final String chatId;
  final RoomChat roomChat;
  final List<PrivateChat> privateChats;
  final Chat selectedChat;
  final int selectedChatIndex;

  MessageHolderBaseState({
    required this.roomChat,
    required this.privateChats,
    required this.chatId,
    required this.selectedChat,
    required this.selectedChatIndex,
  });

  MessageHolderBaseState copyWith({
    RoomChat? roomChat,
    List<PrivateChat>? privateChats,
    String? chatId,
    Chat? selectedChat,
    int? selectedChatIndex,
  }) {
    return MessageHolderBaseState(
      roomChat: roomChat ?? this.roomChat,
      privateChats: privateChats ?? this.privateChats,
      chatId: chatId ?? this.chatId,
      selectedChat: selectedChat ?? this.selectedChat,
      selectedChatIndex: selectedChatIndex ?? this.selectedChatIndex,
    );
  }

  @override
  List<Object> get props => [
        roomChat,
        chatId,
        privateChats,
        selectedChat,
        selectedChatIndex,
      ];
}
