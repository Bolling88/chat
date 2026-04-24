import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/room_chat.dart';
import '../../../model/chat_user.dart';
import '../../../repository/supabase_repository.dart';
import '../../../utils/log.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SupabaseRepository _supabaseRepository;

  StreamSubscription<List<RoomChat>>? chatStream;
  StreamSubscription<List<ChatUser>>? onlineUsersStream;
  StreamSubscription<ChatUser?>? userStream;
  final List<ChatUser> _initialUsers;

  ChatBloc(this._supabaseRepository, this._initialUsers)
      : super(ChatLoadingState()) {
    on<ChatInitialEvent>(_onInitialEvent);
    on<ChatUpdatedEvent>(_onUpdatedEvent);
    on<ChatOnlineUsersUpdatedEvent>(_onOnlineUsersUpdatedEvent);
    on<ChatUserUpdatedEvent>(_onUserUpdatedEvent);

    add(ChatInitialEvent());
  }

  @override
  Future<void> close() {
    chatStream?.cancel();
    onlineUsersStream?.cancel();
    userStream?.cancel();
    return super.close();
  }

  void _onInitialEvent(
    ChatInitialEvent event,
    Emitter<ChatState> emit,
  ) {
    setUpUserListener();
  }

  void _onUpdatedEvent(
    ChatUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    final currentState = state;
    if (currentState is ChatBaseState) {
      emit(currentState.copyWith(chats: event.chats));
    } else {
      emit(ChatBaseState(
          chats: event.chats, onlineUsers: groupUsersByChat(_initialUsers)));
    }
  }

  void _onOnlineUsersUpdatedEvent(
    ChatOnlineUsersUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    final currentState = state;
    if (currentState is ChatBaseState) {
      emit(currentState.copyWith(onlineUsers: event.onlineUsers));
    } else {
      emit(ChatBaseState(
          chats: const [], onlineUsers: event.onlineUsers));
    }
  }

  void _onUserUpdatedEvent(
    ChatUserUpdatedEvent event,
    Emitter<ChatState> emit,
  ) {
    final currentState = state;
    if (currentState is ChatBaseState) {
      //Do nothing, user info is not of interest for the state
    } else {
      //Set up the remaining listeners and load the UI
      setUpPeopleListener();
      setUpChatListener(event.chatUser);
      emit(ChatBaseState(
          chats: const [], onlineUsers: groupUsersByChat(_initialUsers)));
    }
  }

  void setUpChatListener(ChatUser user) async {
    Log.d("Setting up chat listener");
    chatStream = _supabaseRepository.streamOpenChats(user).listen((chats) {
      Log.d('Chats: $chats');
      chats.sort((a, b) => b.chatName.compareTo(a.chatName));
      final reversedChats = chats.reversed;

      add(ChatUpdatedEvent(reversedChats.toList()));
    });
  }

  void setUpPeopleListener() {
    onlineUsersStream =
        _supabaseRepository.onlineUsersStream.listen((event) async {
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
    userStream = _supabaseRepository.streamUser().listen((user) async {
      if (user == null) {
        Log.d('No user found');
        return;
      }
      add(ChatUserUpdatedEvent(user));
    });
  }
}
