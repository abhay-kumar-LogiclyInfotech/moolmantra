import 'package:moolmantra/resources/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static const String _selectedVoiceKey = "selected_voice";
  static const String _repeatCountKey = "repeat_count";

  /// Save selected voice
  static Future<void> saveSelectedVoice(String voice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedVoiceKey, voice);
  }

  /// Get selected voice
  static Future<String?> getSelectedVoice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedVoiceKey) ?? Constants.voice1;
  }

  /// Save repeat count
  static Future<void> saveRepeatCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_repeatCountKey, count);
  }

  /// Get repeat count (default = 1 if not set)
  static Future<int?> getRepeatCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_repeatCountKey);
  }
}
