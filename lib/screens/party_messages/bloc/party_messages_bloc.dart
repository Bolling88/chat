import 'package:chat/screens/party_messages/bloc/party_messages_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../model/chat.dart';
import '../../../repository/firestore_repository.dart';
import 'party_messages_event.dart';

class PartyMessagesBloc extends Bloc<PartyMessagesEvent, PartyMessagesState> {
  final FirestoreRepository _firestoreRepository;
  Chat? chat;
  final String? chatId;

  PartyMessagesBloc(this._firestoreRepository, this.chat, this.chatId)
      : super(PartyMessageLoadingState()) {
    add(PartyMessageInitialEvent());
  }

  @override
  Stream<PartyMessagesState> mapEventToState(PartyMessagesEvent event) async* {
    if (event is PartyMessageInitialEvent) {
      chat ??= await _firestoreRepository.getChat(chatId!);
      _firestoreRepository.setLastMessageRead(chat?.id ?? '');
      yield PartyMessagesBaseState(chat!, chat?.id ?? '');
    } else {
      throw UnimplementedError();
    }
  }
}
