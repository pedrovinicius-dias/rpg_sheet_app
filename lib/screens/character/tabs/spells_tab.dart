// lib/screens/character/tabs/spells_tab.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/stat_calculator.dart';
import '../../../models/character.dart';
import '../../../providers/character_provider.dart';
import '../../widgets/dnd_widgets.dart';

class SpellsTab extends ConsumerWidget {
  final String characterId;
  final Character character;

  const SpellsTab({
    super.key,
    required this.characterId,
    required this.character,
  });

  int _spellcastingScore() {
    switch (character.spellcastingAbility) {
      case 'intelligence':
        return character.intelligence;
      case 'wisdom':
        return character.wisdom;
      case 'charisma':
        return character.charisma;
      default:
        return 10;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spellsAsync = ref.watch(spellsProvider(characterId));
    final slotsAsync = ref.watch(spellSlotsProvider(characterId));
    final score = _spellcastingScore();
    final saveDC = character.spellcastingAbility.isNotEmpty
        ? StatCalculator.spellSaveDC(
            spellcastingAbilityScore: score, characterLevel: character.level)
        : null;
    final attackBonus = character.spellcastingAbility.isNotEmpty
        ? StatCalculator.spellAttackBonusStr(
            spellcastingAbilityScore: score, characterLevel: character.level)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Cabeçalho de conjuração ──────────────────────────────────────────
        _SpellcastingHeader(
          character: character,
          saveDC: saveDC,
          attackBonus: attackBonus,
          onChanged: (updated) => ref
              .read(characterDetailProvider(characterId).notifier)
              .atualizar(updated),
          onSave: (updated) => ref
              .read(characterDetailProvider(characterId).notifier)
              .saveAndPersist(updated),
        ),
        const SizedBox(height: 16),

        // ── Truques (círculo 0) ──────────────────────────────────────────────
        spellsAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.gold)),
          error: (e, _) => Text('Erro: $e'),
          data: (spells) => slotsAsync.when(
            loading: () => const SizedBox(),
            error: (e, _) => const SizedBox(),
            data: (slots) => Column(children: [
              // Truques
              _SpellCircleSection(
                circle: 0,
                label: 'TRUQUES',
                spells: spells.where((s) => s.circle == 0).toList(),
                slot: null,
                characterId: characterId,
              ),
              const SizedBox(height: 8),
              // Círculos 1-9
              ...List.generate(9, (i) {
                final circle = i + 1;
                final slot = slots.firstWhere((s) => s.circle == circle,
                    orElse: () =>
                        SpellSlot(characterId: characterId, circle: circle));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _SpellCircleSection(
                    circle: circle,
                    label: 'CÍRCULO $circle',
                    spells: spells.where((s) => s.circle == circle).toList(),
                    slot: slot,
                    characterId: characterId,
                  ),
                );
              }),
            ]),
          ),
        ),
        const SizedBox(height: 80),
      ]),
    );
  }
}

// ── Cabeçalho de Conjuração ───────────────────────────────────────────────

class _SpellcastingHeader extends StatelessWidget {
  final Character character;
  final int? saveDC;
  final String? attackBonus;
  final void Function(Character) onChanged;
  final Future<void> Function(Character) onSave;

  const _SpellcastingHeader({
    required this.character,
    this.saveDC,
    this.attackBonus,
    required this.onChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final abilityName = _abilityName(character.spellcastingAbility);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder)),
      child: Column(children: [
        // Classe conjuradora
        DndTextField(
          label: 'Classe Conjuradora',
          value: character.spellcastingClass,
          onChanged: (v) => onChanged(character.copyWith(spellcastingClass: v)),
        ),
        const SizedBox(height: 8),
        // Atributo
        _AbilityDropdown(
          value: character.spellcastingAbility,
          onChanged: (v) =>
              onChanged(character.copyWith(spellcastingAbility: v)),
        ),
        const SizedBox(height: 12),
        // Stats calculados
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SpellStat(
                label: 'ATRIBUTO',
                value: abilityName.isEmpty ? '—' : abilityName),
            Container(width: 1, height: 40, color: AppColors.divider),
            _SpellStat(
                label: 'CD DA MAGIA', value: saveDC != null ? '$saveDC' : '—'),
            Container(width: 1, height: 40, color: AppColors.divider),
            _SpellStat(label: 'BÔN. ATAQUE', value: attackBonus ?? '—'),
          ],
        ),
      ]),
    );
  }

  String _abilityName(String key) {
    const names = {
      'intelligence': 'Inteligência',
      'wisdom': 'Sabedoria',
      'charisma': 'Carisma',
    };
    return names[key] ?? '';
  }
}

