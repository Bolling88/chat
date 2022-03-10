import 'package:chat/screens/splash/bloc/splash_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repository/data_repository.dart';
import '../../../utils/log.dart';
import '../../../utils/save_file.dart';
import 'splash_event.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {

  SplashBloc() : super(SplashBaseState()) {
    add(SplashInitialEvent());
  }

  @override
  Stream<SplashState> mapEventToState(SplashEvent event) async* {
    try {
      if (event is SplashInitialEvent) {
        if (FirebaseAuth.instance.currentUser != null) {
          yield SplashSuccessState();
        } else {
          yield SplashLoginState();
        }
      }else{
        Log.e('SplashBloc: Not implemented');
        throw UnimplementedError();
      }
    } on Exception catch (error, stacktrace) {
      yield SplashErrorState();
      Log.e('SplashErrorState: $error', stackTrace: stacktrace);
    }
  }
}
