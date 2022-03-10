import 'package:shared_preferences/shared_preferences.dart';

class SaveFile {
  final SharedPreferences _prefs;

  SaveFile(this._prefs);

  // Future<bool> saveToken(String token) async{
  //   return await _prefs.setString(_tokenKey, token);
  // }
  //
  // String getToken() {
  //   return _prefs.getString(_tokenKey) ?? "";
  // }
}
