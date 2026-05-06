import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class ModerationEndpoint extends Endpoint {
  Future<void> blockUser(Session session, String targetUserId) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.authUserIdentifier.equals(authId),
    );
    if (myUser == null) return;

    var target = await ChatUser.db.findById(
      session,
      UuidValue.fromString(targetUserId),
    );
    if (target == null) return;

    if (!target.blockedBy.contains(myUser.id.toString())) {
      target.blockedBy = [...target.blockedBy, myUser.id.toString()];
      await ChatUser.db.updateRow(session, target);
    }
  }

  Future<void> unblockUser(Session session, String targetUserId) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.authUserIdentifier.equals(authId),
    );
    if (myUser == null) return;

    var target = await ChatUser.db.findById(
      session,
      UuidValue.fromString(targetUserId),
    );
    if (target == null) return;

    target.blockedBy =
        target.blockedBy.where((id) => id != myUser.id.toString()).toList();
    await ChatUser.db.updateRow(session, target);
  }

  Future<void> reportMessage(
    Session session,
    String messageId,
    String messageText,
    DateTime messageCreated,
    String messageCreatedBy,
    int messageCreatedByGender,
    String messageCreatedByCountryCode,
    String messageCreatedByImageUrl,
    String messageCreatedByDisplayName,
  ) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.authUserIdentifier.equals(authId),
    );
    if (myUser == null) return;

    await Report.db.insertRow(
      session,
      Report(
        messageId: messageId,
        messageText: messageText,
        messageCreated: messageCreated,
        messageCreatedBy: messageCreatedBy,
        messageCreatedByGender: messageCreatedByGender,
        messageCreatedByCountryCode: messageCreatedByCountryCode,
        messageCreatedByImageUrl: messageCreatedByImageUrl,
        messageCreatedByDisplayName: messageCreatedByDisplayName,
        reportedBy: myUser.id.toString(),
        reportedAt: DateTime.now(),
      ),
    );
  }

  Future<void> reportInappropriateImage(
    Session session,
    String reportedUserId,
  ) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.authUserIdentifier.equals(authId),
    );
    if (myUser == null) return;

    var target = await ChatUser.db.findById(
      session,
      UuidValue.fromString(reportedUserId),
    );
    if (target == null) return;

    if (!target.imageReports.contains(myUser.id.toString())) {
      target.imageReports = [...target.imageReports, myUser.id.toString()];
    }
    target.approvedImage = 0;
    await ChatUser.db.updateRow(session, target);
  }

  Future<void> reportBot(Session session, String reportedUserId) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.authUserIdentifier.equals(authId),
    );
    if (myUser == null) return;

    var target = await ChatUser.db.findById(
      session,
      UuidValue.fromString(reportedUserId),
    );
    if (target == null) return;

    if (!target.botReports.contains(myUser.id.toString())) {
      target.botReports = [...target.botReports, myUser.id.toString()];
      await ChatUser.db.updateRow(session, target);
    }
  }

  Future<void> reportHatefulLanguage(
    Session session,
    String reportedUserId,
  ) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.authUserIdentifier.equals(authId),
    );
    if (myUser == null) return;

    var target = await ChatUser.db.findById(
      session,
      UuidValue.fromString(reportedUserId),
    );
    if (target == null) return;

    if (!target.languageReports.contains(myUser.id.toString())) {
      target.languageReports = [
        ...target.languageReports,
        myUser.id.toString(),
      ];
      await ChatUser.db.updateRow(session, target);
    }
  }

  Future<void> approveImage(Session session, String userId) async {
    var user = await ChatUser.db.findById(
      session,
      UuidValue.fromString(userId),
    );
    if (user == null) return;
    user.approvedImage = 2;
    user.imageReports = [];
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> rejectImage(Session session, String userId) async {
    var user = await ChatUser.db.findById(
      session,
      UuidValue.fromString(userId),
    );
    if (user == null) return;
    user.approvedImage = 1;
    await ChatUser.db.updateRow(session, user);
  }

  Future<List<ChatUser>> getUnapprovedImages(Session session) async {
    return await ChatUser.db.find(
      session,
      where: (t) => t.approvedImage.equals(0) & t.pictureData.notEquals(''),
    );
  }
}
