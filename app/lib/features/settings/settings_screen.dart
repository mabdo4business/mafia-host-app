import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../game/providers.dart';
import '../../ui/ui.dart';
import '../gallery/gallery_screen.dart';

const _timerOptions = [0, 60, 120, 180, 300];

/// Language, sound, haptics and the defaults every new game starts from.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.mafia;
    final prefs = ref.watch(preferencesProvider).value ?? const AppPreferences();
    final controller = ref.read(preferencesProvider.notifier);

    Widget toggle(String title, String? subtitle, bool value, ValueChanged<bool> onChanged) =>
        GlassCard(
          radius: Radii.tile,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.xs, vertical: 2),
          child: SwitchListTile(
            title: Text(
              title,
              style: context.type.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
            ),
            subtitle: subtitle == null
                ? null
                : Text(subtitle, style: context.type.bodySmall!.copyWith(fontSize: 12)),
            value: value,
            onChanged: onChanged,
          ),
        );

    Widget block(String title, Widget control, {String? subtitle}) => GlassCard(
      radius: Radii.tile,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.lg, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: context.type.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
          if (subtitle != null)
            Text(subtitle, style: context.type.bodySmall!.copyWith(fontSize: 12)),
          const SizedBox(height: Space.md),
          control,
        ],
      ),
    );

    return PhaseScaffold(
      glow: Glow(color: MafiaColors.night.glow, start: -100, end: null, top: -160, size: 420),
      body: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(
          Space.page,
          Space.sm,
          Space.page,
          Navigator.canPop(context) ? Space.xl : 120,
        ),
        children: [
          Row(
            children: [
              if (Navigator.canPop(context)) ...[
                IconCircleButton(
                  glyph: MafiaGlyphs.back,
                  semanticLabel: l.back,
                  onPressed: () => Navigator.maybePop(context),
                ),
                const SizedBox(width: Space.md),
              ],
              Text(l.settingsTitle, style: context.type.headlineLarge),
            ],
          ),
          const SizedBox(height: Space.xl),
          block(
            l.settingsLanguage,
            SegmentedPill<String?>(
              key: const Key('languagePill'),
              // Language names are shown in their own language on purpose.
              segments: [
                (null, l.settingsDeviceShort),
                ('en', l.languageEnglish),
                ('ar', l.languageArabic),
              ],
              selected: prefs.locale?.languageCode,
              onChanged: (code) => controller.setLocale(code == null ? null : Locale(code)),
            ),
          ),
          const SizedBox(height: 28),
          SectionTitle(l.settingsFeedbackSection),
          const SizedBox(height: Space.md),
          toggle(
            l.settingsSound,
            l.settingsSoundSubtitle,
            prefs.soundEnabled,
            controller.setSoundEnabled,
          ),
          const SizedBox(height: 10),
          toggle(
            l.settingsHaptics,
            l.settingsHapticsSubtitle,
            prefs.hapticsEnabled,
            controller.setHapticsEnabled,
          ),
          const SizedBox(height: 28),
          SectionTitle(l.settingsDefaultsSection),
          const SizedBox(height: Space.xs),
          Text(l.settingsDefaultsHint, style: context.type.bodySmall),
          const SizedBox(height: Space.md),
          toggle(l.setupRevealRole, null, prefs.defaultRevealRole, controller.setDefaultRevealRole),
          const SizedBox(height: 10),
          GlassCard(
            radius: Radii.tile,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.lg, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.setupBombTakesDown,
                        style: context.type.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        l.setupBombTakesDownHint,
                        style: context.type.bodySmall!.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SegmentedPill<int>(
                  dense: true,
                  segments: [
                    for (final n in [2, 3]) (n, context.number(n)),
                  ],
                  selected: prefs.defaultBombVictims,
                  onChanged: controller.setDefaultBombVictims,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          block(
            l.setupDiscussionTimerMinutes,
            SegmentedPill<int>(
              segments: [
                for (final s in _timerOptions) (s, s == 0 ? l.timerOff : context.number(s ~/ 60)),
              ],
              selected: prefs.defaultDiscussionSeconds,
              onChanged: controller.setDefaultDiscussionSeconds,
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 28),
            ListTile(
              // Debug-only developer tool; not shipped, not localized.
              title: Text('Component gallery', style: TextStyle(color: c.textMuted)),
              onTap: () => Navigator.pushNamed(context, GalleryScreen.route),
            ),
          ],
        ],
      ),
    );
  }
}
