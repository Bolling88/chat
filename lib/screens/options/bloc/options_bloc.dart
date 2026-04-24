import 'dart:async';

import 'package:chat/repository/supabase_repository.dart';
import 'package:chat/screens/options/bloc/options_state.dart';
import 'package:chat/screens/options/bloc/options_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_io/io.dart';
import '../../../model/chat_user.dart';
import '../../../utils/cloud_translation/google_cloud_translation.dart';
import '../../../utils/cloud_translation/translator.dart';
import '../../../utils/log.dart';

class OptionsBloc extends Bloc<OptionsEvent, OptionsState> {
  final SupabaseRepository _supabaseRepository;
  late StreamSubscription<ChatUser?> userStream;

  late Translation translator;

  @override
  Future<void> close() {
    userStream.cancel();
    return super.close();
  }

  OptionsBloc(this._supabaseRepository) : super(OptionsLoadingState()) {
    on<OptionsInitialEvent>(_onOptionsInitialEvent);
    on<OptionsTranslateEvent>(_onOptionsTranslateEvent);
    on<OptionsUserChangedEvent>(_onOptionsUserChangedEvent);

    add(OptionsInitialEvent());
  }

  void _onOptionsInitialEvent(
    OptionsInitialEvent event,
    Emitter<OptionsState> emit,
  ) {
    try {
      translator = getTranslator();
      setUpUserListener();
    } on Exception catch (error, stacktrace) {
      emit(OptionsErrorState());
      Log.e('OptionsErrorState: $error', stackTrace: stacktrace);
    }
  }

  Future<void> _onOptionsTranslateEvent(
    OptionsTranslateEvent event,
    Emitter<OptionsState> emit,
  ) async {
    final currentState = state;
    try {
      if (currentState is OptionsBaseState) {
        emit(OptionsLoadingState());
        final user = currentState.user;
        if (user.kvitterCredits > 0 || kIsWeb || user.isPremiumUser) {
          String deviceLanguage = Platform.localeName.substring(0, 2);
          final translation = await translator.translate(
              text: event.text, to: deviceLanguage);
          emit(OptionsTranslationDoneState(translation: translation));
          if (!kIsWeb || user.isPremiumUser) {
            _supabaseRepository.reduceUserCredits(user.id, 1);
          }
        } else {
          emit(OptionsShowCreditsOfferState(user: user));
        }
      }
    } on Exception catch (error, stacktrace) {
      emit(OptionsErrorState());
      Log.e('OptionsErrorState: $error', stackTrace: stacktrace);
    }
  }

  void _onOptionsUserChangedEvent(
    OptionsUserChangedEvent event,
    Emitter<OptionsState> emit,
  ) {
    try {
      emit(OptionsBaseState(user: event.user));
    } on Exception catch (error, stacktrace) {
      emit(OptionsErrorState());
      Log.e('OptionsErrorState: $error', stackTrace: stacktrace);
    }
  }

  void setUpUserListener() async {
    Log.d('Setting up private chats stream');
    userStream = _supabaseRepository.streamUser().listen((user) async {
      if (user == null) {
        Log.d('No user found');
        return;
      }
      add(OptionsUserChangedEvent(user));
    });
  }
}
