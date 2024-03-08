class FacebookData {
  String name;
  Picture? picture;
  String email;
  String id;

  FacebookData(
      {required this.name,
      required this.picture,
      required this.email,
      required this.id});

  FacebookData.fromJson(Map<dynamic, dynamic> json)
      : name = json['name'] ?? "",
        picture =
            json['picture'] != null ? Picture.fromJson(json['picture']) : null,
        email = json['email'] ?? "",
        id = json['id'] ?? "";

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (picture != null) {
      data['picture'] = picture!.toJson();
    }
    data['email'] = email;
    data['id'] = id;
    return data;
  }
}

class Picture {
  Data? data;

  Picture({required this.data});

  Picture.fromJson(Map<String, dynamic> json)
      : data = json['data'] != null ? Data.fromJson(json['data']) : null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int height;
  String url;
  int width;

  Data({required this.height, required this.url, required this.width});

  Data.fromJson(Map<String, dynamic> json)
      : height = json['height'],
        url = json['url'],
        width = json['width'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['height'] = height;
    data['url'] = url;
    data['width'] = width;
    return data;
  }
}
