import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/user_location.dart';
import '../utils/log.dart';
import 'package:universal_io/io.dart';

class Network {
  final String url;

  Network(this.url);

  Future<String> getData() async {
    //Ad no headers, we get cors preflight issue!
    //https://stackoverflow.com/a/32501365/1983904
    http.Response response = await http.get(Uri.parse(url));
    Log.d('Response status get location: ${response.statusCode}');
    Log.d('Response body get location: ${response.body}');
    if (response.statusCode == 200) {
      return (response.body);
    } else {
      String platform = kIsWeb ? 'Web' : (Platform.isAndroid ? 'Android' : 'iOS');
      Log.e('Error getting location: ${response.statusCode}, Platform: $platform');
      return 'No Data';
    }
  }
}

Future<UserLocation> getUserLocation() async {
  Network n = Network("https://geolocation-db.com/json/");
  Log.d('Get location from: ${n.url}');
  final locationSTR = (await n.getData());
  Log.d('Location: $locationSTR');
  final userLocation = UserLocation.fromJson(jsonDecode(locationSTR));
  Log.d('User location: $userLocation');
  return userLocation;
}
