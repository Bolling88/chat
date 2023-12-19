import 'package:chat/model/private_chat.dart';
import 'package:equatable/equatable.dart';
import '../../../model/chat.dart';
import '../../../model/chat_user.dart';
import '../../../model/room_chat.dart';

abstract class MessageHolderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MessageHolderLoadingState extends MessageHolderState {}

class MessageHolderBaseState extends MessageHolderState {
  final RoomChat? roomChat;
  final ChatUser user;
  final List<PrivateChat> privateChats;
  final List<ChatUser> onlineUsers;
  final Chat? selectedChat;
  final int selectedChatIndex;

  MessageHolderBaseState({
    required this.roomChat,
    required this.user,
    required this.privateChats,
    required this.onlineUsers,
    required this.selectedChat,
    required this.selectedChatIndex,
  });

  MessageHolderBaseState copyWith({
    RoomChat? roomChat,
    ChatUser? user,
    List<PrivateChat>? privateChats,
    List<ChatUser>? onlineUsers,
    Chat? selectedChat,
    int? selectedChatIndex,
  }) {
    return MessageHolderBaseState(
      roomChat: roomChat ?? this.roomChat,
      user: user ?? this.user,
      privateChats: privateChats ?? this.privateChats,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      selectedChat: selectedChat ?? this.selectedChat,
      selectedChatIndex: selectedChatIndex ?? this.selectedChatIndex,
    );
  }

  @override
  List<Object?> get props => [
        roomChat,
        user,
        privateChats,
        onlineUsers,
        selectedChat,
        selectedChatIndex,
      ];
}

class MessageHolderLikeDialogState extends MessageHolderBaseState {
  MessageHolderLikeDialogState(MessageHolderBaseState state)
      : super(
            roomChat: state.roomChat,
            user: state.user,
            privateChats: state.privateChats,
            onlineUsers: state.onlineUsers,
            selectedChat: state.selectedChat,
            selectedChatIndex: state.selectedChatIndex);
}

class MessageHolderShowOnlineUsersInChatState extends MessageHolderBaseState {
  final Chat chat;
  MessageHolderShowOnlineUsersInChatState(MessageHolderBaseState state, this.chat)
      : super(
      roomChat: state.roomChat,
      user: state.user,
      privateChats: state.privateChats,
      onlineUsers: state.onlineUsers,
      selectedChat: state.selectedChat,
      selectedChatIndex: state.selectedChatIndex);
}
