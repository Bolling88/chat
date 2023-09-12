import 'dart:async';
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

  ChatBloc(this._firestoreRepository) : super(ChatLoadingState()) {
    add(ChatInitialEvent());
  }

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    if (event is ChatInitialEvent) {
      user = (await _firestoreRepository.getUser())!;
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
    Log.d("Setting up data listener");
    _firestoreRepository.streamChats().listen((event) {
      final List<RoomChat> chats = event.docs
          .map((e) => RoomChat.fromJson(e.id, e.data() as Map<String, dynamic>))
          .toList();
      chats.sort((a, b) => b.chatName.compareTo(a.chatName));

      add(ChatUpdatedEvent(chats));
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
