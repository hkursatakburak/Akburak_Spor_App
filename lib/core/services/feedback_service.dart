import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Play a heavy haptic vibration and the gong sound
  Future<void> triggerRoundEnd() async {
    try {
      // Trigger native heavy impact vibration
      await HapticFeedback.heavyImpact();
      
      // Play the gong sound
      await _audioPlayer.play(AssetSource('audio/gong.mp3'));
    } catch (e) {
      print("FeedbackService Error: $e");
    }
  }
}
