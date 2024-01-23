import 'dart:async';

import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/options/bloc/options_state.dart';
import 'package:chat/screens/options/bloc/options_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_io/io.dart';
import '../../../model/chat_user.dart';
import '../../../utils/cloud_translation/google_cloud_translation.dart';
import '../../../utils/cloud_translation/translator.dart';
import '../../../utils/log.dart';

class OptionsBloc extends Bloc<OptionsEvent, OptionsState> {
  final FirestoreRepository _firestoreRepository;
  late StreamSubscription<QuerySnapshot<Object?>> userStream;

  late Translation translator;

  @override
  Future<void> close() {
    userStream.cancel();
    return super.close();
  }

  OptionsBloc(this._firestoreRepository) : super(OptionsLoadingState()) {
    add(OptionsInitialEvent());
  }

  @override
  Stream<OptionsState> mapEventToState(OptionsEvent event) async* {
    final currentState = state;
    try {
      if (event is OptionsInitialEvent) {
        translator = getTranslator();
        setUpUserListener();
        yield const OptionsBaseState();
      } else if (event is OptionsTranslateEvent) {
        if (currentState is OptionsBaseState) {
          yield OptionsLoadingState();
          final user = currentState.user;
          if(user == null){
            throw Exception('User is null');
          }else{
            if(user.kvitterCredits > 1){
              String deviceLanguage = Platform.localeName.substring(0, 2);
              final translation =
              await translator.translate(text: event.text, to: deviceLanguage);
              yield OptionsTranslationDoneState(translation: translation);
              _firestoreRepository.reduceUserCredits(user.id, 1);
            }else{
              //TODO show offer to get tokens by viewing a rewarded ad
            }
          }
        }
      } else if (event is OptionsUserChangedEvent) {
        if (currentState is OptionsBaseState) {
          yield OptionsBaseState(user: event.user);
        }
      }
    } on Exception catch (error, stacktrace) {
      yield OptionsErrorState();
      Log.e('OptionsErrorState: $error', stackTrace: stacktrace);
    }
  }

  void setUpUserListener() async {
    Log.d('Setting up private chats stream');
    userStream = _firestoreRepository.streamUser().listen((event) async {
      final user = ChatUser.fromJson(
          event.docs.first.id, event.docs.first.data() as Map<String, dynamic>);
      add(OptionsUserChangedEvent(user));
    });
  }
}
