import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:math';
import 'dart:convert';

import '../utils/log.dart';

class LoginRepository {
  Future<String> getFacebookUserInfo(String token) async {
    final url = Uri.parse('https://graph.facebook.com/me?fields=name,email&access_token=$token');
    final graphResponse = await http.get(url);
    Log.d(graphResponse.body);
    return graphResponse.body;
  }

  Future<UserCredential?> signInWithGoogle() async {
    if(kIsWeb){
      return await _signInWithGoogleWeb();
    }else {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return null;
      }

      // Obtain the auth details from the request
      OAuthCredential credential = await getGoogleCredentials(googleUser);

      return await FirebaseAuth.instance.signInWithCredential(credential);
      // Once signed in, return the UserCredential
    }
  }

  Future<UserCredential> _signInWithGoogleWeb() async{
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.addScope('https://www.googleapis.com/auth/');
    googleProvider.setCustomParameters({
      'login_hint': 'user@example.com'
    });

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithPopup(googleProvider);
  }

  String createNonce(int length) {
    final random = Random();
    final charCodes = List<int>.generate(length, (_) {
      int codeUnit;

      switch (random.nextInt(3)) {
        case 0:
          codeUnit = random.nextInt(10) + 48;
          break;
        case 1:
          codeUnit = random.nextInt(26) + 65;
          break;
        case 2:
          codeUnit = random.nextInt(26) + 97;
          break;
        default: codeUnit = -1;
      }

      return codeUnit;
    });

    return String.fromCharCodes(charCodes);
  }

  Future<AuthorizationCredentialAppleID> getAppleCredentials(String nonce) async{
    return await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: sha256.convert(utf8.encode(nonce)).toString(),
    );
  }

  Future<void> reauthenticate() async{
    final GoogleSignInAccount? googleUser = GoogleSignIn().currentUser;
    if(googleUser != null) {
      Log.d('Signed in with google');
      // Obtain the auth details from the request
      OAuthCredential credential = await getGoogleCredentials(googleUser);
      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(
          credential);
    }
    //SignInWithApple.getCredentialState(scopes: scopes);
  }

  Future<UserCredential> signInWithApple(AuthorizationCredentialAppleID oauth, String nonce) async {
    final oauthCred = await _createAppleOAuthCred(oauth, nonce);
    return await FirebaseAuth.instance.signInWithCredential(oauthCred);
  }

  Future<OAuthCredential> _createAppleOAuthCred(AuthorizationCredentialAppleID nativeAppleCred, String nonce) async {

    return OAuthCredential(
      providerId: "apple.com",
      // MUST be "apple.com"
      signInMethod: "oauth",
      // MUST be "oauth"
      accessToken: nativeAppleCred.identityToken,
      // propagate Apple ID token to BOTH accessToken and idToken parameters
      idToken: nativeAppleCred.identityToken,
      rawNonce: nonce,
    );
  }
}

  Future<OAuthCredential> getGoogleCredentials(GoogleSignInAccount googleUser) async {
    final GoogleSignInAuthentication? googleAuth =
    await googleUser.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return credential;
  }
