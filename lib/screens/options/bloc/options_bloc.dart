import 'dart:async';

import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/options/bloc/options_state.dart';
import 'package:chat/screens/options/bloc/options_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_io/io.dart';
import '../../../utils/cloud_translation/google_cloud_translation.dart';
import '../../../utils/log.dart';

const androidTranslateKey = 'AIzaSyDA_Ok3f2_H3bWZhKgiVzrPR6s5nYE4YKY';
const iOSTranslateKey = 'AIzaSyDrYtpHeq3jcb2SSqr4Da9wC-GYfXOd6ko';
const webTranslateKey = 'AIzaSyChD4747kdf9R6l5WehknJfXeTgPmUK34o';

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
         translator = Translation(apiKey: kIsWeb? webTranslateKey : Platform.isIOS? iOSTranslateKey : androidTranslateKey, onError: (error) {
          Log.e('Translation error: $error');
        });
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
