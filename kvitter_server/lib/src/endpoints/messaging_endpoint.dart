import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Provides presence (online users) and messaging infrastructure.
///
/// Presence is driven by [UserEndpoint.setActive] (sets [ChatUser.presence]
/// to `true`) and [UserEndpoint.logout] (sets it to `false`).  The Flutter
/// client polls [getOnlineUsers] on a periodic timer.  This polling-based
/// approach is the planned starting implementation and can be upgraded to a
/// WebSocket stream later using Serverpod 3.x's `Stream<T>` return-type
/// pattern.
class MessagingEndpoint extends Endpoint {
  /// Returns all users whose [ChatUser.presence] field is `true`.
  ///
  /// Callers can optionally filter by [countryCode] to retrieve only users
  /// in a specific country, or pass `null` / an empty string to get all
  /// online users.
  Future<List<ChatUser>> getOnlineUsers(
    Session session, {
    String? countryCode,
  }) async {
    if (countryCode != null && countryCode.isNotEmpty) {
      return await ChatUser.db.find(
        session,
        where: (t) =>
            t.presence.equals(true) & t.countryCode.equals(countryCode),
      );
    }
    return await ChatUser.db.find(
      session,
      where: (t) => t.presence.equals(true),
    );
  }

  /// Returns the total number of users currently online.
  Future<int> getOnlineUserCount(Session session) async {
    return await ChatUser.db.count(
      session,
      where: (t) => t.presence.equals(true),
    );
  }

  /// Marks users as offline if they have not been active within [staleMinutes]
  /// minutes.  Intended to be called from a scheduled [FutureCall] so that
  /// presence stays accurate even when a client disconnects without calling
  /// [UserEndpoint.logout].
  Future<void> cleanUpStalePresence(
    Session session, {
    int staleMinutes = 5,
  }) async {
    final cutoff = DateTime.now().subtract(Duration(minutes: staleMinutes));
    final staleUsers = await ChatUser.db.find(
      session,
      where: (t) => t.presence.equals(true) & (t.lastActive < cutoff),
    );
    for (final user in staleUsers) {
      user.presence = false;
      await ChatUser.db.updateRow(session, user);
    }
  }
}
