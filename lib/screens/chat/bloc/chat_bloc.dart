import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/room_chat.dart';
import '../../../model/chat_user.dart';
import '../../../model/user_location.dart';
import '../../../repository/firestore_repository.dart';
import '../../../repository/network_repository.dart';
import '../../../utils/log.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirestoreRepository _firestoreRepository;
  late ChatUser user;

  late StreamSubscription<QuerySnapshot> chatStream;

  ChatBloc(this._firestoreRepository) : super(ChatLoadingState()) {
    add(ChatInitialEvent());
  }

  @override
  Future<void> close() {
    chatStream.cancel();
    return super.close();
  }

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    if (event is ChatInitialEvent) {
      user = (await _firestoreRepository.getUser())!;
      Log.d('Got User: ${user.displayName}');
      setUpDataListener();
      updateUserLocation();
    } else if (event is ChatUpdatedEvent) {
      final chats = event.chats;
      if (chats.isEmpty) {
        yield ChatEmptyState();
      } else {
        Set<String> userIds = {};
        for (var chat in chats) {
          userIds.addAll(chat.users);
        }

        yield ChatBaseState(chats, user);
      }
    } else {
      throw UnimplementedError();
    }
  }

  void setUpDataListener() async {
    Log.d("Setting up chat listener");
    chatStream = _firestoreRepository.streamChats().listen((event) {
      final List<RoomChat> chats = event.docs
          .map((e) => RoomChat.fromJson(e.id, e.data() as Map<String, dynamic>))
          .toList();
      Log.d('Chats: $chats');
      chats.sort((a, b) => b.chatName.compareTo(a.chatName));
      final reversedChats = chats.reversed;

      add(ChatUpdatedEvent(reversedChats.toList()));
    });
  }

  void updateUserLocation()async{
    UserLocation userLocation = await getUserLocation();
    _firestoreRepository.updateUserLocation(userLocation);
  }
}

class ChatsAndUser {
  final ChatUser user;
  final List<RoomChat> chats;

  ChatsAndUser(this.user, this.chats);
}
