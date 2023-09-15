import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat/model/chat_user.dart';
import 'package:chat/model/private_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/room_chat.dart';
import '../../../repository/firestore_repository.dart';
import '../../../utils/log.dart';
import 'message_holder_event.dart';
import 'message_holder_state.dart';

class MessageHolderBloc extends Bloc<MessageHolderEvent, MessageHolderState> {
  final FirestoreRepository _firestoreRepository;
  final RoomChat chatRoom;

  StreamSubscription<QuerySnapshot>? privateChatStream;
  StreamSubscription<QuerySnapshot>? roomChatStream;

  late ChatUser _chatUser;

  MessageHolderBloc(this._firestoreRepository, this.chatRoom)
      : super(MessageHolderLoadingState()) {
    add(MessageHolderInitialEvent());
  }

  @override
  Future<void> close() {
    privateChatStream?.cancel();
    roomChatStream?.cancel();
    return super.close();
  }

  @override
  Stream<MessageHolderState> mapEventToState(MessageHolderEvent event) async* {
    final currentState = state;
    if (event is MessageHolderInitialEvent) {
      _chatUser = (await _firestoreRepository.getUser())!;
      yield MessageHolderBaseState(
          roomChat: chatRoom,
          chatId: chatRoom.id,
          privateChats: const [],
          selectedChat: chatRoom,
          selectedChatIndex: 0);
      setUpPrivateChatsListener();
      setUpChatsListener();
    } else if (event is MessageHolderStartPrivateChatEvent) {
      if (currentState is MessageHolderBaseState) {
        final bool isChatAvailable =
            await _firestoreRepository.isPrivateChatAvailable(event.user.id);
        if (isChatAvailable) {
          await _firestoreRepository.createPrivateChat(
              otherUser: event.user, myUser: _chatUser);
        } else {
          final privateChat = currentState.privateChats
              .where((element) => element.users.contains(event.user.id))
              .firstOrNull;
          if (privateChat != null) {
            _firestoreRepository.setLastMessageRead(chatId: privateChat.id);
            final int index = currentState.privateChats.indexOf(privateChat);
            yield currentState.copyWith(
                selectedChatIndex: index + 1, selectedChat: privateChat);
          } else {
            Log.e("Private chat not found");
          }
        }
      }
    } else if (event is MessageHolderPrivateChatsUpdatedEvent) {
      if (currentState is MessageHolderBaseState) {
        //If the number of chats have changed...
        if (currentState.privateChats.length != event.privateChats.length) {
          if (currentState.selectedChatIndex == 0) {
            //If we are in the group chat
            if (event.privateChats.length > currentState.privateChats.length) {
              //And private chats have increased
              if (event.privateChats.last.initiatedBy == getUserId()) {
                //And it was by you, move to that chat
                yield currentState.copyWith(
                    privateChats: event.privateChats,
                    selectedChat: event.privateChats.last,
                    selectedChatIndex: event.privateChats.length);
              } else {
                //else just update the chats and play a sound
                final player = AudioPlayer();
                await player.play(UrlSource(
                    'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/audio%2Fstop.mp3?alt=media&token=88032575-9833-4bf5-86fb-554b61820c27'));
                yield currentState.copyWith(privateChats: event.privateChats);
              }
            } else {
              yield currentState.copyWith(privateChats: event.privateChats);
            }
          } else {
            if (event.privateChats.contains(currentState.selectedChat)) {
              //If the private chat we are on still exists
              yield currentState.copyWith(
                  privateChats: event.privateChats,
                  selectedChat: currentState.selectedChat,
                  selectedChatIndex: event.privateChats
                          .indexOf(currentState.selectedChat as PrivateChat) +
                      1);
            } else {
              //The private chat has been removed, move the user to the group chat
              yield currentState.copyWith(
                  privateChats: event.privateChats,
                  selectedChatIndex: 0,
                  roomChat: currentState.roomChat
                      .copyWith(lastMessageReadByUser: true),
                  selectedChat: chatRoom.copyWith(lastMessageReadByUser: true));
            }
          }
        } else {
          // The number of private chats did not change
          yield currentState.copyWith(privateChats: event.privateChats);
        }
      }
    } else if (event is MessageHolderChatUpdatedEvent) {
      if (currentState is MessageHolderBaseState) {
        if (currentState.selectedChat.id == event.chat.id) {
          yield currentState.copyWith(
              roomChat: event.chat.copyWith(lastMessageReadByUser: true));
        } else {
          yield currentState.copyWith(roomChat: event.chat);
        }
      }
    } else if (event is MessageHolderChatClickedEvent) {
      if (currentState is MessageHolderBaseState) {
        if (event.index == 0) {
          yield currentState.copyWith(
              selectedChatIndex: event.index,
              selectedChat: chatRoom.copyWith(lastMessageReadByUser: true),
              roomChat: chatRoom.copyWith(lastMessageReadByUser: true));
        } else {
          _firestoreRepository.setLastMessageRead(chatId: event.chat.id);
          yield currentState.copyWith(
              selectedChatIndex: event.index, selectedChat: event.chat);
        }
      }
    } else if (event is MessageHolderExitChatEvent) {
      if (currentState is MessageHolderBaseState) {
        _firestoreRepository.exitAllChats(chatId: chatRoom.id);
      }
    } else if (event is MessageHolderClosePrivateChatEvent) {
      Log.d("Closing private chat");
      if (currentState is MessageHolderBaseState) {
        if (event.privateChat != null) {
          //This is called on big screens, and can be called from any other chat
          _firestoreRepository.leavePrivateChat(event.privateChat!);
          if (event.privateChat == currentState.selectedChat) {
            yield currentState.copyWith(
                selectedChat: chatRoom, selectedChatIndex: 0);
          }
        } else {
          //This is called from a small screen, and the current chat, so we must move to the room again
          _firestoreRepository
              .leavePrivateChat(currentState.selectedChat as PrivateChat);
          yield currentState.copyWith(
              selectedChat: chatRoom, selectedChatIndex: 0);
        }
      }
    } else {
      throw UnimplementedError();
    }
  }

  void setUpPrivateChatsListener() async {
    Log.d('Setting up private chats stream');
    privateChatStream =
        _firestoreRepository.streamPrivateChats().listen((data) {
      Log.d("Got private chats");
      final chats = data.docs
          .map((e) =>
              PrivateChat.fromJson(e.id, e.data() as Map<String, dynamic>))
          .toList()
          .reversed
          .toList();
      Log.d("Chats: ${chats.length}");
      add(MessageHolderPrivateChatsUpdatedEvent(chats));
    });
  }

  void setUpChatsListener() async {
    Log.d('Setting up private chats stream');
    roomChatStream = _firestoreRepository
        .streamChat(chatRoom.id, false)
        .listen((event) async {
      final chat = RoomChat.fromJson(
          event.docs.first.id, event.docs.first.data() as Map<String, dynamic>);
      add(MessageHolderChatUpdatedEvent(chat));
    });
  }
}
