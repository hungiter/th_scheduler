import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/user.dart';

class PreferencesManager {
  static Future<void> setVisitedStateToSP(bool visited) async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setBool("visited", visited);
  }

  static Future<bool> getVisitedStateToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    return s.getBool("visited") ?? false;
  }

  static Future<void> setUserDataToSP(Users user) async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("user_model", jsonEncode(user.toJson()));
    await s.setString("user_id", user.id);
  }

  static Future<Map<String, dynamic>> getUserDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("user_model") ?? '';

    if (data.isEmpty) {
      return {};
    }

    try {
      Map<String, dynamic> dataJson = jsonDecode(data);
      return dataJson;
    } catch (e) {
      return {};
    }
  }

  static Future<String> getUserId() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("user_id") ?? '';
    return data;
  }

  static Future<void> removePreferences(String prefName) async {
    SharedPreferences s = await SharedPreferences.getInstance();
    s.remove(prefName);
  }
}
