import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPersistence {
  static const String _keyName = 'chat_user_name';
  static const String _keyPhone = 'chat_user_phone';
  static const String _keyStep = 'chat_step';
  static const String _keyMessages = 'chat_messages';

  static Future<void> saveUserData({
    required String name,
    required String phone,
    int step = 2,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyPhone, phone);
    await prefs.setInt(_keyStep, step);
  }

  static Future<Map<String, dynamic>> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName) ?? '',
      'phone': prefs.getString(_keyPhone) ?? '',
      'step': prefs.getInt(_keyStep) ?? 0,
    };
  }

  static Future<void> saveMessages(List<Map<String, dynamic>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(messages);
    await prefs.setString(_keyMessages, encoded);
  }

  static Future<List<Map<String, dynamic>>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_keyMessages);
    if (encoded == null) return [];
    try {
      final decoded = jsonDecode(encoded) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyStep);
    await prefs.remove(_keyMessages);
  }
}
