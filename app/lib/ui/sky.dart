import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

enum SkyPhase { night, dawn, day }

/// The sky behind the game screens: the moon's blue glow at night, the sun
/// rising over the horizon at dawn (Morning), and a warm glow by day.
///
/// Changing [phase] moves the bodies with `Motion.phaseChange`: the moon
/// sets toward the start edge while the sun rises: together with the
/// AnimatedTheme color lerp this is the night → morning transition.
class PhaseSky extends StatelessWidget {
  const PhaseSky({super.key, required this.phase});

  final SkyPhase phase;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final d = still ? Duration.zero : Motion.phaseChange;
    const curve = Motion.ease;
    final night = phase == SkyPhase.night;
    final dawn = phase == SkyPhase.dawn;
    final day = phase == SkyPhase.day;
    final sunCore = MafiaColors.day.primaryCta;
    final sunHalo = Color.lerp(MafiaColors.day.bomb, sunCore, 0.35)!;

    Widget glow(Color color, double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          stops: const [0, 0.7],
        ),
      ),
    );

    return IgnorePointer(
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Moon glow: top start at night, sets down and away by morning.
          AnimatedPositionedDirectional(
            duration: d,
            curve: curve,
            top: night ? -160 : 40,
            start: night ? -100 : -300,
            child: AnimatedOpacity(
              duration: d,
              curve: curve,
              opacity: night ? 1 : 0,
              child: glow(MafiaColors.night.glow, 420),
            ),
          ),
          // Day glow: top end while the town debates.
          AnimatedPositionedDirectional(
            duration: d,
            curve: curve,
            top: day ? -180 : -60,
            end: -140,
            child: AnimatedOpacity(
              duration: d,
              curve: curve,
              opacity: day ? 1 : 0,
              child: glow(MafiaColors.day.glow, 420),
            ),
          ),
          // The sun rising behind the horizon line (Morning header).
          PositionedDirectional(
            top: 0,
            start: 0,
            end: 0,
            height: 220,
            child: ClipRect(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  AnimatedPositioned(
                    duration: d,
                    curve: curve,
                    top: dawn ? 200 - 130 : 220,
                    width: 260,
                    height: 260,
                    child: AnimatedOpacity(
                      duration: d,
                      curve: curve,
                      opacity: dawn ? 1 : 0,
                      child: _Sun(core: sunCore, halo: sunHalo),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sun extends StatelessWidget {
  const _Sun({required this.core, required this.halo});

  final Color core, halo;

  @override
  Widget build(BuildContext context) {
    Widget disc(double r, Color c) => Container(
      width: r * 2,
      height: r * 2,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        disc(130, halo.withValues(alpha: 0.10)),
        disc(86, halo.withValues(alpha: 0.16)),
        disc(52, core),
      ],
    );
  }
}
