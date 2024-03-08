import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

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

  Future<UserCredential?> signInWithApple() async {
    final appleProvider = AppleAuthProvider();
    if (kIsWeb) {
      return await FirebaseAuth.instance.signInWithPopup(appleProvider);
    } else {
      return await FirebaseAuth.instance.signInWithProvider(appleProvider);
    }
  }
}
