import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../game/game_menu.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../ui/ui.dart';
import '../setup/setup_screen.dart';

/// The winners, under a slowly pulsing glow in their color, and every
/// player's card revealed.
class GameOverView extends ConsumerWidget {
  const GameOverView({super.key, required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.mafia;
    final winner = session.state.winner!;
    final (accent, soft) = teamColors(c, winner);
    final still = MediaQuery.disableAnimationsOf(context);
    final width = MediaQuery.sizeOf(context).width;

    Widget glow = Container(
      width: 460,
      height: 460,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [c.tint(accent, 0.30), c.tint(accent, 0)],
          stops: const [0, 0.7],
        ),
      ),
    );
    if (!still) {
      glow = glow
          .animate(onPlay: (a) => a.repeat(reverse: true))
          .scaleXY(begin: 0.9, end: 1.08, duration: 2400.ms, curve: Curves.easeInOut)
          .fade(begin: 0.7, end: 1, duration: 2400.ms);
    }

    return PhaseScaffold(
      transparent: true,
      backdrop: PositionedDirectional(
        top: -120,
        start: (width - 460) / 2,
        child: IgnorePointer(child: glow),
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, Space.lg),
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GameMenuButton(session: session),
          ),
          const SizedBox(height: Space.xl),
          Center(
            child: Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.tint(accent, 0.16),
                border: Border.all(color: c.tint(accent, 0.45)),
              ),
              child: MafiaIcon(
                winner == Team.mafia ? MafiaGlyphs.mafiaWon : MafiaGlyphs.trophy,
                size: 40,
                color: soft,
              ),
            ),
          ),
          const SizedBox(height: Space.xl),
          Center(child: Overline(l.stageGameOver, color: soft, wide: true)),
          const SizedBox(height: Space.sm),
          Text(
            winner == Team.mafia ? l.winMafia : l.winCivilians,
            key: const Key('winnerTitle'),
            textAlign: TextAlign.center,
            style: context.type.displayLarge!.copyWith(color: soft),
          ),
          const SizedBox(height: Space.sm),
          Text(
            l.gameOverSummary(session.round, session.state.alivePlayers.length),
            textAlign: TextAlign.center,
            style: context.type.bodyMedium!.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.xxl),
          SectionTitle(l.gameOverAllRoles),
          const SizedBox(height: Space.md),
          for (final p in session.state.players) ...[
            _RevealRow(player: p),
            const SizedBox(height: Space.sm),
          ],
        ],
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryActionButton(
            key: const Key('playAgain'),
            label: l.gameOverPlayAgain,
            tone: winner == Team.mafia ? ActionTone.danger : ActionTone.phase,
            trailing: MafiaGlyphs.shuffle,
            onPressed: () {
              ref.read(activeGameProvider.notifier).close();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SetupScreen()));
            },
          ),
          SizedBox(
            height: Sizes.iconButton + Space.xs,
            child: TextButton(
              key: const Key('backHome'),
              style: TextButton.styleFrom(foregroundColor: c.textMuted),
              onPressed: () {
                ref.read(activeGameProvider.notifier).close();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text(l.gameOverBackHome),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar, name, role chip and alive / out.
class _RevealRow extends StatelessWidget {
  const _RevealRow({required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final (accent, soft) = teamColors(c, player.team);
    final alive = player.isAlive;
    return Opacity(
      opacity: alive ? 1 : 0.6,
      child: GlassCard(
        radius: Radii.tile,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: Space.md),
        child: Row(
          children: [
            Avatar(player.name, size: Sizes.avatarLg),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.bodyLarge!.copyWith(
                      fontSize: TextSizes.row,
                      decoration: alive ? null : TextDecoration.lineThrough,
                      decorationColor: c.textMuted,
                    ),
                  ),
                  Text(
                    alive ? l.statusAlive : l.statusEliminated,
                    style: context.type.bodySmall!.copyWith(fontSize: TextSizes.small),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: c.tint(accent, 0.14),
                borderRadius: BorderRadius.circular(Radii.chip),
                border: Border.all(color: c.tint(accent, 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MafiaIcon(roleGlyph(player.effectiveRole), size: 14, color: soft),
                  const SizedBox(width: 6),
                  Text(
                    l.playerRole(player),
                    style: context.type.labelMedium!.copyWith(color: soft),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
