library digihttp;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract class Serializable<T> {
  T fromJson(Map json);
  Map<String, dynamic> toJson();
  T clone();
}

class ResponseUpdateData {
  int affectedRows;

  ResponseUpdateData({this.affectedRows});

  ResponseUpdateData.fromJson(Map json) : affectedRows = json['affected_rows'];
}

class ResponseInsertData {
  int id;

  ResponseInsertData({this.id});

  ResponseInsertData.fromJson(Map json) : id = json['id'];
}

class Http {
  static String _api;
  static set api(String a) => _api = a;

  Future<T> getSingle<T>(String endpoint, Serializable<T> s) async {
    http.Response response = await http
        .get('$_api$endpoint', headers: {'Authorization': await _getToken()});
    return s.fromJson(json.decode(response.body)['data']);
  }

  Future<List<T>> getAll<T>(String endpoint, Serializable<T> s) async {
    http.Response response = await http
        .get('$_api$endpoint', headers: {'Authorization': await _getToken()});
    dynamic j = json.decode(response.body)['data'];
    return (j as List).map((i) => s.fromJson(i)).toList();
  }

  Future<ResponseInsertData> post(String endpoint, Map s) async {
    http.Response response = await http.post('$_api$endpoint',
        headers: {
          'Authorization': await _getToken(),
          'Content-Type': 'application/json'
        },
        body: json.encode(s));
    return ResponseInsertData.fromJson(json.decode(response.body)['data']);
  }

  Future<ResponseUpdateData> put(String endpoint, Map s) async {
    http.Response response = await http.put('$_api$endpoint',
        headers: {
          'Authorization': await _getToken(),
          'Content-Type': 'application/json'
        },
        body: json.encode(s));
    return ResponseUpdateData.fromJson(json.decode(response.body)['data']);
  }

  Future<ResponseUpdateData> delete(String endpoint) async {
    http.Response response = await http.delete('$_api$endpoint', headers: {
      'Authorization': await _getToken(),
    });
    return ResponseUpdateData.fromJson(json.decode(response.body)['data']);
  }

  Future<String> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
