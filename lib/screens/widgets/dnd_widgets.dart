// lib/screens/widgets/dnd_widgets.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/stat_calculator.dart';

// ── Section Title ──────────────────────────────────────────────────────────

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionTitle(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(),
              style: const TextStyle(
                color: AppColors.gold, fontSize: 11,
                fontWeight: FontWeight.w700, letterSpacing: 1.5,
              )),
            const SizedBox(height: 4),
            Container(height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.gold, Colors.transparent]),
              )),
          ],
        )),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ]),
    );
  }
}

// ── Stat Box (atributo principal) ─────────────────────────────────────────

class StatBox extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int>? onChanged;

  const StatBox({
    super.key, required this.label, required this.value, this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final mod = StatCalculator.modifier(value);
    final modStr = mod >= 0 ? '+$mod' : '$mod';

    return GestureDetector(
      onTap: onChanged != null ? () => _showEditDialog(context) : null,
      child: Container(
        width: 80, padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(children: [
          Text(label,
            style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 1,
            )),
          const SizedBox(height: 4),
          // Modificador (grande)
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            alignment: Alignment.center,
            child: Text(modStr,
              style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 22,
                fontWeight: FontWeight.w700,
              )),
          ),
          const SizedBox(height: 4),
          // Valor base
          Container(
            width: 32, height: 20,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.cardBorder),
            ),
            alignment: Alignment.center,
            child: Text('$value',
              style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12,
              )),
          ),
        ]),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final ctrl = TextEditingController(text: '$value');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(label,
          style: const TextStyle(color: AppColors.gold)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 24),
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            labelText: 'Valor (1-30)',
            labelStyle: TextStyle(color: AppColors.textSecondary),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
              style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text) ?? value;
              onChanged?.call(v.clamp(1, 30));
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ── HP Tracker ────────────────────────────────────────────────────────────

class HpTracker extends StatefulWidget {
  final int current;
  final int max;
  final int temp;
  final ValueChanged<int>? onCurrentChanged;
  final ValueChanged<int>? onMaxChanged;
  final ValueChanged<int>? onTempChanged;

  const HpTracker({
    super.key,
    required this.current,
    required this.max,
    this.temp = 0,
    this.onCurrentChanged,
    this.onMaxChanged,
    this.onTempChanged,
  });

  @override
  State<HpTracker> createState() => _HpTrackerState();
}

class _HpTrackerState extends State<HpTracker> {
  Color get _hpColor {
    final pct = widget.max > 0 ? widget.current / widget.max : 0.0;
    if (pct > 0.5) return AppColors.hpFull;
    if (pct > 0.25) return AppColors.hpMid;
    return AppColors.hpLow;
  }

  void _editDialog(String label, int current, ValueChanged<int> onChanged) {
  final ctrl = TextEditingController(text: '$current');
  String? errorText;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setStateDialog) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(label,
          style: const TextStyle(color: AppColors.gold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            color: AppColors.textPrimary, fontSize: 28),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            errorText: errorText,
            errorStyle: const TextStyle(
              color: AppColors.danger, fontSize: 12),
          ),
          onChanged: (_) {
            // Limpa o erro enquanto o usuário digita
            if (errorText != null) {
              setStateDialog(() => errorText = null);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
              style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text) ?? current;

              // Valida: HP atual não pode ultrapassar HP máximo
              if (label == 'HP Atual' && v > widget.max) {
                setStateDialog(() => errorText =
                  'Não pode ultrapassar o HP máximo (${widget.max})');
                return;
              }

              onChanged(v.clamp(0, 9999));
              Navigator.pop(ctx);
            },
            child: const Text('OK')),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(children: [
        // Barra de HP
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: widget.max > 0
                ? (widget.current / widget.max).clamp(0.0, 1.0) : 0,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(_hpColor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          // HP Atual
          Expanded(child: GestureDetector(
            onTap: widget.onCurrentChanged != null
                ? () => _editDialog(
                    'HP Atual', widget.current, widget.onCurrentChanged!)
                : null,
            child: _hpField('HP ATUAL', widget.current, _hpColor),
          )),
          const SizedBox(width: 8),
          // HP Máximo
          Expanded(child: GestureDetector(
            onTap: widget.onMaxChanged != null
                ? () => _editDialog(
                    'HP Máximo', widget.max, widget.onMaxChanged!)
                : null,
            child: _hpField('HP MÁX', widget.max, AppColors.textSecondary),
          )),
          const SizedBox(width: 8),
          // HP Temporário
          Expanded(child: GestureDetector(
            onTap: widget.onTempChanged != null
                ? () => _editDialog(
                    'HP Temporário', widget.temp, widget.onTempChanged!)
                : null,
            child: _hpField('HP TEMP', widget.temp, AppColors.hpTemp),
          )),
        ]),
      ]),
    );
  }

  Widget _hpField(String label, int value, Color color) {
    return Column(children: [
      Text(label,
        style: const TextStyle(
          color: AppColors.textHint, fontSize: 9, letterSpacing: 1,
        )),
      const SizedBox(height: 2),
      Text('$value',
        style: TextStyle(
          color: color, fontSize: 26, fontWeight: FontWeight.w700,
        )),
      const SizedBox(height: 2),
      Text('toque para editar',
        style: const TextStyle(
          color: AppColors.textHint, fontSize: 8,
        )),
    ]);
  }
}

