class UserLocation {
  final String status;
  final String country;
  final String countryCode;
  final String region;
  final String regionName;
  final String city;
  final String zip;
  final double lat;
  final double lon;
  final String timezone;
  final String isp;
  final String org;
  final String as;
  final String query;

  UserLocation({
    required this.status,
    required this.country,
    required this.countryCode,
    required this.region,
    required this.regionName,
    required this.city,
    required this.zip,
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.isp,
    required this.org,
    required this.as,
    required this.query,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      status: json['status'],
      country: json['country'],
      countryCode: json['countryCode'],
      region: json['region'],
      regionName: json['regionName'],
      city: json['city'],
      zip: json['zip'],
      lat: json['lat'].toDouble(),
      lon: json['lon'].toDouble(),
      timezone: json['timezone'],
      isp: json['isp'],
      org: json['org'],
      as: json['as'],
      query: json['query'],
    );
  }
}
