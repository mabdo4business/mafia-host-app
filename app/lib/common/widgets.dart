import 'package:material_ui/material_ui.dart';
import 'package:mafia_engine/mafia_engine.dart';

import 'l10n.dart';

/// Team accent colors, tuned per brightness.
Color teamColor(BuildContext context, Team team) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (team) {
    Team.mafia => dark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
    Team.civilians => dark ? const Color(0xFF80CBC4) : const Color(0xFF00695C),
  };
}

/// A small pill with the player's role, tinted by team.
class RoleChip extends StatelessWidget {
  const RoleChip(this.player, {super.key});

  final Player player;

  @override
  Widget build(BuildContext context) {
    final color = teamColor(context, player.team);
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        context.l10n.playerRole(player),
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 8, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

/// Lines the host reads out loud to the table.
class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({super.key, required this.lines, this.title});

  final List<String> lines;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign_outlined, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Text(
                  title ?? context.l10n.readAloud,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final line in lines)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 8),
                child: Text(
                  line,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Information the table must not see.
class HostOnlyCard extends StatelessWidget {
  const HostOnlyCard({super.key, required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.visibility_off_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(context.l10n.hostOnly, style: theme.textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 8),
            for (final line in lines)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 4),
                child: Text(line, style: theme.textTheme.bodyMedium),
              ),
          ],
        ),
      ),
    );
  }
}

/// Pinned bottom area for the screen's main action(s).
class BottomActions extends StatelessWidget {
  const BottomActions({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Material(
    elevation: 3,
    color: Theme.of(context).colorScheme.surfaceContainer,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
        child: Row(
          children: [
            for (final (i, child) in children.indexed) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: child),
            ],
          ],
        ),
      ),
    ),
  );
}

/// A tappable player row used by every picker.
class PlayerOption extends StatelessWidget {
  const PlayerOption({
    super.key,
    required this.player,
    required this.selected,
    required this.onTap,
    this.note,
    this.showRole = true,
  });

  final Player player;
  final bool selected;
  final VoidCallback? onTap;
  final String? note;
  final bool showRole;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: selected ? scheme.secondaryContainer : scheme.surfaceContainerLow,
      margin: const EdgeInsetsDirectional.symmetric(vertical: 4),
      child: ListTile(
        enabled: onTap != null,
        onTap: onTap,
        title: Text(player.name),
        subtitle: note == null ? null : Text(note!),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showRole) RoleChip(player),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? scheme.primary : scheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(confirmLabel)),
        ],
      ),
    ) ??
    false;
