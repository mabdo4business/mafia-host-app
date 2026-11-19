import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../game/providers.dart';
import '../../ui/ui.dart';

/// One player's record: games, win rate, favorite role and the roles
/// they've played.
class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.mafia;
    final records = ref.watch(playerRecordsProvider).value ?? const [];
    final r = records.where((r) => r.name == name).firstOrNull;
    final favorite = r?.favoriteRole;
    final roles = (r?.roles.entries.toList() ?? [])..sort((a, b) => b.value.compareTo(a.value));
    final most = roles.isEmpty ? 1 : roles.first.value;

    return PhaseScaffold(
      glow: Glow(color: MafiaColors.night.glow, start: -100, end: null, top: -160, size: 420),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, Space.xl),
        children: [
          Row(
            children: [
              IconCircleButton(
                glyph: MafiaGlyphs.back,
                semanticLabel: l.back,
                onPressed: () => Navigator.maybePop(context),
              ),
            ],
          ),
          const SizedBox(height: Space.lg),
          Center(child: Avatar(name, size: 88)),
          const SizedBox(height: Space.lg),
          Text(name, textAlign: TextAlign.center, style: context.type.headlineLarge),
          if (r != null) ...[
            const SizedBox(height: Space.xs),
            Text(
              l.profileLastPlayed(MaterialLocalizations.of(context).formatMediumDate(r.lastPlayed)),
              textAlign: TextAlign.center,
              style: context.type.bodySmall,
            ),
          ],
          const SizedBox(height: Space.xl),
          Row(
            children: [
              Expanded(
                child: StatTile(value: context.number(r?.games ?? 0), label: l.statGames),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  value: r == null ? l.statNone : l.percent(r.winRate),
                  label: l.profileWinRate,
                  tint: c.civilian,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatTile(
                  value: favorite == null ? l.statNone : l.role(favorite),
                  label: l.profileFavoriteRole,
                  tint: favorite == null ? null : teamColors(c, favorite.team).$1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SectionTitle(l.profileRoleHistory),
          const SizedBox(height: Space.md),
          if (roles.isEmpty)
            Text(l.profileNoGames, style: context.type.bodySmall)
          else
            GlassCard(
              child: Column(
                children: [
                  for (final (i, MapEntry(key: role, value: n)) in roles.indexed) ...[
                    if (i > 0) const SizedBox(height: 14),
                    _RoleBar(role: role, count: n, of: most),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RoleBar extends StatelessWidget {
  const _RoleBar({required this.role, required this.count, required this.of});

  final Role role;
  final int count, of;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final (accent, soft) = teamColors(c, role.team);
    return Row(
      children: [
        MafiaIcon(roleGlyph(role), size: 18, color: soft),
        const SizedBox(width: 10),
        SizedBox(
          width: 92,
          child: Text(
            l.role(role),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.type.labelMedium,
          ),
        ),
        Expanded(
          child: Container(
            height: 10,
            alignment: AlignmentDirectional.centerStart,
            decoration: BoxDecoration(color: c.veil(0.06), borderRadius: BorderRadius.circular(5)),
            child: FractionallySizedBox(
              widthFactor: count / of,
              child: Container(
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(5)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 24,
          child: Text(
            context.number(count),
            textAlign: TextAlign.end,
            style: context.type.labelMedium!.copyWith(color: c.textMuted),
          ),
        ),
      ],
    );
  }
}
