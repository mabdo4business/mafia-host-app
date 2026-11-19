import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../common/widgets.dart';
import '../../game/game_flow_screen.dart';
import '../../game/game_session.dart';
import '../../ui/ui.dart';
import '../setup/setup_screen.dart';

/// Opens setup, first confirming if a game in progress would be closed.
Future<void> startNewGame(BuildContext context, {required bool canContinue}) async {
  final l = context.l10n;
  if (canContinue &&
      !await confirm(
        context,
        title: l.newGameConfirmTitle,
        body: l.newGameConfirmBody,
        confirmLabel: l.homeNewGame,
      )) {
    return;
  }
  if (!context.mounted) return;
  Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SetupScreen()));
}

void continueGame(BuildContext context) =>
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const GameFlowScreen()));

/// The red "tonight" card: start a game, or continue the one in progress.
class TonightCard extends StatelessWidget {
  const TonightCard({
    super.key,
    required this.session,
    required this.lastNames,
    required this.onStart,
    required this.onContinue,
  });

  /// The game in progress, if any.
  final GameSession? session;
  final List<String> lastNames;
  final VoidCallback onStart;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final s = session;
    final cardColor = Color.alphaBlend(c.tint(c.mafia, 0.10), c.bg);
    final names = s == null ? lastNames : [for (final p in s.state.players) p.name];

    return Stack(
      children: [
        GlassCard(
          radius: Radii.hero,
          tintColor: c.mafia,
          borderOpacity: 0.25,
          padding: const EdgeInsetsDirectional.all(Space.xl),
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [cardColor, Color.alphaBlend(c.veil(0.03), c.bg)],
            stops: const [0, 0.7],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TagPill(
                s == null ? l.homeHeroTag : l.homeHeroInProgress,
                color: c.mafia,
                textColor: c.mafiaSoft,
                dot: true,
              ),
              const SizedBox(height: 14),
              Text(
                s == null ? l.homeHeroTitle : l.stageTitle(s),
                style: context.type.headlineMedium,
              ),
              const SizedBox(height: 14),
              Text(
                s != null
                    ? l.playerCount(s.state.players.length)
                    : names.isEmpty
                    ? l.homeHeroEmpty
                    : l.homeHeroLastTable(names.length),
                style: context.type.bodyMedium!.copyWith(color: c.textMuted),
              ),
              if (names.isNotEmpty) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    AvatarStack(
                      names: names.take(3).toList(),
                      extra: names.length > 3 ? names.length - 3 : 0,
                      ring: cardColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      s == null
                          ? l.homeHeroReady(names.length)
                          : l.homeHeroAlive(s.state.alivePlayers.length),
                      style: context.type.bodySmall,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              PrimaryActionButton(
                key: Key(s == null ? 'homeNewGame' : 'homeContinue'),
                label: s == null ? l.homeStartGame : l.homeContinueAt(l.stageTitle(s)),
                tone: ActionTone.danger,
                trailing: MafiaGlyphs.arrow,
                height: Sizes.heroButton,
                radius: Radii.tile,
                onPressed: s == null ? onStart : onContinue,
              ),
              if (s != null)
                Center(
                  child: TextButton(
                    key: const Key('homeNewGame'),
                    onPressed: onStart,
                    style: TextButton.styleFrom(
                      foregroundColor: c.textMuted,
                      minimumSize: const Size(48, 44),
                    ),
                    child: Text(l.homeNewGame),
                  ),
                ),
            ],
          ),
        ),
        PositionedDirectional(
          top: -18,
          end: -14,
          child: IgnorePointer(
            child: CustomPaint(
              size: const Size.square(120),
              painter: CrescentPainter(moon: c.text, shadow: cardColor),
            ),
          ),
        ),
      ],
    );
  }
}

/// The hero card's crescent moon: a disc with a card-colored disc over it.
class CrescentPainter extends CustomPainter {
  CrescentPainter({required this.moon, required this.shadow});

  final Color moon, shadow;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 120);
    canvas.saveLayer(Offset.zero & const Size.square(120), Paint());
    canvas.drawCircle(const Offset(70, 50), 34, Paint()..color = moon.withValues(alpha: 0.92));
    canvas.drawCircle(const Offset(84, 40), 32, Paint()..blendMode = BlendMode.dstOut);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CrescentPainter old) => old.moon != moon || old.shadow != shadow;
}
