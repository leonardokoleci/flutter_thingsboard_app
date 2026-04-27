import 'dart:async';

import 'package:flutter/material.dart';
import 'package:thingsboard_app/locator.dart';
import 'package:thingsboard_app/utils/services/alarm_ringing_service.dart';

/// Full-screen alarm screen displayed whenever a new Thingsboard alarm
/// arrives.  The alarm keeps ringing until the user taps "Stop Alarm".
class AlarmRingingScreen extends StatefulWidget {
  const AlarmRingingScreen({super.key});

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen>
    with SingleTickerProviderStateMixin {
  late final AlarmRingingService _service;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    _service = getIt<AlarmRingingService>();

    // Pulsing ring animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Listen so the screen automatically pops when stop() is called
    // programmatically (e.g. from background).
    _sub = _service.ringingStream.listen((ringing) {
      if (!ringing && mounted) {
        Navigator.of(context, rootNavigator: true).maybePop();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _stopAlarm() async {
    await _service.stop();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final alarm = _service.pendingAlarm;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0A0A),
              Color(0xFF3D0000),
              Color(0xFF7B0000),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '⚠ ALARM',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'ThingsBoard',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white38,
                            letterSpacing: 1.5,
                          ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Pulsing icon ──────────────────────────────────────────
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, __) => Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.shade800.withOpacity(0.35),
                      border: Border.all(
                        color: Colors.redAccent.shade100,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade700.withOpacity(0.6),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      size: 72,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // ── Alarm info ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      alarm?.title ?? 'New Alarm',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if ((alarm?.originator ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        alarm!.originator,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _AlarmBadgeRow(alarm: alarm),
                  ],
                ),
              ),

              const Spacer(),

              // ── Stop button ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 48),
                child: GestureDetector(
                  onTap: _stopAlarm,
                  child: Container(
                    width: double.infinity,
                    height: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.shade600,
                          Colors.deepOrange.shade700,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade900.withOpacity(0.7),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.stop_circle_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'STOP ALARM',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlarmBadgeRow extends StatelessWidget {
  const _AlarmBadgeRow({this.alarm});
  // ignore: prefer_typing_uninitialized_variables
  final alarm;

  @override
  Widget build(BuildContext context) {
    final badges = <String>[];
    if ((alarm?.severity ?? '').isNotEmpty) badges.add(alarm!.severity);
    if ((alarm?.status ?? '').isNotEmpty) badges.add(alarm!.status);
    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      children: badges
          .map(
            (b) => Chip(
              label: Text(
                b.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              backgroundColor: Colors.white.withOpacity(0.15),
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
          )
          .toList(),
    );
  }
}
