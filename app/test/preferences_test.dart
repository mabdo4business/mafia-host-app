import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_host/game/providers.dart';

import 'helpers.dart';

void main() {
  test('setup defaults from Settings start every new game and are remembered', () async {
    final db = memoryDb();
    final container = containerFor(db);
    addTearDown(container.dispose);
    await container.read(preferencesProvider.future);
    final prefs = container.read(preferencesProvider.notifier);
    await prefs.setDefaultBombVictims(3);
    await prefs.setDefaultRevealRole(true);
    await prefs.setDefaultDiscussionSeconds(120);
    await prefs.setHapticsEnabled(false);

    final draft = container.read(setupDraftProvider);
    expect(draft.settings.bombVictimCount, 3);
    expect(draft.settings.revealRoleOnDeath, isTrue);
    expect(draft.discussionSeconds, 120);

    final fresh = containerFor(db);
    addTearDown(fresh.dispose);
    final restored = await fresh.read(preferencesProvider.future);
    expect(restored.defaultBombVictims, 3);
    expect(restored.hapticsEnabled, isFalse);
    expect(restored.soundEnabled, isTrue);
  });
}
