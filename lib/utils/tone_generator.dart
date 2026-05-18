import 'dart:math' as math;
import 'dart:typed_data';

class ToneGenerator {
  const ToneGenerator._();

  static Uint8List buildWavTone({
    required int frequencyHz,
    Duration duration = const Duration(milliseconds: 1200),
    double amplitude = 0.32,
    int sampleRate = 44100,
  }) {
    final int totalSamples =
        (sampleRate * duration.inMilliseconds / 1000).round();
    final ByteData data = ByteData(44 + (totalSamples * 2));
    final int fileLength = 36 + (totalSamples * 2);

    void writeString(int offset, String value) {
      for (int index = 0; index < value.length; index++) {
        data.setUint8(offset + index, value.codeUnitAt(index));
      }
    }

    writeString(0, 'RIFF');
    data.setUint32(4, fileLength, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, 1, Endian.little);
    data.setUint32(24, sampleRate, Endian.little);
    data.setUint32(28, sampleRate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    writeString(36, 'data');
    data.setUint32(40, totalSamples * 2, Endian.little);

    for (int sampleIndex = 0; sampleIndex < totalSamples; sampleIndex++) {
      final double sample = math.sin(
        2 * math.pi * frequencyHz * sampleIndex / sampleRate,
      );
      final int pcmValue = (sample * 32767 * amplitude).round();
      data.setInt16(44 + (sampleIndex * 2), pcmValue, Endian.little);
    }

    return data.buffer.asUint8List();
  }
}
