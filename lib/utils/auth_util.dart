import 'package:kvitter_client/kvitter_client.dart';

late Client serverpodClient;

String getUserId() => serverpodClient.auth.authInfo!.authUserId.toString();
