import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/user_location.dart';
import '../utils/analytics.dart';
import '../utils/log.dart';
import 'package:universal_io/io.dart';

class Network {

  Network();

  Future<String> _getData(String url) async {
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

const String mainUrl = 'https://geolocation-db.com/json/"';
const String fallbackUrl = 'http://ip-api.com/json';

Future<UserLocation?> getUserLocation() async {
  try {
    Network n = Network();
    Log.d('Get location from: $mainUrl');
    final locationSTR = (await n._getData(mainUrl));
    Log.d('Location: $locationSTR');
    final userLocation = UserLocation.fromJson(jsonDecode(locationSTR));
    Log.d('User location: $userLocation');
    if(userLocation.countryCode.isEmpty){
      logEvent('failed_get_country_code');
      Log.e('Failed to get country code from Geo API');

      return await tryWithFallback(n);
    }
    return userLocation;
  } catch (e) {
    Log.e('Error getting location from GEO API: $e');
    logEvent('failed_get_location');
    Network n = Network();
    return await tryWithFallback(n);
  }
}

Future<UserLocation?> tryWithFallback(Network n) async {
  try {
    Log.d('Get location from: $fallbackUrl');
    final locationSTR = (await n._getData(fallbackUrl));
    Log.d('Location: $locationSTR');
    final userLocation = UserLocation.fromFallbackJson(jsonDecode(locationSTR));
    Log.d('User location: $userLocation');
    if(userLocation.countryCode.isEmpty){
      logEvent('failed_get_country_code');
      Log.e('Failed to get country code from IP API');
    }
    return userLocation;
  }catch (e) {
    Log.e('Error getting location from IP API: $e');
    logEvent('failed_get_location');
    return null;
  }
}
