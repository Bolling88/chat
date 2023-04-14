import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat.dart';
import '../../../repository/firestore_repository.dart';
import 'message_holder_event.dart';
import 'message_holder_state.dart';

class MessageHolderBloc extends Bloc<MessageHolderEvent, MessageHolderState> {
  final FirestoreRepository _firestoreRepository;
  Chat? chat;
  final String? chatId;

  MessageHolderBloc(this._firestoreRepository, this.chat, this.chatId)
      : super(PartyMessageLoadingState()) {
    add(PartyMessageInitialEvent());
  }

  @override
  Stream<MessageHolderState> mapEventToState(MessageHolderEvent event) async* {
    if (event is PartyMessageInitialEvent) {
      chat ??= await _firestoreRepository.getChat(chatId!);
      _firestoreRepository.setLastMessageRead(chat?.id ?? '');
      yield MessageHolderBaseState(chat!, chat?.id ?? '');
    } else {
      throw UnimplementedError();
    }
  }
}
