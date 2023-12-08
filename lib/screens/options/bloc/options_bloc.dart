import 'dart:async';

import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/options/bloc/options_state.dart';
import 'package:chat/screens/options/bloc/options_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_io/io.dart';
import '../../../utils/cloud_translation/google_cloud_translation.dart';
import '../../../utils/cloud_translation/translator.dart';
import '../../../utils/log.dart';

class OptionsBloc extends Bloc<OptionsEvent, OptionsState> {
  final FirestoreRepository _firestoreRepository;

  late Translation translator;

  OptionsBloc(this._firestoreRepository) : super(OptionsLoadingState()) {
    add(OptionsInitialEvent());
  }

  @override
  Stream<OptionsState> mapEventToState(OptionsEvent event) async* {
    final currentState = state;
    try {
      if (event is OptionsInitialEvent) {
         translator = getTranslator();
        yield const OptionsBaseState();
      }else if (event is OptionsTranslateEvent) {
        if(currentState is OptionsBaseState){
          yield OptionsLoadingState();
          String deviceLanguage= Platform.localeName.substring(0,2);
          final translation = await translator.translate(text: event.text, to: deviceLanguage);
          yield OptionsTranslationDoneState(translation: translation);
        }
      }
    } on Exception catch (error, stacktrace) {
      yield OptionsErrorState();
      Log.e('OptionsErrorState: $error', stackTrace: stacktrace);
    }
  }
}
