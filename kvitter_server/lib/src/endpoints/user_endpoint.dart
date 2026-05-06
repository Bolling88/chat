import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class UserEndpoint extends Endpoint {
  Future<ChatUser?> getUser(Session session, {String? userId}) async {
    if (userId != null) {
      return await ChatUser.db.findById(session, UuidValue.fromString(userId));
    }
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return null;
    return await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.authUserIdentifier.equals(authId),
    );
  }

  Future<ChatUser> ensureUserExists(Session session, String email) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) throw Exception('Not authenticated');

    var existing = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.authUserIdentifier.equals(authId),
    );
    if (existing != null) return existing;

    var user = ChatUser(
      authUserIdentifier: authId,
      email: email,
      displayName: '',
      gender: -1,
      showAge: true,
      pictureData: '',
      approvedImage: 0,
      city: '',
      countryCode: '',
      country: '',
      regionName: '',
      presence: false,
      lastActive: DateTime.now(),
      fcmToken: '',
      blockedBy: [],
      imageReports: [],
      botReports: [],
      languageReports: [],
      kvitterCredits: 0,
      isPremiumUser: false,
      onboardingCompleted: false,
      isAdmin: false,
      searchArray: [],
    );
    return await ChatUser.db.insertRow(session, user);
  }

  Future<void> updateGender(Session session, int gender) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.gender = gender;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> updateBirthday(Session session, DateTime birthDate) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.birthDate = birthDate;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> updateShowAge(Session session, bool showAge) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.showAge = showAge;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> updateDisplayName(
    Session session,
    String name,
    List<String> searchArray,
  ) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.displayName = name;
    user.searchArray = searchArray;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> updateProfileImage(
    Session session,
    String imageUrl,
    bool hasNudity,
  ) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.pictureData = imageUrl;
    user.approvedImage = hasNudity ? 0 : 2;
    user.imageReports = [];
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<bool> isNameAvailable(Session session, String displayName) async {
    var existing = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.displayName.equals(displayName),
    );
    return existing == null;
  }

  Future<void> updateLocation(
    Session session,
    String city,
    String countryCode,
    String country,
    String regionName,
  ) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.city = city;
    user.countryCode = countryCode;
    user.country = country;
    user.regionName = regionName;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> setActive(Session session) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.presence = true;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> setCurrentChatRoom(Session session, String chatId) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.currentRoomChatId =
        chatId.isEmpty ? null : UuidValue.fromString(chatId);
    user.presence = true;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> saveFcmToken(Session session, String token) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.fcmToken = token;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> logout(Session session) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.presence = false;
    user.fcmToken = '';
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> deleteAccount(Session session) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    await ChatUser.db.deleteRow(session, user);
  }

  Future<void> setPremium(Session session, bool isPremium) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.isPremiumUser = isPremium;
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> deletePhoto(Session session) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.pictureData = '';
    user.approvedImage = 0;
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> updateImageNotReviewedStatus(Session session) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.approvedImage = 0;
    await ChatUser.db.updateRow(session, user);
  }

  Future<ChatUser?> _getAuthenticatedUser(Session session) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return null;
    return await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.authUserIdentifier.equals(authId),
    );
  }
}
