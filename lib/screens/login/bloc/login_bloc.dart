import 'package:chat/repository/serverpod_auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat_user.dart';
import '../../../repository/serverpod_repository.dart';
import '../../../utils/log.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final ServerpodAuthRepository _authRepository;
  final ServerpodRepository _serverpodRepository;

  LoginBloc(this._authRepository, this._serverpodRepository)
      : super(LoginBaseState()) {
    on<LoginGoogleClickedEvent>(_onGoogleClicked);
    on<LoginAppleClickedEvent>(_onAppleClicked);
  }

  Future<void> _onGoogleClicked(
      LoginGoogleClickedEvent event, Emitter<LoginState> emit) async {
    try {
      emit(LoginLoadingState());
      final success = await _authRepository.signInWithGoogle();
      if (!success) {
        emit(LoginErrorState());
      } else {
        await _serverpodRepository.setInitialUserData('', '');
        final chatUser = await _serverpodRepository.getUser();
        emit(await checkIfOnboardingIsDone(chatUser));
      }
    } on Exception catch (exception, stacktrace) {
      Log.e(exception, stackTrace: stacktrace);
      emit(LoginErrorState());
    }
  }

  Future<void> _onAppleClicked(
      LoginAppleClickedEvent event, Emitter<LoginState> emit) async {
    try {
      emit(LoginLoadingState());
      final success = await _authRepository.signInWithApple();
      if (!success) {
        emit(LoginErrorState());
      } else {
        await _serverpodRepository.setInitialUserData('', '');
        final chatUser = await _serverpodRepository.getUser();
        emit(await checkIfOnboardingIsDone(chatUser));
      }
    } on Exception catch (exception, stacktrace) {
      Log.e(exception, stackTrace: stacktrace);
      emit(LoginErrorState());
    }
  }

  Future<LoginState> checkIfOnboardingIsDone(final ChatUser? chatUser) async {
    if (chatUser == null || chatUser.displayName.isEmpty) {
      return const LoginSuccessState(OnboardingNavigation.name);
    } else if (chatUser.pictureData.isEmpty) {
      return const LoginSuccessState(OnboardingNavigation.picture);
    } else if (chatUser.gender == -1) {
      return const LoginSuccessState(OnboardingNavigation.gender);
    } else {
      return const LoginSuccessState(OnboardingNavigation.done);
    }
  }
}
