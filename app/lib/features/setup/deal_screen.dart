import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';

import '../../common/l10n.dart';
import '../../common/widgets.dart';
import '../../game/game_flow_screen.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../game/role_mix.dart';

/// Random deal: shows the host which card goes to whom, and lets each
/// Chameleon pick the role they will play before night 1.
class DealScreen extends ConsumerStatefulWidget {
  const DealScreen({
    super.key,
    required this.names,
    required this.mix,
    required this.settings,
    required this.discussionSeconds,
    this.random,
  });

  final List<String> names;
  final Map<Role, int> mix;
  final GameSettings settings;
  final int discussionSeconds;

  /// Injected in tests for a predictable deal.
  final Random? random;

  @override
  ConsumerState<DealScreen> createState() => _DealScreenState();
}

class _DealScreenState extends ConsumerState<DealScreen> {
  late final Random _random = widget.random ?? Random.secure();
  late List<Player> _players;
  final Map<String, Role> _chameleonPicks = {};
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _deal();
  }

  void _deal() {
    _players = dealRoles(widget.names, widget.mix, _random);
    _chameleonPicks.clear();
  }

  bool get _ready => _players
      .where((p) => p.role == Role.chameleon)
      .every((p) => _chameleonPicks.containsKey(p.id));

  Future<void> _start() async {
    setState(() => _starting = true);
    final setup = GameSetup(
      settings: widget.settings,
      discussionSeconds: widget.discussionSeconds,
      players: [
        for (final p in _players)
          Player(id: p.id, name: p.name, role: p.role, chameleonRole: _chameleonPicks[p.id]),
      ],
    );
    await ref.read(activeGameProvider.notifier).start(setup);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const GameFlowScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final choices = chameleonChoices(widget.settings);
    return Scaffold(
      appBar: AppBar(title: Text(l.dealTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: [
          Text(l.dealInstructions, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          for (final (i, p) in _players.indexed)
            Card(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(child: Text(context.number(i + 1))),
                      title: Text(p.name),
                      trailing: RoleChip(p),
                    ),
                    if (p.role == Role.chameleon)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
                        child: DropdownButtonFormField<Role>(
                          key: Key('chameleonPick_${p.id}'),
                          initialValue: _chameleonPicks[p.id],
                          decoration: InputDecoration(
                            labelText: l.dealChameleonPlaysAs,
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            for (final r in choices)
                              DropdownMenuItem(value: r, child: Text(l.role(r))),
                          ],
                          onChanged: (r) => setState(() => _chameleonPicks[p.id] = r!),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (!_ready)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 8),
              child: Text(
                l.dealChameleonMissing,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomActions(
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.shuffle),
            label: Text(l.dealReshuffle),
            onPressed: _starting ? null : () => setState(_deal),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.nightlight_round),
            label: Text(l.dealStartGame),
            onPressed: _ready && !_starting ? _start : null,
          ),
        ],
      ),
    );
  }
}
