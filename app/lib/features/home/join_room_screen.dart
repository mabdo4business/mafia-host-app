import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../ui/ui.dart';

/// Players' phones mode: enter the host's room code (or scan it).
/// Joining needs the online rooms of a later phase; until then the screen
/// says so instead of pretending to connect.
class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  static const codeLength = 6;

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _code = TextEditingController();

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _notYet() => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(context.l10n.joinNotYet)));

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final code = _code.text;
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
              const SizedBox(width: Space.md),
              Expanded(child: Text(l.joinTitle, style: context.type.headlineSmall)),
            ],
          ),
          const SizedBox(height: Space.xxl),
          Text(l.joinIntro, style: context.type.bodyMedium!.copyWith(color: c.textMuted)),
          const SizedBox(height: Space.xl),
          // One field, drawn as six boxes; the code is Latin letters and
          // digits, so it reads left-to-right in both languages.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [
                    for (var i = 0; i < JoinRoomScreen.codeLength; i++) ...[
                      if (i > 0) const SizedBox(width: Space.sm),
                      Expanded(
                        child: AnimatedContainer(
                          duration: Motion.fast,
                          height: 68,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(Radii.iconBoxLg),
                            border: Border.all(
                              color: i == code.length ? c.civilian : c.surfaceBorder,
                              width: i == code.length ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            i < code.length ? code[i] : '',
                            style: context.type.headlineMedium,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Positioned.fill(
                  child: Opacity(
                    opacity: 0,
                    child: TextField(
                      key: const Key('roomCode'),
                      controller: _code,
                      autofocus: true,
                      maxLength: JoinRoomScreen.codeLength,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                        TextInputFormatter.withFunction(
                          (_, v) => v.copyWith(text: v.text.toUpperCase()),
                        ),
                      ],
                      decoration: const InputDecoration(counterText: ''),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
          Text(l.joinCodeHint, style: context.type.bodySmall),
          const SizedBox(height: Space.xxl),
          Center(
            child: GlassPillButton(label: l.joinScanQr, glyph: MafiaGlyphs.qr, onPressed: _notYet),
          ),
        ],
      ),
      bottom: PrimaryActionButton(
        key: const Key('joinRoom'),
        label: l.joinCta,
        trailing: MafiaGlyphs.arrow,
        onPressed: code.length >= 4 ? _notYet : null,
      ),
    );
  }
}
