import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Service that manages the continuously-ringing alarm when a new
/// Thingsboard alarm notification is received.
///
/// Call [ring] to start the alarm and [stop] to silence it.
/// The screen is kept awake while the alarm is ringing.
class AlarmRingingService {
  AlarmRingingService();

  final _player = AudioPlayer();
  bool _isRinging = false;

  // Stream that other widgets can listen to in order to react when
  // the ringing state changes.
  final _stateController = StreamController<bool>.broadcast();
  Stream<bool> get ringingStream => _stateController.stream;

  bool get isRinging => _isRinging;

  /// Starts the looping alarm sound and keeps the screen awake.
  Future<void> ring({
    String? alarmTitle,
    String? alarmOriginator,
    String? alarmSeverity,
    String? alarmStatus,
  }) async {
    if (_isRinging) return; // Already ringing – don't stack.

    _isRinging = true;
    _stateController.add(true);

    try {
      await WakelockPlus.enable();
    } catch (_) {}

    // Use the built-in AudioPlayers notification / alarm audio source.
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(1.0);

    // Play the system alarm sound included in audioplayers' assets.
    // This is a bundled alarm ringtone that works on Android & iOS.
    await _player.play(AssetSource('audio/alarm.mp3'));

    // Store metadata so the ringing screen can display it.
    _pendingAlarm = _PendingAlarm(
      title: alarmTitle ?? 'New Alarm',
      originator: alarmOriginator ?? '',
      severity: alarmSeverity ?? '',
      status: alarmStatus ?? '',
    );
  }

  /// Stops the alarm sound and releases the wake-lock.
  Future<void> stop() async {
    if (!_isRinging) return;

    _isRinging = false;
    _pendingAlarm = null;
    _stateController.add(false);

    await _player.stop();
    try {
      await WakelockPlus.disable();
    } catch (_) {}
  }

  _PendingAlarm? _pendingAlarm;
  _PendingAlarm? get pendingAlarm => _pendingAlarm;

  void dispose() {
    _player.dispose();
    _stateController.close();
  }
}

class _PendingAlarm {
  const _PendingAlarm({
    required this.title,
    required this.originator,
    required this.severity,
    required this.status,
  });

  final String title;
  final String originator;
  final String severity;
  final String status;
}
