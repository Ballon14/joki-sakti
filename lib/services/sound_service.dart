import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _isInitialized = true;
  }

  /// Play loud notification sound for new orders
  /// Uses online sound as fallback if local asset not available
  Future<void> playNewOrderSound() async {
    try {
      await init();
      await _audioPlayer.setVolume(1.0); // Max volume for alert

      // Play loud notification sound - multiple beeps
      // Using Windows notification sound URL as reliable source
      await _audioPlayer.play(
        UrlSource(
            'https://cdn.pixabay.com/audio/2024/02/19/audio_e4043eb3a1.mp3'),
      );

      // Wait and play again for more attention
      await Future.delayed(const Duration(milliseconds: 800));
      await _audioPlayer.play(
        UrlSource(
            'https://cdn.pixabay.com/audio/2024/02/19/audio_e4043eb3a1.mp3'),
      );
    } catch (e) {
      debugPrint('Error playing new order sound: $e');
    }
  }

  /// Play standard notification sound
  Future<void> playNotificationSound() async {
    try {
      await init();
      await _audioPlayer.setVolume(0.8);
      await _audioPlayer.play(
        UrlSource(
            'https://cdn.pixabay.com/audio/2022/03/15/audio_c8c005e3d4.mp3'),
      );
    } catch (e) {
      debugPrint('Error playing notification sound: $e');
    }
  }

  /// Stop any playing sound
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping sound: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
