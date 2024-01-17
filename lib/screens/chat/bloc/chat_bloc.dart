import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/room_chat.dart';
import '../../../model/chat_user.dart';
import '../../../repository/firestore_repository.dart';
import '../../../utils/log.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirestoreRepository _firestoreRepository;

  late StreamSubscription<QuerySnapshot> chatStream;
  late StreamSubscription<List<ChatUser>> onlineUsersStream;
  final List<ChatUser> _initialUsers;

  ChatBloc(this._firestoreRepository, this._initialUsers) : super(ChatLoadingState()) {
    add(ChatInitialEvent());
  }

  @override
  Future<void> close() {
    chatStream.cancel();
    onlineUsersStream.cancel();
    return super.close();
  }

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    final currentState = state;
    if (event is ChatInitialEvent) {
      final user = await _firestoreRepository.getUser();
      if(user != null) {
        setUpChatListener(user);
        setUpPeopleListener();
      }else{
        Log.e('ChatInitialEvent: User is null');
      }
    } else if (event is ChatUpdatedEvent) {
      if (currentState is ChatBaseState) {
        yield currentState.copyWith(chats: event.chats);
      } else {
        yield ChatBaseState(event.chats, groupUsersByChat(_initialUsers));
      }
    } else if (event is ChatOnlineUsersUpdatedEvent) {
      if (currentState is ChatBaseState) {
        yield currentState.copyWith(onlineUsers: event.onlineUsers);
      } else {
        yield ChatBaseState(const [], event.onlineUsers);
      }
    } else {
      throw UnimplementedError();
    }
  }

  void setUpChatListener(ChatUser user) async {
    Log.d("Setting up chat listener");
    chatStream = _firestoreRepository.streamOpenChats(user).listen((event) {
      final List<RoomChat> chats = event.docs
          .map((e) => RoomChat.fromJson(e.id, e.data() as Map<String, dynamic>))
          .toList();
      Log.d('Chats: $chats');
      chats.sort((a, b) => b.chatName.compareTo(a.chatName));
      final reversedChats = chats.reversed;

      add(ChatUpdatedEvent(reversedChats.toList()));
    });
  }

  void setUpPeopleListener() {
    onlineUsersStream =
        _firestoreRepository.onlineUsersStream.listen((event) async {
      Map<String, List<ChatUser>> usersPerChat = groupUsersByChat(event);
      Log.d('ChatOnlineUsersUpdatedEvent');
      add(ChatOnlineUsersUpdatedEvent(usersPerChat));
    });
  }

  Map<String, List<ChatUser>> groupUsersByChat(List<ChatUser> users) {
    final usersPerChat = <String, List<ChatUser>>{};
    for (var user in users) {
      if (user.currentRoomChatId.isNotEmpty) {
        if (usersPerChat.containsKey(user.currentRoomChatId)) {
          usersPerChat[user.currentRoomChatId]!.add(user);
        } else {
          usersPerChat[user.currentRoomChatId] = [user];
        }
      }
    }
    return usersPerChat;
  }
}
