import 'package:kvitter_client/kvitter_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

late Client serverpodClient;

String getUserId() => serverpodClient.auth.authInfo!.authUserId.toString();
