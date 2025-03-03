import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

class AudioService with ChangeNotifier {
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

  /// PLAY AUDIO FUNCTION
  Future<void> playAudio() async {
    try {
      await _player.setSource(AssetSource("audios/moolmantra_audio.mp3"));
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.resume(); // Starts playing

      _isPlaying = true;
      notifyListeners();
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