// ── Death Saves Widget ────────────────────────────────────────────────────

class DeathSavesWidget extends StatelessWidget {
  final int successes;
  final int failures;
  final ValueChanged<int>? onSuccessChanged;
  final ValueChanged<int>? onFailureChanged;

  const DeathSavesWidget({
    super.key,
    required this.successes,
    required this.failures,
    this.onSuccessChanged,
    this.onFailureChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SALVAGUARDA CONTRA MORTE',
            style: TextStyle(
              color: AppColors.textHint, fontSize: 9, letterSpacing: 1,
            )),
          const SizedBox(height: 6),
          _row('Sucessos', successes, AppColors.success, onSuccessChanged),
          const SizedBox(height: 4),
          _row('Falhas', failures, AppColors.danger, onFailureChanged),
        ],
      ),
    );
  }

  Widget _row(String label, int count, Color color, ValueChanged<int>? onChange) {
    return Row(children: [
      SizedBox(width: 60,
        child: Text(label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
      ...List.generate(3, (i) {
        final filled = i < count;
        return GestureDetector(
          onTap: onChange != null
              ? () => onChange(filled ? i : i + 1)
              : null,
          child: Container(
            width: 18, height: 18,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? color : Colors.transparent,
              border: Border.all(color: color, width: 1.5),
            ),
          ),
        );
      }),
    ]);
  }
}

// ── Skill Row ─────────────────────────────────────────────────────────────

class SkillRow extends StatelessWidget {
  final String skillName;
  final String skillLabel;
  final String abilityAbbr;
  final int proficiencyLevel; // 0, 1, 2
  final int value;
  final ValueChanged<int>? onProficiencyChanged;

  const SkillRow({
    super.key,
    required this.skillName,
    required this.skillLabel,
    required this.abilityAbbr,
    required this.proficiencyLevel,
    required this.value,
    this.onProficiencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final valStr = value >= 0 ? '+$value' : '$value';
    Color dotColor;
    switch (proficiencyLevel) {
      case 2: dotColor = AppColors.expertise; break;
      case 1: dotColor = AppColors.proficient; break;
      default: dotColor = AppColors.noProficiency;
    }

    return InkWell(
      onTap: onProficiencyChanged != null
          ? () => onProficiencyChanged!((proficiencyLevel + 1) % 3)
          : null,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
        child: Row(children: [
          // Círculo de proficiência
          Container(
            width: 14, height: 14,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: proficiencyLevel > 0 ? dotColor : Colors.transparent,
              border: Border.all(color: dotColor, width: 1.5),
            ),
            // Expertise: adiciona star
            child: proficiencyLevel == 2
                ? const Icon(Icons.star, size: 8, color: AppColors.background)
                : null,
          ),
          // Valor
          SizedBox(width: 28,
            child: Text(valStr,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: proficiencyLevel > 0
                    ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 13, fontWeight: FontWeight.w600,
              ))),
          const SizedBox(width: 6),
          // Nome da perícia
          Expanded(child: Text(skillLabel,
            style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 13,
            ))),
          // Atributo
          Text('($abilityAbbr)',
            style: const TextStyle(
              color: AppColors.textHint, fontSize: 10,
            )),
        ]),
      ),
    );
  }
}

