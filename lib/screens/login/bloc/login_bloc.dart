import 'dart:convert';

import 'package:chat/repository/login_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../../model/chat_user.dart';
import '../../../model/facebook_data.dart';
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
      if (event is LoginFacebookClickedEvent) {
        yield LoginLoadingState();
        try {
          final accessToken = await loginWithFacebook();
          if (accessToken != null) {
            final userInfoJson =
                await _loginRepository.getFacebookUserInfo(accessToken.token);
            Map valueMap = json.decode(userInfoJson);
            final facebookData = FacebookData.fromJson(valueMap);

            final OAuthCredential credential =
                FacebookAuthProvider.credential(accessToken.token);
            // Once signed in, return the UserCredential
            final user =
                await FirebaseAuth.instance.signInWithCredential(credential);

            final chatUser = await _firestoreRepository.getUser();
            if (chatUser == null || chatUser.displayName.isEmpty) {
              await _firestoreRepository.setInitialUserData(
                  facebookData.email, user.user!.uid);
              final chatUser = await _firestoreRepository.getUser();
              if (chatUser != null) {
                yield await checkIfOnboardingIsDone(chatUser);
              } else {
                yield LoginErrorState();
              }
            } else {
              yield await checkIfOnboardingIsDone(chatUser);
            }
          } else {
            yield LoginErrorState();
          }
        } on Exception catch (e) {
          Log.e(e);
          yield LoginErrorState();
        }
      } else if (event is LoginGoogleClickedEvent) {
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
        final nonce = _loginRepository.createNonce(32);
        final appleCredentials =
            await _loginRepository.getAppleCredentials(nonce);
        final credentials =
            await _loginRepository.signInWithApple(appleCredentials, nonce);

        final chatUser = await _firestoreRepository.getUser();
        if (chatUser == null || chatUser.displayName.isEmpty) {
          await _firestoreRepository.setInitialUserData(
              credentials.user?.email ?? "", credentials.user?.uid ?? "");
          Log.d("User logged in!");
          if (chatUser != null) {
            yield await checkIfOnboardingIsDone(chatUser);
          } else {
            yield LoginErrorState();
          }
        } else {
          yield await checkIfOnboardingIsDone(chatUser);
        }
      } else if (event is LoginGuestClickedEvent) {
        final credentials = await FirebaseAuth.instance.signInAnonymously();
        await _firestoreRepository.setInitialUserData(
            "", credentials.user?.uid ?? "");
        yield await checkIfOnboardingIsDone(null);
      } else {
        yield LoginErrorState();
      }
    } on Exception catch (exception, stacktrace) {
      Log.e(exception, stackTrace: stacktrace);
      yield LoginErrorState();
    }
  }

  Future<AccessToken?> loginWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance
        .login(); // by the fault we request the email and the public profile
    if (result.status == LoginStatus.success) {
      // get the user data
      // by default we get the userId, email,name and picture
      final userData = await FacebookAuth.instance.getUserData();
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      Log.d(userData.toString());
      return result.accessToken!;
    }

    return null;
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
