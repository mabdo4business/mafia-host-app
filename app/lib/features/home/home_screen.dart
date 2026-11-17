import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/l10n.dart';
import '../../common/widgets.dart';
import '../../game/game_session.dart';
import '../../game/game_flow_screen.dart';
import '../../game/providers.dart';
import '../settings/settings_screen.dart';
import '../setup/setup_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final active = ref.watch(activeGameProvider).value;
    final canContinue = active != null && active.stage != GameStage.gameOver;

    Future<void> newGame() async {
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

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsetsDirectional.all(24),
            children: [
              Icon(Icons.nights_stay_rounded, size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(l.appTitle, textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(l.homeTagline, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 40),
              if (canContinue) ...[
                FilledButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text('${l.homeContinueGame} · ${l.stageTitle(active)}'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const GameFlowScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l.homeNewGame),
                  onPressed: newGame,
                ),
              ] else
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l.homeNewGame),
                  onPressed: newGame,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