class _SpellStat extends StatelessWidget {
  final String label;
  final String value;
  const _SpellStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(label,
          style: const TextStyle(
              color: AppColors.textHint, fontSize: 9, letterSpacing: 1)),
    ]);
  }
}

class _AbilityDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _AbilityDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [
      ('', 'Sem atributo'),
      ('intelligence', 'Inteligência'),
      ('wisdom', 'Sabedoria'),
      ('charisma', 'Carisma'),
    ];
    return DropdownButtonFormField<String>(
      initialValue: options.any((o) => o.$1 == value) ? value : '',
      decoration: const InputDecoration(labelText: 'Atributo de Conjuração'),
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold, size: 18),
      items: options
          .map((o) => DropdownMenuItem(
                value: o.$1,
                child: Text(o.$2,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13)),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

// ── Seção de Círculo ──────────────────────────────────────────────────────

class _SpellCircleSection extends ConsumerWidget {
  final int circle;
  final String label;
  final List<Spell> spells;
  final SpellSlot? slot;
  final String characterId;

  const _SpellCircleSection({
    required this.circle,
    required this.label,
    required this.spells,
    required this.slot,
    required this.characterId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(spellsProvider(characterId).notifier);
    final slotNotifier = ref.read(spellSlotsProvider(characterId).notifier);

    return Container(
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder)),
      child: Column(children: [
        // Cabeçalho do círculo
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            // Badge do círculo
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryDark,
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text('$circle',
                  style: const TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
            const Spacer(),
            // Espaços de magia (apenas para círculos 1-9)
            if (slot != null)
              _SlotTracker(
                slot: slot!,
                onChanged: (s) => slotNotifier.atualizarSlot(s),
              ),
            // Botão adicionar magia
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.gold, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => notifier.add(circle: circle),
            ),
          ]),
        ),
        // Magias
        if (spells.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12, left: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Nenhuma magia. Toque + para adicionar.',
                  style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                      fontStyle: FontStyle.italic)),
            ),
          )
        else
          ...spells.map((spell) => _SpellRow(
                spell: spell,
                characterId: characterId,
              )),
      ]),
    );
  }
}

// ── Rastreador de Espaços ──────────────────────────────────────────────────

class _SlotTracker extends StatelessWidget {
  final SpellSlot slot;
  final ValueChanged<SpellSlot> onChanged;
  const _SlotTracker({required this.slot, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      // Espaços usados (círculos)
      ...List.generate(slot.total, (i) {
        final used = i < slot.used;
        return GestureDetector(
          onTap: () => onChanged(slot.copyWith(used: used ? i : i + 1)),
          child: Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: used ? AppColors.primary : Colors.transparent,
                border: Border.all(color: AppColors.primary, width: 1.5)),
          ),
        );
      }),
      // Total de espaços (editar)
      GestureDetector(
        onTap: () => _editTotal(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('${slot.remaining}/${slot.total}',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ),
      ),
    ]);
  }

  void _editTotal(BuildContext context) {
    final ctrl = TextEditingController(text: '${slot.total}');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Espaços — Círculo ${slot.circle}',
            style: const TextStyle(color: AppColors.gold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: ctrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 24),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(labelText: 'Total de espaços'),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
              onPressed: () {
                final total = int.tryParse(ctrl.text) ?? slot.total;
                onChanged(slot.copyWith(
                    total: total.clamp(0, 9), used: slot.used.clamp(0, total)));
                Navigator.pop(context);
              },
              child: const Text('OK')),
        ],
      ),
    );
  }
}

// ── Linha de Magia ────────────────────────────────────────────────────────

class _SpellRow extends ConsumerStatefulWidget {
  final Spell spell;
  final String characterId;
  const _SpellRow({required this.spell, required this.characterId});

  @override
  ConsumerState<_SpellRow> createState() => _SpellRowState();
}