// ── CombatStatBox ─────────────────────────────────────────────────────────

class CombatStatBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  final IconData? icon;

  const CombatStatBox({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.gold, size: 16),
            const SizedBox(height: 2),
          ],
          Text(value,
            style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 22,
              fontWeight: FontWeight.w700,
            )),
          const SizedBox(height: 2),
          Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textHint, fontSize: 9, letterSpacing: 0.8,
            )),
        ]),
      ),
    );
  }
}

// ── Campo de texto DnD ────────────────────────────────────────────────────

class DndTextField extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  const DndTextField({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
  });

  @override
  State<DndTextField> createState() => _DndTextFieldState();
}

class _DndTextFieldState extends State<DndTextField> {
  late TextEditingController _ctrl;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
    _focus = FocusNode();
    _focus.addListener(() {
      if (!_focus.hasFocus) {
        widget.onChanged?.call(_ctrl.text);
      }
    });
  }

  @override
  void didUpdateWidget(DndTextField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_focus.hasFocus) {
      _ctrl.text = widget.value;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      focusNode: _focus,
      maxLines: widget.maxLines,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(labelText: widget.label),
      onChanged: (v) {/* saved on focus lost */},
    );
  }
}

// ── Avatar do Personagem ──────────────────────────────────────────────────

class CharacterAvatar extends StatelessWidget {
  final String? imagePath;
  final double size;
  final VoidCallback? onTap;
  final String initials;

  const CharacterAvatar({
    super.key,
    this.imagePath,
    this.size = 80,
    this.onTap,
    this.initials = '?',
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && File(imagePath!).existsSync();

    return GestureDetector(
      onTap: hasImage
          ? () => _showImageOptions(context)
          : onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.15),
          border: Border.all(color: AppColors.gold, width: 2),
          color: AppColors.surfaceVariant,
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Image.file(File(imagePath!),
                fit: BoxFit.cover,
                key: ValueKey(imagePath),
                gaplessPlayback: true)
            : Stack(alignment: Alignment.center, children: [
                Text(initials.toUpperCase(),
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.w700,
                  )),
                if (onTap != null) Positioned(
                  bottom: 4, right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt,
                      size: 12, color: Colors.white),
                  ),
                ),
              ]),
      ),
    );
  }

  void _showImageOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Imagem em tamanho maior
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12)),
            child: Image.file(File(imagePath!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 280,
              key: ValueKey(imagePath),
            ),
          ),
          // Botões
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onTap?.call();
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Alterar'),
              )),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── NumberEditor ──────────────────────────────────────────────────────────

class NumberEditor extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int>? onChanged;
  final int min;
  final int max;

  const NumberEditor({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.min = 0,
    this.max = 9999,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label,
        style: const TextStyle(
          color: AppColors.textHint, fontSize: 9, letterSpacing: 1,
        )),
      const SizedBox(height: 4),
      Row(mainAxisSize: MainAxisSize.min, children: [
        _btn(Icons.remove, () => onChanged?.call((value - 1).clamp(min, max))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: () => _editDialog(context),
            child: Text('$value',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18, fontWeight: FontWeight.w700,
              )),
          ),
        ),
        _btn(Icons.add, () => onChanged?.call((value + 1).clamp(min, max))),
      ]),
    ]);
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: AppColors.gold, size: 18),
      ),
    );
  }

  void _editDialog(BuildContext context) {
    final ctrl = TextEditingController(text: '$value');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(label, style: const TextStyle(color: AppColors.gold)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            color: AppColors.textPrimary, fontSize: 28),
          textAlign: TextAlign.center,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
              style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text) ?? value;
              onChanged?.call(v.clamp(min, max));
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
