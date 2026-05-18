import 'package:audioplayers/audioplayers.dart';

import '../models/ringtone_profile.dart';
import '../utils/tone_generator.dart';

class AlarmPreviewService {
  AlarmPreviewService();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playPreview({
    required RingtoneProfile profile,
    required double volume,
  }) async {
    await _audioPlayer.stop();
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(volume.clamp(0, 1));
    await _audioPlayer.play(
      BytesSource(
        ToneGenerator.buildWavTone(
          frequencyHz: profile.previewFrequencyHz,
        ),
      ),
    );
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
