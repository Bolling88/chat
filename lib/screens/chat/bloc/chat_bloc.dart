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

  StreamSubscription<QuerySnapshot>? chatStream;
  StreamSubscription<List<ChatUser>>? onlineUsersStream;
  StreamSubscription<QuerySnapshot>? userStream;
  final List<ChatUser> _initialUsers;

  ChatBloc(this._firestoreRepository, this._initialUsers)
      : super(ChatLoadingState()) {
    add(ChatInitialEvent());
  }

  @override
  Future<void> close() {
    chatStream?.cancel();
    onlineUsersStream?.cancel();
    userStream?.cancel();
    return super.close();
  }

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    final currentState = state;
    if (event is ChatInitialEvent) {
      setUpUserListener();
    } else if (event is ChatUpdatedEvent) {
      if (currentState is ChatBaseState) {
        yield currentState.copyWith(chats: event.chats);
      } else {
        yield ChatBaseState(
            chats: event.chats, onlineUsers: groupUsersByChat(_initialUsers));
      }
    } else if (event is ChatOnlineUsersUpdatedEvent) {
      if (currentState is ChatBaseState) {
        yield currentState.copyWith(onlineUsers: event.onlineUsers);
      } else {
        yield ChatBaseState(
            chats: const [], onlineUsers: event.onlineUsers);
      }
    } else if (event is ChatUserUpdatedEvent) {
      if (currentState is ChatBaseState) {
        //Do nothing, user info is not of interest for the state
      } else {
        //Set up the remaining listeners and load the UI
        setUpPeopleListener();
        setUpChatListener(event.chatUser);
        yield ChatBaseState(
            chats: const [], onlineUsers: groupUsersByChat(_initialUsers));
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

  // TODO move to isolate?
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

  void setUpUserListener() async {
    Log.d('Setting up private chats stream');
    userStream = _firestoreRepository.streamUser().listen((event) async {
      if (event.docs.isEmpty) {
        Log.d('No user found');
        return;
      }
      final Map<String, dynamic> userData =
          event.docs.first.data() as Map<String, dynamic>;

      // Convert Timestamp to int (milliseconds since epoch)
      if (userData.containsKey('lastActive') &&
          userData['lastActive'] is Timestamp) {
        userData['lastActive'] =
            (userData['lastActive'] as Timestamp).millisecondsSinceEpoch;
      }
      final user = ChatUser.fromJson(event.docs.first.id, userData);
      add(ChatUserUpdatedEvent(user));
    });
  }
}
