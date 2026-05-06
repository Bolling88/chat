import 'package:chat/repository/serverpod_repository.dart';
import 'package:chat/screens/splash/bloc/splash_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat/utils/auth_util.dart';
import 'package:universal_io/io.dart';
import '../../../utils/log.dart';
import '../../login/bloc/login_state.dart';
import 'splash_event.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final ServerpodRepository _serverpodRepository;

  SplashBloc(this._serverpodRepository) : super(SplashBaseState()) {
    on<SplashInitialEvent>(_onSplashInitialEvent);

    add(SplashInitialEvent());
  }

  Future<void> _onSplashInitialEvent(
      SplashInitialEvent event, Emitter<SplashState> emit) async {
    try {
      if (serverpodClient.auth.isAuthenticated) {
        final chatUser = await _serverpodRepository.getUser();
        if (chatUser == null) {
          emit(SplashLoginState());
        } else if (chatUser.displayName.isEmpty) {
          emit(SplashLoginState());
        } else if (chatUser.birthDate == null && Platform.isAndroid) {
          emit(SplashLoginState());
        } else if (chatUser.gender == -1) {
          emit(SplashLoginState());
        } else {
          if(kIsWeb && (chatUser.isPremiumUser == false && chatUser.isAdmin == false)){
            emit(SplashPremiumState());
          }else {
            emit(const SplashSuccessState(OnboardingNavigation.done));
          }
        }
      } else {
        emit(SplashLoginState());
      }
    } on Exception catch (error, stacktrace) {
      emit(SplashErrorState());
      Log.e('SplashErrorState: $error', stackTrace: stacktrace);
    }
  }
}
