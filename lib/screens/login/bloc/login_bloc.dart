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
            if (chatUser == null || chatUser.name.isEmpty) {
              final searchArray = _getSearchArray(facebookData.name);
              await _firestoreRepository.setInitialUserData(facebookData.name,
                  facebookData.email, user.user!.uid, searchArray);
              final chatUser = await _firestoreRepository.getUser();
              if(chatUser != null) {
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
          if (chatUser == null || chatUser.name.isEmpty) {
            var fullName = credentials.user?.displayName ?? "";
            if (fullName.contains('@')) {
              fullName = "";
            }
            final searchArray = _getSearchArray(fullName);
            await _firestoreRepository.setInitialUserData(
                fullName,
                credentials.user?.email ?? "",
                credentials.user?.uid ?? "",
                searchArray);
            Log.d("User logged in!");
            final chatUser = await _firestoreRepository.getUser();
            if(chatUser != null) {
              yield await checkIfOnboardingIsDone(chatUser);
            } else {
              yield LoginErrorState();
            }
          } else {
            yield await checkIfOnboardingIsDone(chatUser);
          }
        }
      } else if (event is LoginAppleClickedEvent) {
        yield LoginLoadingState();
        final nonce = _loginRepository.createNonce(32);
        final appleCredentials = await _loginRepository.getAppleCredentials(nonce);
        final credentials = await _loginRepository.signInWithApple(appleCredentials, nonce);

        final user = await _firestoreRepository.getUser();
        if (user == null || user.name.isEmpty) {
          final fullName = '${appleCredentials.givenName} ${appleCredentials.familyName}';
          final searchArray = _getSearchArray(fullName);
          await _firestoreRepository.setInitialUserData(
              fullName,
              credentials.user?.email ?? "",
              credentials.user?.uid ?? "",
              searchArray);
          Log.d("User logged in!");
          final chatUser = await _firestoreRepository.getUser();
          if(chatUser != null) {
            yield await checkIfOnboardingIsDone(chatUser);
          } else {
            yield LoginErrorState();
          }
        } else {
          yield await checkIfOnboardingIsDone(user);
        }
      }else if(event is LoginGuestClickedEvent){
        UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
        final chatUser = await _firestoreRepository.getUser();
        if(chatUser != null) {
          yield await checkIfOnboardingIsDone(chatUser);
        } else {
          yield LoginErrorState();
        }
      }else{
        yield LoginErrorState();
      }
    } on Exception catch (exception, stacktrace) {
      Log.e(exception, stackTrace: stacktrace);
      yield LoginErrorState();
    }
  }

  List<String> _getSearchArray(String name) {
    if (name.isEmpty) return [];
    List<String> searchArray = [];
    for (int i = 1; i < name.length + 1; i++) {
      searchArray.add(name.substring(0, i).toLowerCase());
    }
    return searchArray;
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

  Future<LoginState> checkIfOnboardingIsDone(final ChatUser chatUser) async {
    if (chatUser.name.isEmpty || chatUser.name.contains('@')) {
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
