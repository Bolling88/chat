import 'package:chat/repository/firestore_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/log.dart';
import 'create_chat_event.dart';
import 'create_chat_state.dart';

class CreateChatBloc extends Bloc<CreateChatEvent, CreateChatState> {
  final FirestoreRepository _firestoreRepository;

  CreateChatBloc(this._firestoreRepository)
      : super(const CreateChatBaseState(name: '')) {
    add(CreateChatInitialEvent());
  }

  @override
  Stream<CreateChatState> mapEventToState(CreateChatEvent event) async* {
    final currentState = state;
    try {
      if (event is CreateChatInitialEvent) {
      } else if (event is CreateChatNameChangedEvent) {
        if (currentState is CreateChatBaseState) {
          Log.d(event.name);
          yield currentState.copyWith(name: event.name);
        }
      } else if (event is CreateChatContinueClickedEvent) {
        if (currentState is CreateChatBaseState) {
          yield CreateChatLoadingState();
          await _firestoreRepository.createChat(chatName: currentState.name);
          yield CreateChatSuccessState(name: currentState.name);
        }
      } else {
        Log.e('CreateChatBloc: Not implemented');
        throw UnimplementedError();
      }
    } on Exception catch (error, stacktrace) {
      yield CreateChatErrorState();
      Log.e('CreateChatErrorState: $error', stackTrace: stacktrace);
    }
  }
}
