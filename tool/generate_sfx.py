"""
Generate short, license-free sound effects for KanjiPro quiz feedback.

Outputs:
  ui/common/assets/audio/correct.wav  — pleasant rising two-note chime (~300 ms)
  ui/common/assets/audio/wrong.wav    — short low descending buzz (~300 ms)

Usage:
  python3 tool/generate_sfx.py

Run from the kanjipro/ directory. No extra dependencies — stdlib only.
"""

import math
import os
import struct
import wave

SAMPLE_RATE = 22050  # Hz
NUM_CHANNELS = 1     # mono
SAMPLE_WIDTH = 2     # 16-bit


def _sine_wave(frequency: float, duration: float, amplitude: float = 0.6) -> bytes:
    """Return raw PCM bytes for a sine wave with a simple ADSR-like envelope."""
    num_samples = int(SAMPLE_RATE * duration)
    attack = int(num_samples * 0.05)
    release = int(num_samples * 0.30)
    frames = []
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        raw = math.sin(2.0 * math.pi * frequency * t)

        # Envelope
        if i < attack:
            env = i / attack
        elif i >= num_samples - release:
            env = (num_samples - i) / release
        else:
            env = 1.0

        sample = int(raw * amplitude * env * 32767)
        sample = max(-32768, min(32767, sample))
        frames.append(struct.pack('<h', sample))
    return b''.join(frames)


def _write_wav(path: str, pcm_frames: list[bytes]) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with wave.open(path, 'wb') as wav:
        wav.setnchannels(NUM_CHANNELS)
        wav.setsampwidth(SAMPLE_WIDTH)
        wav.setframerate(SAMPLE_RATE)
        for chunk in pcm_frames:
            wav.writeframes(chunk)


def generate_correct(out_path: str) -> None:
    """Rising two-note chime: E5 (659 Hz) → G#5 (831 Hz), each ~150 ms."""
    note1 = _sine_wave(659.0, 0.15, amplitude=0.55)
    note2 = _sine_wave(831.0, 0.15, amplitude=0.55)
    _write_wav(out_path, [note1, note2])
    print(f"  wrote {out_path}")


def generate_wrong(out_path: str) -> None:
    """Descending two-note dull tone: A3 (220 Hz) → F3 (175 Hz), each ~150 ms."""
    note1 = _sine_wave(220.0, 0.15, amplitude=0.50)
    note2 = _sine_wave(175.0, 0.15, amplitude=0.50)
    _write_wav(out_path, [note1, note2])
    print(f"  wrote {out_path}")


if __name__ == '__main__':
    base = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    audio_dir = os.path.join(base, 'ui', 'common', 'assets', 'audio')

    print("Generating SFX …")
    generate_correct(os.path.join(audio_dir, 'correct.wav'))
    generate_wrong(os.path.join(audio_dir, 'wrong.wav'))
    print("Done.")
