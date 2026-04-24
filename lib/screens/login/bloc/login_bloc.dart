import 'package:chat/repository/supabase_auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat_user.dart';
import '../../../repository/supabase_repository.dart';
import '../../../utils/log.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SupabaseAuthRepository _authRepository;
  final SupabaseRepository _supabaseRepository;

  LoginBloc(this._authRepository, this._supabaseRepository)
      : super(LoginBaseState()) {
    on<LoginGoogleClickedEvent>(_onGoogleClicked);
    on<LoginAppleClickedEvent>(_onAppleClicked);
    on<LoginGuestClickedEvent>(_onGuestClicked);
  }

  Future<void> _onGoogleClicked(
      LoginGoogleClickedEvent event, Emitter<LoginState> emit) async {
    try {
      emit(LoginLoadingState());
      final credentials = await _authRepository.signInWithGoogle();
      if (credentials == null) {
        emit(LoginErrorState());
      } else {
        final chatUser = await _supabaseRepository.getUser();
        if (chatUser == null || chatUser.displayName.isEmpty) {
          await _supabaseRepository.setInitialUserData(
              credentials.user?.email ?? "", credentials.user?.id ?? "");
          emit(const LoginSuccessState(OnboardingNavigation.name));
        } else {
          emit(await checkIfOnboardingIsDone(chatUser));
        }
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
      final appleCredentials = await _authRepository.signInWithApple();

      if (appleCredentials != null) {
        final chatUser = await _supabaseRepository.getUser();
        if (chatUser == null || chatUser.displayName.isEmpty) {
          await _supabaseRepository.setInitialUserData(
              appleCredentials.user?.email ?? "",
              appleCredentials.user?.id ?? "");
          Log.d("User logged in!");
          if (chatUser != null) {
            emit(await checkIfOnboardingIsDone(chatUser));
          } else {
            emit(LoginErrorState());
          }
        } else {
          emit(await checkIfOnboardingIsDone(chatUser));
        }
      } else {
        emit(LoginErrorState());
      }
    } on Exception catch (exception, stacktrace) {
      Log.e(exception, stackTrace: stacktrace);
      emit(LoginErrorState());
    }
  }

  Future<void> _onGuestClicked(
      LoginGuestClickedEvent event, Emitter<LoginState> emit) async {
    try {
      emit(LoginLoadingState());
      final credentials = await _authRepository.signInAnonymously();
      await _supabaseRepository.setInitialUserData(
          "", credentials?.user?.id ?? "");
      emit(await checkIfOnboardingIsDone(null));
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
