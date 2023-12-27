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
      : super(LoginBaseState());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    try {
      if (event is LoginGoogleClickedEvent) {
        yield LoginLoadingState();
        final credentials = await _loginRepository.signInWithGoogle();
        if (credentials == null) {
          yield LoginErrorState();
        } else {
          final chatUser = await _firestoreRepository.getUser();
          if (chatUser == null || chatUser.displayName.isEmpty) {
            await _firestoreRepository.setInitialUserData(
                credentials.user?.email ?? "", credentials.user?.uid ?? "");
            yield const LoginSuccessState(OnboardingNavigation.NAME);
          } else {
            yield await checkIfOnboardingIsDone(chatUser);
          }
        }
      } else if (event is LoginAppleClickedEvent) {
        yield LoginLoadingState();
        final appleCredentials =
            await _loginRepository.signInWithApple();

        if(appleCredentials != null) {
          final chatUser = await _firestoreRepository.getUser();
          if (chatUser == null || chatUser.displayName.isEmpty) {
            await _firestoreRepository.setInitialUserData(
                appleCredentials.user?.email ?? "",
                appleCredentials.user?.uid ?? "");
            Log.d("User logged in!");
            if (chatUser != null) {
              yield await checkIfOnboardingIsDone(chatUser);
            } else {
              yield LoginErrorState();
            }
          } else {
            yield await checkIfOnboardingIsDone(chatUser);
          }
        }else{
          yield LoginErrorState();
        }
      } else if (event is LoginGuestClickedEvent) {
        yield LoginLoadingState();
        if (FirebaseAuth.instance.currentUser != null) {
          final chatUser = await _firestoreRepository.getUser();
          yield await checkIfOnboardingIsDone(chatUser);
        }else {
          final credentials = await FirebaseAuth.instance.signInAnonymously();
          await _firestoreRepository.setInitialUserData(
              "", credentials.user?.uid ?? "");
          yield await checkIfOnboardingIsDone(null);
        }
      } else {
        yield LoginErrorState();
      }
    } on Exception catch (exception, stacktrace) {
      Log.e(exception, stackTrace: stacktrace);
      yield LoginErrorState();
    }
  }

  Future<LoginState> checkIfOnboardingIsDone(final ChatUser? chatUser) async {
    if (chatUser == null || chatUser.displayName.isEmpty) {
      return const LoginSuccessState(OnboardingNavigation.NAME);
    } else if (chatUser.pictureData.isEmpty) {
      return const LoginSuccessState(OnboardingNavigation.PICTURE);
    } else if (chatUser.gender == -1) {
      return const LoginSuccessState(OnboardingNavigation.GENDER);
    } else {
      return const LoginSuccessState(OnboardingNavigation.DONE);
    }
  }
}
