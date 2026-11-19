import 'package:material_ui/material_ui.dart';

import '../ui/ui.dart';
import 'l10n.dart';

/// A yes/no question in the app's glass style. Resolves to true on confirm.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
}) async {
  final c = context.mafia;
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Color.alphaBlend(c.veil(0.06), c.bg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.card),
            side: BorderSide(color: c.surfaceBorder),
          ),
          title: Text(title, style: context.type.headlineSmall),
          content: Text(body, style: context.type.bodyMedium!.copyWith(color: c.textMuted)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(foregroundColor: c.textMuted),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              key: const Key('confirmYes'),
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: c.mafiaSoft),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ) ??
      false;
}
