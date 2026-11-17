// Synthesizes the app's sound cues (original audio, no samples).
// Regenerate: dart run tool/gen_sounds.dart assets/sounds
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const rate = 44100;

/// A struck bell/gong partial: quick attack, exponential decay.
double partial(double t, double freq, double amp, double decay, {double attack = 0.008}) {
  if (t < 0) return 0;
  final env = (t < attack ? t / attack : 1.0) * exp(-t / decay);
  return amp * env * sin(2 * pi * freq * t);
}

/// Low, soft gong: inharmonic partials with a slow bloom and a gentle
/// shimmer (beating between two close partials). "Close your eyes."
double night(double t) {
  const f = 98.0; // G2
  double s = 0;
  // Two strikes, the second lower and softer: a falling "dong… dong".
  for (final (start, base, level) in [(0.0, f, 1.0), (1.1, f * 0.84, 0.75)]) {
    final u = t - start;
    s +=
        level *
        (partial(u, base, 0.55, 1.6, attack: 0.06) +
            partial(u, base * 2.0, 0.25, 1.1, attack: 0.05) +
            partial(u, base * 2.01, 0.18, 1.1, attack: 0.05) + // shimmer
            partial(u, base * 2.76, 0.12, 0.7, attack: 0.04) +
            partial(u, base * 5.4, 0.04, 0.35, attack: 0.03));
  }
  return s;
}

/// Bright rising bell arpeggio, C major (C5 E5 G5 C6). "Wake up."
double morning(double t) {
  const notes = [523.25, 659.25, 783.99, 1046.50];
  double s = 0;
  for (final (i, f) in notes.indexed) {
    final u = t - i * 0.16;
    final last = i == notes.length - 1;
    final d = last ? 1.4 : 0.9;
    s +=
        partial(u, f, 0.45, d) +
        partial(u, f * 2.0, 0.16, d * 0.6) +
        partial(u, f * 3.0, 0.06, d * 0.35) +
        partial(u, f * 4.2, 0.03, d * 0.2); // bell "ting"
  }
  return s;
}

void write(String path, double Function(double) fn, double seconds) {
  final n = (seconds * rate).round();
  final samples = List<double>.generate(n, (i) => fn(i / rate));
  // Normalize to -3 dBFS peak and fade out the last 150 ms (no click).
  final peak = samples.fold(0.0, (m, v) => max(m, v.abs()));
  final gain = pow(10, -3 / 20) / peak;
  final fade = (0.15 * rate).round();
  final pcm = Int16List(n);
  for (var i = 0; i < n; i++) {
    final tail = i > n - fade ? (n - i) / fade : 1.0;
    pcm[i] = (samples[i] * gain * tail * 32767).round().clamp(-32768, 32767);
  }
  final data = pcm.buffer.asUint8List();
  final h = ByteData(44)
    ..setUint32(0, 0x52494646) // RIFF
    ..setUint32(4, 36 + data.length, Endian.little)
    ..setUint32(8, 0x57415645) // WAVE
    ..setUint32(12, 0x666d7420) // fmt
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little) // PCM
    ..setUint16(22, 1, Endian.little) // mono
    ..setUint32(24, rate, Endian.little)
    ..setUint32(28, rate * 2, Endian.little)
    ..setUint16(32, 2, Endian.little)
    ..setUint16(34, 16, Endian.little)
    ..setUint32(36, 0x64617461) // data
    ..setUint32(40, data.length, Endian.little);
  File(path).writeAsBytesSync([...h.buffer.asUint8List(), ...data]);
  final rms = sqrt(pcm.fold(0.0, (a, v) => a + v * v) / n) / 32767;
  stdout.writeln(
    '$path: ${seconds}s, peak -3.0 dBFS, rms ${(20 * log(rms) / ln10).toStringAsFixed(1)} dBFS, '
    'last sample ${pcm.last}, ${File(path).lengthSync() ~/ 1024} KB',
  );
}

void main(List<String> args) {
  write('${args[0]}/night.wav', night, 3.6);
  write('${args[0]}/morning.wav', morning, 2.4);
}