class _SpellRowState extends ConsumerState<_SpellRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(spellsProvider(widget.characterId).notifier);
    final spell = widget.spell;

    return Dismissible(
      key: Key(spell.id),
      direction: DismissDirection.endToStart,
      background: Container(
          color: AppColors.danger,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.delete, color: Colors.white)),
      onDismissed: (_) => notifier.remove(spell.id),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(children: [
              // Preparada
              if (spell.circle > 0)
                GestureDetector(
                  onTap: () => notifier
                      .updateSpell(spell.copyWith(isPrepared: !spell.isPrepared)),
                  child: Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: spell.isPrepared
                            ? AppColors.gold
                            : Colors.transparent,
                        border: Border.all(
                            color: spell.isPrepared
                                ? AppColors.gold
                                : AppColors.noProficiency,
                            width: 1.5)),
                  ),
                )
              else
                const SizedBox(width: 24),
              // Nome (editável inline)
              Expanded(
                  child: _SpellNameField(
                value: spell.name,
                onChanged: (v) => notifier.updateSpell(spell.copyWith(name: v)),
              )),
              // Expand icon
              Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.textHint, size: 18),
            ]),
          ),
        ),
        // Detalhes expandidos
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Column(children: [
              TextField(
                maxLines: 4,
                minLines: 2,
                controller: TextEditingController(text: spell.description),
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
                decoration: const InputDecoration(
                    labelText: 'Descrição da magia',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                onChanged: (v) =>
                    notifier.updateSpell(spell.copyWith(description: v)),
              ),
              const SizedBox(height: 6),
              // Imagem da magia
              _SpellImageRow(spell: spell, characterId: widget.characterId),
            ]),
          ),
        const Divider(height: 1, indent: 12, endIndent: 12),
      ]),
    );
  }
}

class _SpellNameField extends StatefulWidget {
  final String value;
  final ValueChanged<String>? onChanged;
  const _SpellNameField({required this.value, this.onChanged});

  @override
  State<_SpellNameField> createState() => _SpellNameFieldState();
}

class _SpellNameFieldState extends State<_SpellNameField> {
  late TextEditingController _ctrl;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
    _focus = FocusNode();
    _focus.addListener(() {
      if (!_focus.hasFocus) widget.onChanged?.call(_ctrl.text);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _ctrl,
        focusNode: _focus,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: const InputDecoration(
            hintText: 'Nome da magia',
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 2)),
      );
}

class _SpellImageRow extends ConsumerWidget {
  final Spell spell;
  final String characterId;
  const _SpellImageRow({required this.spell, required this.characterId});

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final saved = await ref
        .read(repositoryProvider)
        .saveImage(characterId, picked.path, 'spell_${spell.id}');
    // Limpa cache para forçar recarregamento
    imageCache.clear();
    imageCache.clearLiveImages();
    ref
        .read(spellsProvider(characterId).notifier)
        .updateSpell(spell.copyWith(imagePath: saved));
  }

  void _showImageOptions(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.file(
              File(spell.imagePath!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 280,
              key: ValueKey(spell.imagePath),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                  child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(context, ref);
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Alterar'),
              )),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ref
                      .read(spellsProvider(characterId).notifier)
                      .updateSpell(spell.copyWith(clearImage: true));
                },
                icon: const Icon(Icons.delete_outline,
                    size: 16, color: AppColors.danger),
                label: const Text('Remover',
                    style: TextStyle(color: AppColors.danger)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.danger)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasImage =
        spell.imagePath != null && File(spell.imagePath!).existsSync();

    return Row(children: [
      if (hasImage)
        GestureDetector(
          onTap: () => _showImageOptions(context, ref),
          child: Container(
            width: 80,
            height: 60,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.gold)),
            clipBehavior: Clip.antiAlias,
            child: Image.file(File(spell.imagePath!),
                fit: BoxFit.cover,
                key: ValueKey(spell.imagePath),
                gaplessPlayback: true),
          ),
        ),
      if (!hasImage)
        OutlinedButton.icon(
          onPressed: () => _pickImage(context, ref),
          icon: const Icon(Icons.add_photo_alternate, size: 16),
          label: const Text('Adicionar imagem', style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero),
        ),
    ]);
  }
}
