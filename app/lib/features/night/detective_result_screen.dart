import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../ui/ui.dart';

/// Host only: the answer to show the Detective, full screen and big enough
/// to signal across the table. Pops `true` to continue the night.
class DetectiveResultScreen extends StatelessWidget {
  const DetectiveResultScreen({super.key, required this.targetName, required this.result});

  final String targetName;

  /// Null when the Detective was blocked tonight: give no answer.
  final DetectiveResult? result;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final r = result;
    final color = r == null
        ? c.textMuted
        : r == DetectiveResult.mafia
        ? c.mafia
        : c.civilian;
    final soft = r == null
        ? c.textMuted
        : r == DetectiveResult.mafia
        ? c.mafiaSoft
        : c.civilianSoft;

    return PhaseScaffold(
      glow: Glow(
        color: c.tint(color, r == null ? 0.10 : 0.28),
        top: 140,
        size: 480,
        start: (MediaQuery.sizeOf(context).width - 480) / 2,
        fade: 0.65,
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconCircleButton(
                  glyph: MafiaGlyphs.back,
                  semanticLabel: l.back,
                  onPressed: () => Navigator.pop(context, false),
                ),
                const Spacer(),
                TagPill(l.hostOnly, color: c.textMuted, textColor: c.textMuted),
              ],
            ),
            Expanded(
              child: Center(
                child: GlassCard(
                  key: const Key('detectiveAnswer'),
                  // Same width in every language.
                  radius: Radii.hero,
                  tintColor: r == null ? null : color,
                  fillOpacity: 0.10,
                  borderOpacity: 0.40,
                  padding: const EdgeInsetsDirectional.fromSTEB(Space.xl, 36, Space.xl, 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.tint(color, 0.16),
                            border: Border.all(color: c.tint(color, 0.4)),
                          ),
                          child: MafiaIcon(
                            r == null ? MafiaGlyphs.putana : MafiaGlyphs.detective,
                            size: 34,
                            color: soft,
                          ),
                        ),
                      ),
                      const SizedBox(height: Space.xl),
                      Text(
                        r == null ? l.detectiveBlockedTitle : l.detectiveChecked(targetName),
                        textAlign: TextAlign.center,
                        style: context.type.bodyLarge!.copyWith(color: c.textMuted),
                      ),
                      const SizedBox(height: Space.md),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          r == null
                              ? l.detectiveNoAnswer
                              : r == DetectiveResult.mafia
                              ? l.resultMafia
                              : l.resultCivilian,
                          style: context.type.displayLarge!.copyWith(
                            fontSize: TextSizes.verdict,
                            color: soft,
                          ),
                        ),
                      ),
                      const SizedBox(height: Space.lg),
                      Text(
                        r == null ? l.nightDetectiveBlocked : l.detectiveSignalHint,
                        textAlign: TextAlign.center,
                        style: context.type.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PrimaryActionButton(
        key: const Key('detectiveDone'),
        label: l.detectiveDone,
        trailing: MafiaGlyphs.arrow,
        onPressed: () => Navigator.pop(context, true),
      ),
    );
  }
}
