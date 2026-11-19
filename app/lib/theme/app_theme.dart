// Mafia Host — design tokens and themes.
// Source of truth: docs/design/DESIGN.md and docs/design/mockups/*.dc.html
//
// Usage:
//   MaterialApp(theme: AppTheme.night(locale))
//   final c = context.mafia;           // colors
//   AnimatedTheme(data: isNight ? AppTheme.night(l) : AppTheme.day(l), ...)
//     → MafiaColors.lerp gives the night→morning transition for free.

import 'package:material_ui/material_ui.dart';

/// Spacing scale. Use these only.
abstract final class Space {
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32, xxxl = 48;

  /// Page side padding.
  static const double page = 24;

  /// Bottom padding under the primary action (home-indicator safe).
  static const double bottomAction = 34;
}

/// Corner radii.
abstract final class Radii {
  static const double chip = 10, tile = 18, card = 24, hero = 28, button = 20, pill = 999;
  static const double iconBox = 12, iconBoxLg = 16;
}

/// Sizes that matter for thumb use.
abstract final class Sizes {
  static const double primaryButton = 60; // bottom CTA height
  static const double heroButton = 56; // CTA inside cards
  static const double iconButton = 44;
  static const double playerTile = 80;
  static const double avatar = 32, avatarLg = 36;
}

/// Motion durations and curves.
abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 240);
  static const Duration cardFlip = Duration(milliseconds: 700);
  static const Duration phaseChange = Duration(milliseconds: 800);
  static const Duration announceStagger = Duration(milliseconds: 400);
  static const Curve ease = Curves.easeOutCubic;
  static const Curve flip = Cubic(0.2, 0.8, 0.2, 1);
}

@immutable
class MafiaColors extends ThemeExtension<MafiaColors> {
  const MafiaColors({
    required this.bg,
    required this.bgTop,
    required this.surface,
    required this.surfaceBorder,
    required this.text,
    required this.textMuted,
    required this.glow,
    required this.mafia,
    required this.mafiaSoft,
    required this.civilian,
    required this.civilianSoft,
    required this.primaryCta,
    required this.onPrimaryCta,
    required this.stepDone,
    required this.bomb,
    required this.saved,
    required this.avatar,
    required this.onAvatar,
  });

  final Color bg; // page background
  final Color bgTop; // top of the page gradient (dawn on day screens)
  final Color surface; // glass card fill
  final Color surfaceBorder; // glass card border
  final Color text;
  final Color textMuted;
  final Color glow; // atmospheric radial glow (moon / sun)
  final Color mafia; // Mafia team, destructive actions
  final Color mafiaSoft; // Mafia text on dark
  final Color civilian; // Civilians team, night CTAs
  final Color civilianSoft; // Civilian text on dark
  final Color primaryCta; // phase CTA color
  final Color onPrimaryCta;
  final Color stepDone; // completed night steps
  final Color bomb; // Bomb explosion events
  final Color saved; // Doctor save events
  final Color avatar;
  final Color onAvatar;

  /// Cold, ink-black night palette.
  static const night = MafiaColors(
    bg: Color(0xFF07080C),
    bgTop: Color(0xFF05060A),
    surface: Color(0x0AFFFFFF), // white 4%
    surfaceBorder: Color(0x14FFFFFF), // white 8%
    text: Color(0xFFF2EEE6),
    textMuted: Color(0xFF9AA0AE),
    glow: Color(0x2E6E82FF), // moon blue 18%
    mafia: Color(0xFFE5484D),
    mafiaSoft: Color(0xFFFF8A8E),
    civilian: Color(0xFFE8B54A),
    civilianSoft: Color(0xFFF3CD78),
    primaryCta: Color(0xFFE8B54A),
    onPrimaryCta: Color(0xFF1A1408),
    stepDone: Color(0xFF6E7AA8),
    bomb: Color(0xFFF58C3C),
    saved: Color(0xFF3FC5B0),
    avatar: Color(0xFF232633),
    onAvatar: Color(0xFFD6D2CB),
  );

