import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../data/game_repository.dart';
import '../../game/providers.dart';
import '../../ui/ui.dart';
import 'player_profile_screen.dart';

/// Players ranked by wins: a podium for the top three, then the rest.
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.mafia;
    final records = ref.watch(playerRecordsProvider).value ?? const [];
    // Gold, silver, bronze.
    final medals = [c.civilian, c.textMuted, c.bomb];

    void open(PlayerRecord r) => Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => PlayerProfileScreen(name: r.name)),
    );

    return PhaseScaffold(
      glow: Glow(color: c.tint(c.civilian, 0.14)),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, 120),
        children: [
          Text(l.leaderboardTitle, style: context.type.headlineLarge),
          const SizedBox(height: Space.xs),
          Text(l.leaderboardSubtitle, style: context.type.bodySmall),
          const SizedBox(height: Space.xl),
          if (records.isEmpty)
            GlassCard(child: Text(l.leaderboardEmpty, style: context.type.bodyMedium))
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Podium order: 2nd, 1st, 3rd (mirrors in RTL).
                for (final rank in const [1, 0, 2]) ...[
                  if (rank != 1) const SizedBox(width: 10),
                  Expanded(
                    child: rank < records.length
                        ? _PodiumCard(
                            record: records[rank],
                            rank: rank + 1,
                            color: medals[rank],
                            onTap: () => open(records[rank]),
                          )
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: Space.xl),
            for (final (i, r) in records.indexed.skip(3)) ...[
              GlassCard(
                key: Key('rank_${r.name}'),
                radius: Radii.tile,
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: Space.md),
                onTap: () => open(r),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        context.number(i + 1),
                        style: context.type.titleMedium!.copyWith(color: c.textMuted),
                      ),
                    ),
                    Avatar(r.name, size: Sizes.avatarLg),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.type.bodyLarge!.copyWith(fontSize: TextSizes.row),
                          ),
                          Text(
                            l.leaderboardRowDetail(r.games, r.winRate),
                            style: context.type.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(context.number(r.wins), style: context.type.titleLarge),
                  ],
                ),
              ),
              const SizedBox(height: Space.sm),
            ],
          ],
        ],
      ),
    );
  }
}

class _PodiumCard extends StatelessWidget {
  const _PodiumCard({
    required this.record,
    required this.rank,
    required this.color,
    required this.onTap,
  });

  final PlayerRecord record;
  final int rank;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    return GlassCard(
      key: Key('podium_$rank'),
      tintColor: color,
      fillOpacity: 0.10,
      borderOpacity: rank == 1 ? 0.45 : 0.28,
      radius: Radii.card,
      onTap: onTap,
      padding: EdgeInsetsDirectional.fromSTEB(Space.sm, rank == 1 ? 22 : 14, Space.sm, 14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: c.tint(color, 0.22),
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
            child: Text(
              context.number(rank),
              style: context.type.labelMedium!.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          Avatar(record.name, size: rank == 1 ? 56 : 44, color: rank == 1 ? color : null),
          const SizedBox(height: Space.sm),
          Text(
            record.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.labelMedium,
          ),
          const SizedBox(height: 2),
          Text(
            l.leaderboardWins(record.wins),
            style: context.type.bodySmall!.copyWith(fontSize: TextSizes.small, color: color),
          ),
        ],
      ),
    );
  }
}
