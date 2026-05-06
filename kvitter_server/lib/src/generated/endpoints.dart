/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../auth/apple_idp_endpoint.dart' as _i2;
import '../auth/google_idp_endpoint.dart' as _i3;
import '../auth/jwt_refresh_endpoint.dart' as _i4;
import '../endpoints/chat_endpoint.dart' as _i5;
import '../endpoints/messaging_endpoint.dart' as _i6;
import '../endpoints/moderation_endpoint.dart' as _i7;
import '../endpoints/private_chat_endpoint.dart' as _i8;
import '../endpoints/storage_endpoint.dart' as _i9;
import '../endpoints/user_endpoint.dart' as _i10;
import 'package:kvitter_server/src/generated/chat_message.dart' as _i11;
import 'dart:typed_data' as _i12;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i13;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i14;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'appleIdp': _i2.AppleIdpEndpoint()
        ..initialize(
          server,
          'appleIdp',
          null,
        ),
      'googleIdp': _i3.GoogleIdpEndpoint()
        ..initialize(
          server,
          'googleIdp',
          null,
        ),
      'jwtRefresh': _i4.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'chat': _i5.ChatEndpoint()
        ..initialize(
          server,
          'chat',
          null,
        ),
      'messaging': _i6.MessagingEndpoint()
        ..initialize(
          server,
          'messaging',
          null,
        ),
      'moderation': _i7.ModerationEndpoint()
        ..initialize(
          server,
          'moderation',
          null,
        ),
      'privateChat': _i8.PrivateChatEndpoint()
        ..initialize(
          server,
          'privateChat',
          null,
        ),
      'storage': _i9.StorageEndpoint()
        ..initialize(
          server,
          'storage',
          null,
        ),
      'user': _i10.UserEndpoint()
        ..initialize(
          server,
          'user',
          null,
        ),
    };
    connectors['appleIdp'] = _i1.EndpointConnector(
      name: 'appleIdp',
      endpoint: endpoints['appleIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'identityToken': _i1.ParameterDescription(
              name: 'identityToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'authorizationCode': _i1.ParameterDescription(
              name: 'authorizationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'isNativeApplePlatformSignIn': _i1.ParameterDescription(
              name: 'isNativeApplePlatformSignIn',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'firstName': _i1.ParameterDescription(
              name: 'firstName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'lastName': _i1.ParameterDescription(
              name: 'lastName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['appleIdp'] as _i2.AppleIdpEndpoint).login(
                session,
                identityToken: params['identityToken'],
                authorizationCode: params['authorizationCode'],
                isNativeApplePlatformSignIn:
                    params['isNativeApplePlatformSignIn'],
                firstName: params['firstName'],
                lastName: params['lastName'],
              ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['appleIdp'] as _i2.AppleIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['googleIdp'] = _i1.EndpointConnector(
      name: 'googleIdp',
      endpoint: endpoints['googleIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'idToken': _i1.ParameterDescription(
              name: 'idToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'accessToken': _i1.ParameterDescription(
              name: 'accessToken',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['googleIdp'] as _i3.GoogleIdpEndpoint).login(
                    session,
                    idToken: params['idToken'],
                    accessToken: params['accessToken'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['googleIdp'] as _i3.GoogleIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i4.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['chat'] = _i1.EndpointConnector(
      name: 'chat',
      endpoint: endpoints['chat']!,
      methodConnectors: {
        'getChat': _i1.MethodConnector(
          name: 'getChat',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['chat'] as _i5.ChatEndpoint).getChat(
                session,
                params['chatId'],
              ),
        ),
        'getOpenChats': _i1.MethodConnector(
          name: 'getOpenChats',
          params: {
            'countryCode': _i1.ParameterDescription(
              name: 'countryCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'isDebug': _i1.ParameterDescription(
              name: 'isDebug',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['chat'] as _i5.ChatEndpoint).getOpenChats(
                session,
                params['countryCode'],
                params['isDebug'],
              ),
        ),
        'getInitialMessages': _i1.MethodConnector(
          name: 'getInitialMessages',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'isPrivate': _i1.ParameterDescription(
              name: 'isPrivate',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chat'] as _i5.ChatEndpoint).getInitialMessages(
                    session,
                    params['chatId'],
                    params['isPrivate'],
                  ),
        ),
        'getMoreMessages': _i1.MethodConnector(
          name: 'getMoreMessages',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'isPrivate': _i1.ParameterDescription(
              name: 'isPrivate',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'before': _i1.ParameterDescription(
              name: 'before',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chat'] as _i5.ChatEndpoint).getMoreMessages(
                    session,
                    params['chatId'],
                    params['isPrivate'],
                    params['before'],
                  ),
        ),
        'postMessage': _i1.MethodConnector(
          name: 'postMessage',
          params: {
            'message': _i1.ParameterDescription(
              name: 'message',
              type: _i1.getType<_i11.ChatMessage>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['chat'] as _i5.ChatEndpoint).postMessage(
                session,
                params['message'],
              ),
        ),
        'postFeedback': _i1.MethodConnector(
          name: 'postFeedback',
          params: {
            'feedback': _i1.ParameterDescription(
              name: 'feedback',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'createdByName': _i1.ParameterDescription(
              name: 'createdByName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'countryCode': _i1.ParameterDescription(
              name: 'countryCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'countryName': _i1.ParameterDescription(
              name: 'countryName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['chat'] as _i5.ChatEndpoint).postFeedback(
                session,
                params['feedback'],
                params['createdByName'],
                params['countryCode'],
                params['countryName'],
              ),
        ),
        'reduceCredits': _i1.MethodConnector(
          name: 'reduceCredits',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'amount': _i1.ParameterDescription(
              name: 'amount',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['chat'] as _i5.ChatEndpoint).reduceCredits(
                session,
                params['userId'],
                params['amount'],
              ),
        ),
        'increaseCredits': _i1.MethodConnector(
          name: 'increaseCredits',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'amount': _i1.ParameterDescription(
              name: 'amount',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['chat'] as _i5.ChatEndpoint).increaseCredits(
                    session,
                    params['userId'],
                    params['amount'],
                  ),
        ),
      },
    );
    connectors['messaging'] = _i1.EndpointConnector(
      name: 'messaging',
      endpoint: endpoints['messaging']!,
      methodConnectors: {
        'getOnlineUsers': _i1.MethodConnector(
          name: 'getOnlineUsers',
          params: {
            'countryCode': _i1.ParameterDescription(
              name: 'countryCode',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['messaging'] as _i6.MessagingEndpoint)
                  .getOnlineUsers(
                    session,
                    countryCode: params['countryCode'],
                  ),
        ),
        'getOnlineUserCount': _i1.MethodConnector(
          name: 'getOnlineUserCount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['messaging'] as _i6.MessagingEndpoint)
                  .getOnlineUserCount(session),
        ),
        'cleanUpStalePresence': _i1.MethodConnector(
          name: 'cleanUpStalePresence',
          params: {
            'staleMinutes': _i1.ParameterDescription(
              name: 'staleMinutes',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['messaging'] as _i6.MessagingEndpoint)
                  .cleanUpStalePresence(
                    session,
                    staleMinutes: params['staleMinutes'],
                  ),
        ),
      },
    );
    connectors['moderation'] = _i1.EndpointConnector(
      name: 'moderation',
      endpoint: endpoints['moderation']!,
      methodConnectors: {
        'blockUser': _i1.MethodConnector(
          name: 'blockUser',
          params: {
            'targetUserId': _i1.ParameterDescription(
              name: 'targetUserId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['moderation'] as _i7.ModerationEndpoint).blockUser(
                    session,
                    params['targetUserId'],
                  ),
        ),
        'unblockUser': _i1.MethodConnector(
          name: 'unblockUser',
          params: {
            'targetUserId': _i1.ParameterDescription(
              name: 'targetUserId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['moderation'] as _i7.ModerationEndpoint)
                  .unblockUser(
                    session,
                    params['targetUserId'],
                  ),
        ),
        'reportMessage': _i1.MethodConnector(
          name: 'reportMessage',
          params: {
            'messageId': _i1.ParameterDescription(
              name: 'messageId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'messageText': _i1.ParameterDescription(
              name: 'messageText',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'messageCreated': _i1.ParameterDescription(
              name: 'messageCreated',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'messageCreatedBy': _i1.ParameterDescription(
              name: 'messageCreatedBy',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'messageCreatedByGender': _i1.ParameterDescription(
              name: 'messageCreatedByGender',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'messageCreatedByCountryCode': _i1.ParameterDescription(
              name: 'messageCreatedByCountryCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'messageCreatedByImageUrl': _i1.ParameterDescription(
              name: 'messageCreatedByImageUrl',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'messageCreatedByDisplayName': _i1.ParameterDescription(
              name: 'messageCreatedByDisplayName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['moderation'] as _i7.ModerationEndpoint)
                  .reportMessage(
                    session,
                    params['messageId'],
                    params['messageText'],
                    params['messageCreated'],
                    params['messageCreatedBy'],
                    params['messageCreatedByGender'],
                    params['messageCreatedByCountryCode'],
                    params['messageCreatedByImageUrl'],
                    params['messageCreatedByDisplayName'],
                  ),
        ),
        'reportInappropriateImage': _i1.MethodConnector(
          name: 'reportInappropriateImage',
          params: {
            'reportedUserId': _i1.ParameterDescription(
              name: 'reportedUserId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['moderation'] as _i7.ModerationEndpoint)
                  .reportInappropriateImage(
                    session,
                    params['reportedUserId'],
                  ),
        ),
        'reportBot': _i1.MethodConnector(
          name: 'reportBot',
          params: {
            'reportedUserId': _i1.ParameterDescription(
              name: 'reportedUserId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['moderation'] as _i7.ModerationEndpoint).reportBot(
                    session,
                    params['reportedUserId'],
                  ),
        ),
        'reportHatefulLanguage': _i1.MethodConnector(
          name: 'reportHatefulLanguage',
          params: {
            'reportedUserId': _i1.ParameterDescription(
              name: 'reportedUserId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['moderation'] as _i7.ModerationEndpoint)
                  .reportHatefulLanguage(
                    session,
                    params['reportedUserId'],
                  ),
        ),
        'approveImage': _i1.MethodConnector(
          name: 'approveImage',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['moderation'] as _i7.ModerationEndpoint)
                  .approveImage(
                    session,
                    params['userId'],
                  ),
        ),
        'rejectImage': _i1.MethodConnector(
          name: 'rejectImage',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['moderation'] as _i7.ModerationEndpoint)
                  .rejectImage(
                    session,
                    params['userId'],
                  ),
        ),
        'getUnapprovedImages': _i1.MethodConnector(
          name: 'getUnapprovedImages',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['moderation'] as _i7.ModerationEndpoint)
                  .getUnapprovedImages(session),
        ),
      },
    );
    connectors['privateChat'] = _i1.EndpointConnector(
      name: 'privateChat',
      endpoint: endpoints['privateChat']!,
      methodConnectors: {
        'createPrivateChat': _i1.MethodConnector(
          name: 'createPrivateChat',
          params: {
            'otherUserId': _i1.ParameterDescription(
              name: 'otherUserId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'initialMessage': _i1.ParameterDescription(
              name: 'initialMessage',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'myName': _i1.ParameterDescription(
              name: 'myName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'myGender': _i1.ParameterDescription(
              name: 'myGender',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'myPictureData': _i1.ParameterDescription(
              name: 'myPictureData',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'otherName': _i1.ParameterDescription(
              name: 'otherName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'otherGender': _i1.ParameterDescription(
              name: 'otherGender',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'otherPictureData': _i1.ParameterDescription(
              name: 'otherPictureData',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['privateChat'] as _i8.PrivateChatEndpoint)
                  .createPrivateChat(
                    session,
                    params['otherUserId'],
                    params['initialMessage'],
                    params['myName'],
                    params['myGender'],
                    params['myPictureData'],
                    params['otherName'],
                    params['otherGender'],
                    params['otherPictureData'],
                  ),
        ),
        'isPrivateChatAvailable': _i1.MethodConnector(
          name: 'isPrivateChatAvailable',
          params: {
            'otherUserId': _i1.ParameterDescription(
              name: 'otherUserId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['privateChat'] as _i8.PrivateChatEndpoint)
                  .isPrivateChatAvailable(
                    session,
                    params['otherUserId'],
                  ),
        ),
        'leavePrivateChat': _i1.MethodConnector(
          name: 'leavePrivateChat',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['privateChat'] as _i8.PrivateChatEndpoint)
                  .leavePrivateChat(
                    session,
                    params['chatId'],
                  ),
        ),
        'setLastMessageRead': _i1.MethodConnector(
          name: 'setLastMessageRead',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['privateChat'] as _i8.PrivateChatEndpoint)
                  .setLastMessageRead(
                    session,
                    params['chatId'],
                  ),
        ),
        'leaveAllPrivateChats': _i1.MethodConnector(
          name: 'leaveAllPrivateChats',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['privateChat'] as _i8.PrivateChatEndpoint)
                  .leaveAllPrivateChats(session),
        ),
        'getPrivateChats': _i1.MethodConnector(
          name: 'getPrivateChats',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['privateChat'] as _i8.PrivateChatEndpoint)
                  .getPrivateChats(session),
        ),
        'getPrivateChatWithUser': _i1.MethodConnector(
          name: 'getPrivateChatWithUser',
          params: {
            'otherUserId': _i1.ParameterDescription(
              name: 'otherUserId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['privateChat'] as _i8.PrivateChatEndpoint)
                  .getPrivateChatWithUser(
                    session,
                    params['otherUserId'],
                  ),
        ),
      },
    );
    connectors['storage'] = _i1.EndpointConnector(
      name: 'storage',
      endpoint: endpoints['storage']!,
      methodConnectors: {
        'uploadAvatar': _i1.MethodConnector(
          name: 'uploadAvatar',
          params: {
            'imageData': _i1.ParameterDescription(
              name: 'imageData',
              type: _i1.getType<_i12.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['storage'] as _i9.StorageEndpoint).uploadAvatar(
                    session,
                    params['imageData'],
                  ),
        ),
        'uploadChatImage': _i1.MethodConnector(
          name: 'uploadChatImage',
          params: {
            'imageData': _i1.ParameterDescription(
              name: 'imageData',
              type: _i1.getType<_i12.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['storage'] as _i9.StorageEndpoint).uploadChatImage(
                    session,
                    params['imageData'],
                  ),
        ),
        'deleteAvatar': _i1.MethodConnector(
          name: 'deleteAvatar',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['storage'] as _i9.StorageEndpoint)
                  .deleteAvatar(session),
        ),
        'deleteUserAvatar': _i1.MethodConnector(
          name: 'deleteUserAvatar',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['storage'] as _i9.StorageEndpoint)
                  .deleteUserAvatar(
                    session,
                    params['userId'],
                  ),
        ),
      },
    );
    connectors['user'] = _i1.EndpointConnector(
      name: 'user',
      endpoint: endpoints['user']!,
      methodConnectors: {
        'getUser': _i1.MethodConnector(
          name: 'getUser',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i10.UserEndpoint).getUser(
                session,
                userId: params['userId'],
              ),
        ),
        'ensureUserExists': _i1.MethodConnector(
          name: 'ensureUserExists',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i10.UserEndpoint).ensureUserExists(
                    session,
                    params['email'],
                  ),
        ),
        'updateGender': _i1.MethodConnector(
          name: 'updateGender',
          params: {
            'gender': _i1.ParameterDescription(
              name: 'gender',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i10.UserEndpoint).updateGender(
                session,
                params['gender'],
              ),
        ),
        'updateBirthday': _i1.MethodConnector(
          name: 'updateBirthday',
          params: {
            'birthDate': _i1.ParameterDescription(
              name: 'birthDate',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i10.UserEndpoint).updateBirthday(
                    session,
                    params['birthDate'],
                  ),
        ),
        'updateShowAge': _i1.MethodConnector(
          name: 'updateShowAge',
          params: {
            'showAge': _i1.ParameterDescription(
              name: 'showAge',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i10.UserEndpoint).updateShowAge(
                session,
                params['showAge'],
              ),
        ),
        'updateDisplayName': _i1.MethodConnector(
          name: 'updateDisplayName',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'searchArray': _i1.ParameterDescription(
              name: 'searchArray',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i10.UserEndpoint).updateDisplayName(
                    session,
                    params['name'],
                    params['searchArray'],
                  ),
        ),
        'updateProfileImage': _i1.MethodConnector(
          name: 'updateProfileImage',
          params: {
            'imageUrl': _i1.ParameterDescription(
              name: 'imageUrl',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'hasNudity': _i1.ParameterDescription(
              name: 'hasNudity',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i10.UserEndpoint).updateProfileImage(
                    session,
                    params['imageUrl'],
                    params['hasNudity'],
                  ),
        ),
        'isNameAvailable': _i1.MethodConnector(
          name: 'isNameAvailable',
          params: {
            'displayName': _i1.ParameterDescription(
              name: 'displayName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i10.UserEndpoint).isNameAvailable(
                    session,
                    params['displayName'],
                  ),
        ),
        'updateLocation': _i1.MethodConnector(
          name: 'updateLocation',
          params: {
            'city': _i1.ParameterDescription(
              name: 'city',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'countryCode': _i1.ParameterDescription(
              name: 'countryCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'country': _i1.ParameterDescription(
              name: 'country',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'regionName': _i1.ParameterDescription(
              name: 'regionName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i10.UserEndpoint).updateLocation(
                    session,
                    params['city'],
                    params['countryCode'],
                    params['country'],
                    params['regionName'],
                  ),
        ),
        'setActive': _i1.MethodConnector(
          name: 'setActive',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i10.UserEndpoint).setActive(session),
        ),
        'setCurrentChatRoom': _i1.MethodConnector(
          name: 'setCurrentChatRoom',
          params: {
            'chatId': _i1.ParameterDescription(
              name: 'chatId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i10.UserEndpoint).setCurrentChatRoom(
                    session,
                    params['chatId'],
                  ),
        ),
        'saveFcmToken': _i1.MethodConnector(
          name: 'saveFcmToken',
          params: {
            'token': _i1.ParameterDescription(
              name: 'token',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i10.UserEndpoint).saveFcmToken(
                session,
                params['token'],
              ),
        ),
        'logout': _i1.MethodConnector(
          name: 'logout',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i10.UserEndpoint).logout(session),
        ),
        'deleteAccount': _i1.MethodConnector(
          name: 'deleteAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i10.UserEndpoint).deleteAccount(
                session,
              ),
        ),
        'setPremium': _i1.MethodConnector(
          name: 'setPremium',
          params: {
            'isPremium': _i1.ParameterDescription(
              name: 'isPremium',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i10.UserEndpoint).setPremium(
                session,
                params['isPremium'],
              ),
        ),
        'deletePhoto': _i1.MethodConnector(
          name: 'deletePhoto',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i10.UserEndpoint).deletePhoto(session),
        ),
        'updateImageNotReviewedStatus': _i1.MethodConnector(
          name: 'updateImageNotReviewedStatus',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i10.UserEndpoint)
                  .updateImageNotReviewedStatus(session),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i13.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i14.Endpoints()
      ..initializeEndpoints(server);
  }
}
