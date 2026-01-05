import 'package:chat/repository/login_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat_user.dart';
import '../../../repository/firestore_repository.dart';
import '../../../utils/log.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository _loginRepository;
  final FirestoreRepository _firestoreRepository;

  LoginBloc(this._loginRepository, this._firestoreRepository)
      : super(LoginBaseState()) {
    on<LoginGoogleClickedEvent>(_onGoogleClicked);
    on<LoginAppleClickedEvent>(_onAppleClicked);
    on<LoginGuestClickedEvent>(_onGuestClicked);
  }

  Future<void> _onGoogleClicked(
      LoginGoogleClickedEvent event, Emitter<LoginState> emit) async {
    try {
      emit(LoginLoadingState());
      final credentials = await _loginRepository.signInWithGoogle();
      if (credentials == null) {
        emit(LoginErrorState());
      } else {
        final chatUser = await _firestoreRepository.getUser();
        if (chatUser == null || chatUser.displayName.isEmpty) {
          await _firestoreRepository.setInitialUserData(
              credentials.user?.email ?? "", credentials.user?.uid ?? "");
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
      final appleCredentials = await _loginRepository.signInWithApple();

      if (appleCredentials != null) {
        final chatUser = await _firestoreRepository.getUser();
        if (chatUser == null || chatUser.displayName.isEmpty) {
          await _firestoreRepository.setInitialUserData(
              appleCredentials.user?.email ?? "",
              appleCredentials.user?.uid ?? "");
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
      if (FirebaseAuth.instance.currentUser != null) {
        final chatUser = await _firestoreRepository.getUser();
        emit(await checkIfOnboardingIsDone(chatUser));
      } else {
        final credentials = await FirebaseAuth.instance.signInAnonymously();
        await _firestoreRepository.setInitialUserData(
            "", credentials.user?.uid ?? "");
        emit(await checkIfOnboardingIsDone(null));
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
