import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:moolmantra/services/shared_pref_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../resources/constants.dart';

class AudioService with ChangeNotifier {


  String selectedVoice = Constants.voice1;
  int? repeatCount;



  /// Initialize SharedPreferences from SharedPrefService
  Future<void> init() async {
    selectedVoice = await SharedPrefService.getSelectedVoice() ?? Constants.voice1;
    repeatCount = await SharedPrefService.getRepeatCount() == 0 ? null : await SharedPrefService.getRepeatCount();
  }

  /// Save selected voice
  Future<void> saveSelectedVoice(String voice) async {
    selectedVoice = voice;
    await SharedPrefService.saveSelectedVoice(voice);
  }



  // Private constructor
  AudioService._privateConstructor();

  // Singleton instance
  static final AudioService _instance = AudioService._privateConstructor();

  // Factory constructor to return the same instance
  factory AudioService() => _instance;

  // Single instance of AudioPlayer
  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = false;

  /// Getter for playing status
  bool get isPlaying => _isPlaying;


  /// PLAY AUDIO FUNCTION WITH REPEAT SUPPORT
  // Future<void> playAudio({String? voice}) async {
  //   try {
  //     await _player.setSource(AssetSource(voice ?? selectedVoice));
  //     saveSelectedVoice(voice ?? selectedVoice);
  //     notifyListeners();
  //     _isPlaying = true;
  //     notifyListeners();
  //
  //     debugPrint("Printing the repeat count ===========================================>$repeatCount");
  //
  //     if (repeatCount == null) {
  //       debugPrint("===========================================>Inside Infinite Loop");
  //       notifyListeners();
  //       await _player.setReleaseMode(ReleaseMode.loop);
  //       await _player.resume();
  //     } else {
  //       debugPrint("===========================================>Inside Finite Loop");
  //       notifyListeners();
  //       // 🔁 Play for a specific number of times
  //       for (int i = 0; i < repeatCount!; i++) {
  //         debugPrint("===========================================>Inside Finite Loop $i");
  //         await _player.setSource(AssetSource(voice ?? selectedVoice)); // Reload source
  //         await _player.resume(); // Start playing
  //         await _player.onPlayerComplete.first; // Wait for completion
  //       }
  //       debugPrint("===========================================> Outside For Loop");
  //
  //       stopAudio();
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     debugPrint("Error playing audio: $e");
  //   }
  // }
  Future<void> playAudio({String? voice}) async {
    try {
      await _player.setSource(AssetSource(voice ?? selectedVoice));
      saveSelectedVoice(voice ?? selectedVoice);

      _isPlaying = true;
      notifyListeners();

      debugPrint("Printing the repeat count: $repeatCount");

      if (repeatCount == null) {
        debugPrint("Inside Infinite Loop");
        await _player.setReleaseMode(ReleaseMode.loop);
        await _player.resume();
      } else {
        debugPrint("Inside Finite Loop");

        for (int i = 0; i < repeatCount!; i++) {
          debugPrint("Playing iteration: $i");

          await _player.setSource(AssetSource(voice ?? selectedVoice)); // Reload source
          await _player.setReleaseMode(ReleaseMode.release);
          await _player.resume(); // Start playing
          await _player.onPlayerComplete.first; // Wait for completion
          await _player.stop(); // Ensure it's fully stopped before next loop
        }

        debugPrint("Outside For Loop");

        _isPlaying = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }


  /// STOP AUDIO FUNCTION
  Future<void> stopAudio() async {
    await _player.stop();
    _isPlaying = false;
    notifyListeners();
  }

  /// PAUSE AUDIO FUNCTION
  Future<void> pauseAudio() async {
    await _player.pause();
    _isPlaying = false;
    notifyListeners();
  }

  /// TOGGLE AUDIO FUNCTION
  Future<void> toggleAudio() async {
    if (_isPlaying) {
      await pauseAudio();
    } else {
      await playAudio();
    }
  }

  /// RESTART AUDIO FUNCTION (Seek to Start)
  Future<void> restartAudio() async {
    await _player.seek(Duration.zero); // Reset audio position
    await _player.resume();
    _isPlaying = true;
    notifyListeners();
  }

  /// RELEASE RESOURCES (Call when not needed)
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