  /// Warm amber morning / day palette.
  static const day = MafiaColors(
    bg: Color(0xFF120D0B),
    bgTop: Color(0xFF3A2116),
    surface: Color(0x0FFFFFFF), // white 6%
    surfaceBorder: Color(0x2EFFFFFF), // white 18%
    text: Color(0xFFFBF4EA),
    textMuted: Color(0xFFCDBFAE),
    glow: Color(0x29FFC870), // sun 16%
    mafia: Color(0xFFE5484D),
    mafiaSoft: Color(0xFFFF8A8E),
    civilian: Color(0xFFE8B54A),
    civilianSoft: Color(0xFFFFD9A0),
    primaryCta: Color(0xFFFFC870),
    onPrimaryCta: Color(0xFF2A1606),
    stepDone: Color(0xFFCDBFAE),
    bomb: Color(0xFFF58C3C),
    saved: Color(0xFF3FC5B0),
    avatar: Color(0xFF2E2420),
    onAvatar: Color(0xFFE6DCCF),
  );

  /// Tinted fill for a team or event color (cards, chips, icon boxes).
  Color tint(Color c, [double opacity = 0.14]) => c.withValues(alpha: opacity);

  /// Label color on a solid fill of [c]: white on dark fills (Mafia red),
  /// a deep shade of the same hue on light ones (gold, bomb, saved).
  Color onAccent(Color c) => c.computeLuminance() < 0.3
      ? const Color(0xFFFFFFFF)
      : Color.lerp(c, const Color(0xFF000000), 0.86)!;

  /// Text drawn on top of [text]-colored fills (selected pill segments).
  Color get onText => Color.lerp(bg, const Color(0xFF000000), 0.2)!;

  /// Faint white overlays used by tracks, chips and disabled fills.
  Color veil(double opacity) => const Color(0xFFFFFFFF).withValues(alpha: opacity);

  @override
  MafiaColors copyWith({
    Color? bg,
    Color? bgTop,
    Color? surface,
    Color? surfaceBorder,
    Color? text,
    Color? textMuted,
    Color? glow,
    Color? mafia,
    Color? mafiaSoft,
    Color? civilian,
    Color? civilianSoft,
    Color? primaryCta,
    Color? onPrimaryCta,
    Color? stepDone,
    Color? bomb,
    Color? saved,
    Color? avatar,
    Color? onAvatar,
  }) {
    return MafiaColors(
      bg: bg ?? this.bg,
      bgTop: bgTop ?? this.bgTop,
      surface: surface ?? this.surface,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      glow: glow ?? this.glow,
      mafia: mafia ?? this.mafia,
      mafiaSoft: mafiaSoft ?? this.mafiaSoft,
      civilian: civilian ?? this.civilian,
      civilianSoft: civilianSoft ?? this.civilianSoft,
      primaryCta: primaryCta ?? this.primaryCta,
      onPrimaryCta: onPrimaryCta ?? this.onPrimaryCta,
      stepDone: stepDone ?? this.stepDone,
      bomb: bomb ?? this.bomb,
      saved: saved ?? this.saved,
      avatar: avatar ?? this.avatar,
      onAvatar: onAvatar ?? this.onAvatar,
    );
  }

