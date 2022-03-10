import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../utils/save_file.dart';

class DataRepository {
  final SaveFile _saveFile;

  DataRepository(this._saveFile);
}
