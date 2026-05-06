import 'dart:async';

import 'package:kvitter_client/kvitter_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../utils/log.dart';

class ServerpodAuthRepository {
  final Client _client;
  late final GoogleAuthController _googleController;
  late final AppleAuthController _appleController;
  final _authStateController = StreamController<bool>.broadcast();
  final Completer<bool> _googleSignInCompleter = Completer<bool>();
  final Completer<bool> _appleSignInCompleter = Completer<bool>();

  ServerpodAuthRepository(this._client) {
    _googleController = GoogleAuthController(
      client: _client,
      onAuthenticated: () {
        _authStateController.add(true);
        if (!_googleSignInCompleter.isCompleted) {
          _googleSignInCompleter.complete(true);
        }
      },
      onError: (error) {
        if (!_googleSignInCompleter.isCompleted) {
          _googleSignInCompleter.complete(false);
        }
      },
    );

    _appleController = AppleAuthController(
      client: _client,
      onAuthenticated: () {
        _authStateController.add(true);
        if (!_appleSignInCompleter.isCompleted) {
          _appleSignInCompleter.complete(true);
        }
      },
      onError: (error) {
        if (!_appleSignInCompleter.isCompleted) {
          _appleSignInCompleter.complete(false);
        }
      },
    );
  }

  Future<bool> signInWithGoogle() async {
    try {
      await _googleController.signIn();
      return await _googleSignInCompleter.future;
    } catch (e, s) {
      Log.e(e, stackTrace: s);
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    try {
      await _appleController.signIn();
      return await _appleSignInCompleter.future;
    } catch (e, s) {
      Log.e(e, stackTrace: s);
      return false;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOutDevice();
    _authStateController.add(false);
  }

  bool get isSignedIn => _client.auth.isAuthenticated;

  String? get currentUserId => _client.auth.authInfo?.authUserId.toString();

  Stream<bool> get onAuthStateChange => _authStateController.stream;

  void dispose() {
    _googleController.dispose();
    _appleController.dispose();
    _authStateController.close();
  }
}
