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
    await prefs.setDefaultRevealRole(true);
    await prefs.setHapticsEnabled(false);

    final draft = container.read(setupDraftProvider);
    expect(draft.settings.revealRoleOnDeath, isTrue);

    final fresh = containerFor(db);
    addTearDown(fresh.dispose);
    final restored = await fresh.read(preferencesProvider.future);
    expect(restored.defaultRevealRole, isTrue);
    expect(restored.hapticsEnabled, isFalse);
    expect(restored.soundEnabled, isTrue);
  });
}
