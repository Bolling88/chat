import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/splash/bloc/splash_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:universal_io/io.dart';
import '../../../utils/log.dart';
import '../../login/bloc/login_state.dart';
import 'splash_event.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final FirestoreRepository _firestoreRepository;


  SplashBloc(this._firestoreRepository) : super(SplashBaseState()) {
    add(SplashInitialEvent());
  }

  @override
  Stream<SplashState> mapEventToState(SplashEvent event) async* {
    try {
      if (event is SplashInitialEvent) {
        if (FirebaseAuth.instance.currentUser != null) {
          final chatUser = await _firestoreRepository.getUser();
          if (chatUser == null) {
            yield SplashLoginState();
          } else if (chatUser.displayName.isEmpty) {
            yield const SplashSuccessState(OnboardingNavigation.NAME);
          }else if(chatUser.birthDate == null && Platform.isAndroid){
            yield const SplashSuccessState(OnboardingNavigation.AGE);
          } else if (chatUser.gender == -1) {
            yield const SplashSuccessState(OnboardingNavigation.GENDER);
          } else {
            yield const SplashSuccessState(OnboardingNavigation.DONE);
          }
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
