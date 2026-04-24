import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/log.dart';

class SupabaseAuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final result = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.kvitter://login-callback/',
      );
      if (!result) return null;
      return null;
    } catch (e, s) {
      Log.e(e, stackTrace: s);
      return null;
    }
  }

  Future<AuthResponse?> signInWithApple() async {
    try {
      final result = await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.kvitter://login-callback/',
      );
      if (!result) return null;
      return null;
    } catch (e, s) {
      Log.e(e, stackTrace: s);
      return null;
    }
  }

  Future<AuthResponse?> signInAnonymously() async {
    try {
      return await _client.auth.signInAnonymously();
    } catch (e, s) {
      Log.e(e, stackTrace: s);
      return null;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> deleteAccount() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;
}
