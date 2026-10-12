import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../extensions/size_extensions.dart';
import '../../../../theme/apptheme.dart';
import '../../../collectitive/widgets/clay_button.dart';
import '../../../collectitive/widgets/glass_card.dart';
import '../../bloc/bloc.dart';
import '../../model/problem.dart';
import 'painters/picnic_painters.dart';
import 'parts/pick_tile.dart';

const _juiceNames = {'O': 'Olmali sharbat', 'A': 'Apelsinli sharbat'};
const _samsaNames = {'G': 'Go‘shtli somsa', 'K': 'Kartoshkali somsa'};

/// Problem 9 — picnic. Put a juice and a samsa on the picnic cloth and a code
/// ticket (OG, AK, …) is printed. Older kids can also type the code directly
/// in the "code machine", just like in the worksheet.
class PicnicGame extends StatefulWidget {
  final Problem problem;

  const PicnicGame({super.key, required this.problem});

  @override
  State<PicnicGame> createState() => _PicnicGameState();
}

class _PicnicGameState extends State<PicnicGame> {
  String? _juice;
  String? _samsa;
  final TextEditingController _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _add(String j, String s) {
    context.read<ProblemBloc>().add(ProblemVariantAdded(Variant(
          key: '$j$s',
          label: '$j$s — ${_juiceNames[j]!.split(' ').first.toLowerCase()} sharbat, '
              '${_samsaNames[s]!.split(' ').first.toLowerCase()} somsa',
          emojis: const ['🧃', '🥟'],
        )));
  }

  void onTapPut() {
    _add(_juice!, _samsa!);
    setState(() {
      _juice = null;
      _samsa = null;
    });
  }

  void onSubmitCode() {
    final code = _code.text.trim().toUpperCase();
    final ok = code.length == 2 && _juiceNames.containsKey(code[0]) && _samsaNames.containsKey(code[1]);
    if (!ok) {
      context.read<ProblemBloc>().add(const ProblemHintShown(
            'Kod 2 harfdan iborat: avval sharbat (O yoki A), keyin somsa (G yoki K). Masalan: OG',
          ));
      return;
    }
    _add(code[0], code[1]);
    _code.clear();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.problem.color;
    final found = context.select<ProblemBloc, List<Variant>>((b) => b.state.found);
    Widget juice(String l, double s) => CustomPaint(
          size: Size(s * 0.7, s),
          painter: JuicePainter(
            color: l == 'O' ? theme.greenObj : theme.orange,
            fruit: l == 'O' ? theme.red : theme.secondary,
            letter: l,
          ),
        );
    Widget samsa(String l, double s) => CustomPaint(
          size: Size(s, s * 0.85),
          painter: SamsaPainter(tag: l == 'G' ? theme.red : theme.wood, letter: l),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ShelfSection(
              title: 'Sharbatlar',
              emoji: '🧃',
              color: theme.greenObj,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final l in _juiceNames.keys) ...[
                    PickTile(
                      picture: juice(l, 70),
                      label: _juiceNames[l]!,
                      color: theme.greenObj,
                      selected: _juice == l,
                      onTap: () => setState(() => _juice = _juice == l ? null : l),
                    ),
                    10.width,
                  ],
                ],
              ),
            ),
            ShelfSection(
              title: 'Somsalar',
              emoji: '🥟',
              color: color,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final l in _samsaNames.keys) ...[
                    PickTile(
                      picture: samsa(l, 70),
                      label: _samsaNames[l]!,
                      color: color,
                      selected: _samsa == l,
                      onTap: () => setState(() => _samsa = _samsa == l ? null : l),
                    ),
                    10.width,
                  ],
                ],
              ),
            ),
          ],
        ),
        16.height,
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Picnic cloth.
            Container(
              width: 260,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: 18.circular,
                border: Border.all(color: theme.white, width: 4),
                boxShadow: theme.lifted(theme.red, depth: 0.5),
              ),
              child: ClipRRect(
                borderRadius: 14.circular,
                child: CustomPaint(
                  painter: _GinghamPainter(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _juice == null ? _ghost('Sharbat') : juice(_juice!, 90),
                      _samsa == null ? _ghost('Somsa') : samsa(_samsa!, 90),
                    ],
                  ),
                ),
              ),
            ),
            ClayButton(
              color: color,
              onTap: _juice != null && _samsa != null ? onTapPut : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.confirmation_number_rounded),
                  8.width,
                  Text(_juice != null && _samsa != null ? 'Kod: $_juice$_samsa' : 'Kod chiqarish'),
                ],
              ),
            ),
            _CodeMachine(controller: _code, color: color, onSubmit: onSubmitCode),
          ],
        ),
        16.height,
        ShelfSection(
          title: 'Kod chiptalari',
          emoji: '🎟️',
          color: theme.violet,
          child: found.isEmpty
              ? Text('Hali chipta yo‘q', style: theme.body(15, color: theme.textHint))
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [for (final v in found) _Ticket(code: v.key, color: color)],
                ),
        ),
      ],
    );
  }

  Widget _ghost(String text) => Container(
        width: 80,
        height: 90,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.white.withValues(alpha: 0.7),
          borderRadius: 14.circular,
          border: Border.all(color: theme.slotBorder, width: 2),
        ),
        child: Text(text, style: theme.body(13, color: theme.textHint)),
      );
}

/// Red-white checked picnic cloth.
class _GinghamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.white);
    final p = Paint()..color = theme.red.withValues(alpha: 0.28);
    const step = 20.0;
    for (double x = 0; x < size.width; x += step * 2) {
      canvas.drawRect(Rect.fromLTWH(x, 0, step, size.height), p);
    }
    for (double y = 0; y < size.height; y += step * 2) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, step), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Two-letter code input: "O G ↵".
class _CodeMachine extends StatelessWidget {
  final TextEditingController controller;
  final Color color;
  final VoidCallback onSubmit;

  const _CodeMachine({required this.controller, required this.color, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 12.all,
      decoration: BoxDecoration(
        color: theme.text,
        borderRadius: 20.circular,
        boxShadow: theme.lifted(theme.text, depth: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Kod mashinasi', style: theme.body(13, color: theme.white)),
          6.height,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 90,
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[oagkOAGK]')),
                    LengthLimitingTextInputFormatter(2),
                  ],
                  onSubmitted: (_) => onSubmit(),
                  style: theme.display(28, color: theme.star),
                  decoration: InputDecoration(
                    hintText: 'OG',
                    hintStyle: theme.display(28, color: theme.white.withValues(alpha: 0.25)),
                    isDense: true,
                    filled: true,
                    fillColor: theme.black.withValues(alpha: 0.35),
                    border: OutlineInputBorder(borderRadius: 12.circular, borderSide: BorderSide.none),
                  ),
                ),
              ),
              8.width,
              ClayIconButton(icon: Icons.keyboard_return_rounded, color: color, onTap: onSubmit),
            ],
          ),
        ],
      ),
    );
  }
}

class _Ticket extends StatelessWidget {
  final String code;
  final Color color;

  const _Ticket({required this.code, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Transform.translate(offset: Offset(0, 20 * (1 - v)), child: Opacity(opacity: v.clamp(0, 1), child: child)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: theme.paper,
          borderRadius: 10.circular,
          border: Border.all(color: color, width: 2.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Emoji('🎟️', size: 20),
            8.width,
            Text(code, style: theme.display(26, color: color)),
          ],
        ),
      ),
    );
  }
}
