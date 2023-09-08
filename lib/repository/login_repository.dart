import 'dart:html';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:math';
import 'dart:convert';

class LoginRepository {

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      return await _signInWithGoogleWeb();
    } else {
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

  Future<OAuthCredential> getGoogleCredentials(
      GoogleSignInAccount googleUser) async {
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return credential;
  }

  Future<UserCredential> _signInWithGoogleWeb() async {
    GoogleAuthProvider googleProvider = GoogleAuthProvider();

    googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

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
        default:
          codeUnit = -1;
      }

      return codeUnit;
    });

    return String.fromCharCodes(charCodes);
  }

  Future<AuthorizationCredentialAppleID> getAppleCredentials(
      String nonce) async {
    return await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
        // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
        clientId:
        'com.xevenition.kvitter',
        redirectUri:
        // For web your redirect URI needs to be the host of the "current page",
        // while for Android you will be using the API server that redirects back into your app via a deep link
        kIsWeb
            ? Uri.parse('https://chat-60225.firebaseapp.com/__/auth/handler')
            : Uri.parse(
          'https://flutter-sign-in-with-apple-example.glitch.me/callbacks/sign_in_with_apple',
        ),
      ),
      nonce: sha256.convert(utf8.encode(nonce)).toString(),
    );
  }

  Future<UserCredential> signInWithApple(
      AuthorizationCredentialAppleID oauth, String nonce) async {
    final oauthCred = await _createAppleOAuthCred(oauth, nonce);
    return await FirebaseAuth.instance.signInWithCredential(oauthCred);
  }

  Future<OAuthCredential> _createAppleOAuthCred(
      AuthorizationCredentialAppleID nativeAppleCred, String nonce) async {
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