  @override
  MafiaColors lerp(ThemeExtension<MafiaColors>? other, double t) {
    if (other is! MafiaColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return MafiaColors(
      bg: l(bg, other.bg),
      bgTop: l(bgTop, other.bgTop),
      surface: l(surface, other.surface),
      surfaceBorder: l(surfaceBorder, other.surfaceBorder),
      text: l(text, other.text),
      textMuted: l(textMuted, other.textMuted),
      glow: l(glow, other.glow),
      mafia: l(mafia, other.mafia),
      mafiaSoft: l(mafiaSoft, other.mafiaSoft),
      civilian: l(civilian, other.civilian),
      civilianSoft: l(civilianSoft, other.civilianSoft),
      primaryCta: l(primaryCta, other.primaryCta),
      onPrimaryCta: l(onPrimaryCta, other.onPrimaryCta),
      stepDone: l(stepDone, other.stepDone),
      bomb: l(bomb, other.bomb),
      saved: l(saved, other.saved),
      avatar: l(avatar, other.avatar),
      onAvatar: l(onAvatar, other.onAvatar),
    );
  }
}

extension MafiaThemeX on BuildContext {
  MafiaColors get mafia => Theme.of(this).extension<MafiaColors>()!;
  TextTheme get type => Theme.of(this).textTheme;
}

abstract final class AppTheme {
  static ThemeData night(Locale locale) => _build(MafiaColors.night, locale);
  static ThemeData day(Locale locale) => _build(MafiaColors.day, locale);

  static bool _isArabic(Locale l) => l.languageCode == 'ar';

  /// Display: Unbounded (Latin) / Cairo (Arabic). Body: Inter / IBM Plex Sans Arabic.
  /// Bundled as asset font families (see pubspec.yaml) so the app works
  /// offline. Each falls back to the other script's face for mixed text
  /// (an Arabic name in the English UI).
  static TextTheme _textTheme(MafiaColors c, Locale locale) {
    final ar = _isArabic(locale);
    TextStyle display(double size, FontWeight w) =>
        (ar
                ? TextStyle(
                    fontFamily: 'Cairo',
                    fontFamilyFallback: const ['IBMPlexSansArabic'],
                    fontSize: size + 2,
                    fontWeight: FontWeight.w800,
                  )
                : TextStyle(
                    fontFamily: 'Unbounded',
                    fontFamilyFallback: const ['Cairo'],
                    fontSize: size,
                    fontWeight: w,
                    letterSpacing: -0.2,
                  ))
            .copyWith(color: c.text, height: 1.2);
    TextStyle body(double size, FontWeight w, Color color) =>
        (ar
                ? TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontFamilyFallback: const ['Inter'],
                    fontSize: size + 1,
                    fontWeight: w,
                    height: 1.6,
                  )
                : TextStyle(
                    fontFamily: 'Inter',
                    fontFamilyFallback: const ['IBMPlexSansArabic'],
                    fontSize: size,
                    fontWeight: w,
                    height: 1.45,
                  ))
            .copyWith(color: color);

    return TextTheme(
      displayLarge: display(34, FontWeight.w700), // big numbers (player count)
      displayMedium: display(30, FontWeight.w700), // role name on card
      headlineLarge: display(26, FontWeight.w700), // screen hero line
      headlineMedium: display(22, FontWeight.w700), // card title
      headlineSmall: display(20, FontWeight.w700), // app bar title
      titleLarge: display(17, FontWeight.w700), // prompt title ("Wake the Doctor")
      titleMedium: display(15, FontWeight.w500), // section header
      bodyLarge: body(16, FontWeight.w600, c.text), // primary list text
      bodyMedium: body(14, FontWeight.w400, c.text),
      bodySmall: body(13, FontWeight.w400, c.textMuted),
      labelLarge: body(16, FontWeight.w600, c.text), // buttons
      labelMedium: body(13, FontWeight.w600, c.text),
      labelSmall: body(12, FontWeight.w600, c.textMuted).copyWith(letterSpacing: 0.8), // OVERLINE
    );
  }

  static ThemeData _build(MafiaColors c, Locale locale) {
    final scheme = ColorScheme.dark(
      surface: c.bg,
      onSurface: c.text,
      primary: c.primaryCta,
      onPrimary: c.onPrimaryCta,
      secondary: c.civilian,
      error: c.mafia,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      textTheme: _textTheme(c, locale),
      splashFactory: InkSparkle.splashFactory,
      extensions: [c],
    );
  }
}
