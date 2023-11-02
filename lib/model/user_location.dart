class UserLocation {
  final String countryCode;
  final String countryName;
  final String city;
  final String postal;
  final double latitude;
  final double longitude;
  final String iPv4;
  final String state;

  UserLocation({
    required this.countryCode,
    required this.countryName,
    required this.city,
    required this.postal,
    required this.latitude,
    required this.longitude,
    required this.iPv4,
    required this.state,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    json.removeWhere((key, value) => value == 'Not found');
    return UserLocation(
      countryCode: json['country_code'] ?? '',
      countryName: json['country_name'] ?? '',
      city: json['city'] ?? '',
      postal: json['postal'] ?? '',
      latitude: json['latitude'] != null && json['latitude'] is num
          ? json['latitude'].toDouble()
          : 0.0,
      longitude: json['longitude'] != null && json['longitude'] is num
          ? json['longitude'].toDouble()
          : 0.0,
      iPv4: json['IPv4'] ?? '',
      state: json['state'] ?? '',
    );
  }
}
