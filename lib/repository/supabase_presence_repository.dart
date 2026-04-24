import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/auth_util.dart';
import '../utils/log.dart';

class SupabasePresenceRepository {
  final SupabaseClient _client = Supabase.instance.client;
  RealtimeChannel? _presenceChannel;

  Future<void> updateUserPresence() async {
    try {
      await _client.from('users').update({
        'presence': true,
        'last_active': DateTime.now().toIso8601String(),
      }).eq('id', getUserId());

      _presenceChannel?.unsubscribe();
      _presenceChannel = _client.channel('presence-${getUserId()}');
      _presenceChannel!.subscribe((status, _) {
        if (status == RealtimeSubscribeStatus.closed) {
          _client.from('users').update({
            'presence': false,
            'last_active': DateTime.now().toIso8601String(),
          }).eq('id', getUserId());
        }
      });
    } catch (e) {
      Log.e('Error updating presence: $e');
    }
  }

  void dispose() {
    _presenceChannel?.unsubscribe();
  }
}
