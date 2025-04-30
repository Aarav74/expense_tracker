import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  final AudioPlayer _player = AudioPlayer();
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      // Preload the sound
      await _player.setSource(AssetSource('sounds/coin.wav'));
      _isInitialized = true;
      debugPrint('SoundService initialized successfully');
    } catch (e) {
      debugPrint('SoundService initialization error: $e');
      _isInitialized = false;
    }
  }

  Future<void> playCoinSound() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _player.stop(); // Stop any existing playback
      await _player.play(AssetSource('sounds/coin.wav'));
      debugPrint('Playing coin sound');
    } catch (e) {
      debugPrint('Error playing sound: $e');
      // Try alternative method if direct play fails
      try {
        final bytes = await rootBundle.load('assets/sounds/coin.wav');
        await _player.play(BytesSource(bytes.buffer.asUint8List()));
      } catch (e) {
        debugPrint('Fallback play method failed: $e');
      }
    }
  }

  void dispose() {
    _player.dispose();
  }
}