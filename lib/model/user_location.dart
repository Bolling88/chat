class UserLocation {
  final String countryCode;
  final String countryName;
  final String city;
  final String postal;
  final String latitude;
  final String longitude;
  final double iPv4;
  final double state;

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
    return UserLocation(
      countryCode: json['country_code'] ?? '',
      countryName: json['country_name'] ?? '',
      city: json['city'] ?? '',
      postal: json['postal'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      iPv4: json['IPv4']?.toDouble() ?? 0.0,
      state: json['state']?.toDouble() ?? 0.0,
    );
  }
}
