// lib/screens/character/tabs/sheet_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/dnd_constants.dart';
import '../../../core/utils/stat_calculator.dart';
import '../../../models/character.dart';
import '../../../providers/character_provider.dart';
import '../../widgets/dnd_widgets.dart';

class SheetTab extends ConsumerWidget {
  final Character character;
  final void Function(Character) onChanged;
  final Future<void> Function(Character) onSave;

  const SheetTab({
    super.key,
    required this.character,
    required this.onChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header: identidade ──────────────────────────────────────────────
        _HeaderSection(character: character, onChanged: onChanged, ref: ref),
        const SizedBox(height: 16),

        // ── Atributos ───────────────────────────────────────────────────────
        const SectionTitle('Atributos'),
        _AbilityScoresSection(character: character, onChanged: onChanged),
        const SizedBox(height: 4),

        // ── Combate ─────────────────────────────────────────────────────────
        const SectionTitle('Combate'),
        _CombatSection(character: character, onChanged: onChanged),
        const SizedBox(height: 4),

        // ── Salvaguardas ────────────────────────────────────────────────────
        const SectionTitle('Salvaguardas'),
        _SavingThrowsSection(character: character, onChanged: onChanged),
        const SizedBox(height: 4),

        // ── Perícias ────────────────────────────────────────────────────────
        SectionTitle('Perícias',
            trailing: Text(
                'Prof. +${StatCalculator.proficiencyBonus(character.level)}',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ))),
        _SkillsSection(character: character, onChanged: onChanged),
        const SizedBox(height: 4),

        // ── Ataques ─────────────────────────────────────────────────────────
        _AttacksSection(character: character),
        const SizedBox(height: 4),

        // ── Equipamentos & Moedas ───────────────────────────────────────────
        const SectionTitle('Equipamentos & Moedas'),
        _EquipmentSection(character: character, onChanged: onChanged),
        const SizedBox(height: 4),

        // ── Personalidade ────────────────────────────────────────────────────
        const SectionTitle('Personalidade'),
        _PersonalitySection(character: character, onChanged: onChanged),
        const SizedBox(height: 4),

        // ── Proficiências & Idiomas ──────────────────────────────────────────
        const SectionTitle('Proficiências & Idiomas'),
        DndTextField(
          label: 'Idiomas, armas, armaduras, ferramentas...',
          value: character.otherProficiencies,
          maxLines: 4,
          onChanged: (v) =>
              onChanged(character.copyWith(otherProficiencies: v)),
        ),
        const SizedBox(height: 4),

        // ── Características & Talentos ───────────────────────────────────────
        const SectionTitle('Características & Talentos'),
        DndTextField(
          label: 'Habilidades de classe, raça, antecedente...',
          value: character.featuresAndTraits,
          maxLines: 8,
          onChanged: (v) => onChanged(character.copyWith(featuresAndTraits: v)),
        ),
        const SizedBox(height: 80),
      ]),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  final Character character;
  final void Function(Character) onChanged;
  final WidgetRef ref;
  const _HeaderSection(
      {required this.character, required this.onChanged, required this.ref});

  Future<void> _pickAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final saved = await ref
        .read(repositoryProvider)
        .saveImage(character.id, picked.path, 'avatar');
    onChanged(character.copyWith(avatarPath: saved));
  }

  @override
  Widget build(BuildContext context) {
    final initials = character.name.trim().isEmpty
        ? '?'
        : character.name.trim().split(' ').map((w) => w[0]).take(2).join();

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Avatar
      CharacterAvatar(
        imagePath: character.avatarPath,
        size: 88,
        initials: initials,
        onTap: () => _pickAvatar(context),
      ),
      const SizedBox(width: 12),
      // Campos de identidade
      Expanded(
          child: Column(children: [
        DndTextField(
          label: 'Nome do Personagem',
          value: character.name,
          onChanged: (v) => onChanged(character.copyWith(name: v)),
        ),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
              child: _DropdownField(
            label: 'Classe',
            value: character.className,
            items: DnDConstants.classes,
            onChanged: (v) => onChanged(character.copyWith(
              className: v,
              hitDie: DnDConstants.classHitDie[v] ?? character.hitDie,
            )),
          )),
          const SizedBox(width: 6),
          SizedBox(
              width: 64,
              child: DndTextField(
                label: 'Nível',
                value: '${character.level}',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) => onChanged(character.copyWith(
                    level: int.tryParse(v) ?? character.level)),
              )),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
              child: _DropdownField(
            label: 'Raça',
            value: character.race,
            items: DnDConstants.races,
            onChanged: (v) => onChanged(character.copyWith(race: v)),
          )),
          const SizedBox(width: 6),
          Expanded(
              child: _DropdownField(
            label: 'Antecedente',
            value: character.background,
            items: DnDConstants.backgrounds,
            onChanged: (v) => onChanged(character.copyWith(background: v)),
          )),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
              child: _DropdownField(
            label: 'Alinhamento',
            value: character.alignment,
            items: DnDConstants.alignments,
            onChanged: (v) => onChanged(character.copyWith(alignment: v)),
          )),
          const SizedBox(width: 6),
          Expanded(
              child: DndTextField(
            label: 'Jogador',
            value: character.playerName,
            onChanged: (v) => onChanged(character.copyWith(playerName: v)),
          )),
        ]),
        const SizedBox(height: 6),
        DndTextField(
          label: 'Pontos de Experiência (XP)',
          value: '${character.experience}',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (v) =>
              onChanged(character.copyWith(experience: int.tryParse(v) ?? 0)),
        ),
      ])),
    ]);
  }
}

// ── Atributos ─────────────────────────────────────────────────────────────

class _AbilityScoresSection extends StatelessWidget {
  final Character character;
  final void Function(Character) onChanged;
  const _AbilityScoresSection(
      {required this.character, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final attrs = [
      ('FOR', character.strength, (v) => character.copyWith(strength: v)),
      ('DES', character.dexterity, (v) => character.copyWith(dexterity: v)),
      (
        'CON',
        character.constitution,
        (v) => character.copyWith(constitution: v)
      ),
      (
        'INT',
        character.intelligence,
        (v) => character.copyWith(intelligence: v)
      ),
      ('SAB', character.wisdom, (v) => character.copyWith(wisdom: v)),
      ('CAR', character.charisma, (v) => character.copyWith(charisma: v)),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: attrs
          .map((a) => StatBox(
                label: a.$1,
                value: a.$2,
                onChanged: (v) => onChanged(a.$3(v)),
              ))
          .toList(),
    );
  }
}

// ── Combate ───────────────────────────────────────────────────────────────

class _CombatSection extends StatelessWidget {
  final Character character;
  final void Function(Character) onChanged;
  const _CombatSection({required this.character, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final initStr = StatCalculator.initiativeStr(character.dexterity,
        bonus: character.initiativeBonus);
    final profBonus = StatCalculator.proficiencyBonus(character.level);

    return Column(children: [
      // Row: CA, Iniciativa, Deslocamento, Proficiência, Inspiração
      Row(children: [
        Expanded(
            child: CombatStatBox(
          label: 'CA',
          value: '${character.armorClass}',
          icon: Icons.shield_outlined,
          onTap: () => _editInt(
              context,
              'Classe de Armadura',
              character.armorClass,
              1,
              30,
              (v) => onChanged(character.copyWith(armorClass: v))),
        )),
        const SizedBox(width: 8),
        Expanded(
            child: CombatStatBox(
          label: 'INICIATIVA',
          value: initStr,
          icon: Icons.flash_on_rounded,
          onTap: () => _editInt(
              context,
              'Bônus Extra de Iniciativa',
              character.initiativeBonus,
              -10,
              20,
              (v) => onChanged(character.copyWith(initiativeBonus: v))),
        )),
        const SizedBox(width: 8),
        Expanded(
            child: CombatStatBox(
          label: 'DESLOCAMENTO',
          value: '${character.speed}m',
          icon: Icons.directions_run,
          onTap: () => _editInt(
              context,
              'Deslocamento (metros)',
              character.speed,
              0,
              60,
              (v) => onChanged(character.copyWith(speed: v))),
        )),
        const SizedBox(width: 8),
        Expanded(
            child: CombatStatBox(
          label: 'PROF.',
          value: '+$profBonus',
          icon: Icons.stars_rounded,
        )),
        const SizedBox(width: 8),
        Expanded(
            child: GestureDetector(
          onTap: () => onChanged(
              character.copyWith(inspiration: !character.inspiration)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: character.inspiration
                  ? AppColors.gold.withOpacity(0.2)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: character.inspiration
                      ? AppColors.gold
                      : AppColors.cardBorder),
            ),
            child: Column(children: [
              Icon(character.inspiration ? Icons.star : Icons.star_border,
                  color: AppColors.gold, size: 16),
              const SizedBox(height: 2),
              const Text('INSPI.',
                  style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 9,
                      letterSpacing: 0.8)),
            ]),
          ),
        )),
      ]),
      const SizedBox(height: 10),

      // HP
      HpTracker(
        current: character.currentHp,
        max: character.maxHp,
        temp: character.tempHp,
        onCurrentChanged: (v) => onChanged(character.copyWith(currentHp: v)),
        onMaxChanged: (v) => onChanged(character.copyWith(maxHp: v)),
        onTempChanged: (v) => onChanged(character.copyWith(tempHp: v)),
      ),
      const SizedBox(height: 10),

      // Dado de vida & salvaguarda contra morte
      Row(children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder)),
          child: Column(children: [
            const Text('DADO DE VIDA',
                style: TextStyle(
                    color: AppColors.textHint, fontSize: 9, letterSpacing: 1)),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${character.level - character.hitDiceUsed}',
                  style: TextStyle(
                      color: character.hitDiceUsed >= character.level
                          ? AppColors.danger
                          : AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              Text(character.hitDie,
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            // Botões gastar / recuperar
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Gastar 1 dado
              InkWell(
                onTap: character.hitDiceUsed < character.level
                    ? () => onChanged(character.copyWith(
                        hitDiceUsed: character.hitDiceUsed + 1))
                    : null,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: character.hitDiceUsed < character.level
                              ? AppColors.danger
                              : AppColors.cardBorder)),
                  child: Text('−1',
                      style: TextStyle(
                          color: character.hitDiceUsed < character.level
                              ? AppColors.danger
                              : AppColors.textHint,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 6),
              // Recuperar 1 dado
              InkWell(
                onTap: character.hitDiceUsed > 0
                    ? () => onChanged(character.copyWith(
                        hitDiceUsed: character.hitDiceUsed - 1))
                    : null,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: character.hitDiceUsed > 0
                              ? AppColors.success
                              : AppColors.cardBorder)),
                  child: Text('+1',
                      style: TextStyle(
                          color: character.hitDiceUsed > 0
                              ? AppColors.success
                              : AppColors.textHint,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
            const SizedBox(height: 4),
            Text('${character.hitDiceUsed}/${character.level} gastos',
                style:
                    const TextStyle(color: AppColors.textHint, fontSize: 10)),
          ]),
        )),
        const SizedBox(width: 8),
        Expanded(
            child: DeathSavesWidget(
          successes: character.deathSaveSuccesses,
          failures: character.deathSaveFailures,
          onSuccessChanged: (v) =>
              onChanged(character.copyWith(deathSaveSuccesses: v)),
          onFailureChanged: (v) =>
              onChanged(character.copyWith(deathSaveFailures: v)),
        )),
      ]),
    ]);
  }

  void _editInt(BuildContext ctx, String label, int current, int min, int max,
      void Function(int) cb) {
    final ctrl = TextEditingController(text: '$current');
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(label, style: const TextStyle(color: AppColors.gold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'-?\d*'))
          ],
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 28),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
              onPressed: () {
                final v = int.tryParse(ctrl.text) ?? current;
                cb(v.clamp(min, max));
                Navigator.pop(ctx);
              },
              child: const Text('OK')),
        ],
      ),
    );
  }
}

// ── Salvaguardas ──────────────────────────────────────────────────────────

class _SavingThrowsSection extends StatelessWidget {
  final Character character;
  final void Function(Character) onChanged;
  const _SavingThrowsSection(
      {required this.character, required this.onChanged});

  int _score(String ability) {
    switch (ability) {
      case 'strength':
        return character.strength;
      case 'dexterity':
        return character.dexterity;
      case 'constitution':
        return character.constitution;
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder)),
      child: Column(
        children: DnDConstants.abilities.map((ability) {
          final isProficient =
              character.savingThrowProficiencies[ability] ?? false;
          final val = StatCalculator.savingThrowValue(
            abilityScore: _score(ability),
            isProficient: isProficient,
            characterLevel: character.level,
          );
          final valStr = val >= 0 ? '+$val' : '$val';
          return InkWell(
            onTap: () {
              final updated =
                  Map<String, bool>.from(character.savingThrowProficiencies);
              updated[ability] = !isProficient;
              onChanged(character.copyWith(savingThrowProficiencies: updated));
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
              child: Row(children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isProficient ? AppColors.gold : Colors.transparent,
                    border: Border.all(
                        color: isProficient
                            ? AppColors.gold
                            : AppColors.noProficiency,
                        width: 1.5),
                  ),
                ),
                SizedBox(
                    width: 28,
                    child: Text(valStr,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: isProficient
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ))),
                const SizedBox(width: 8),
                Text(DnDConstants.abilityNames[ability]!,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Perícias ──────────────────────────────────────────────────────────────

class _SkillsSection extends StatelessWidget {
  final Character character;
  final void Function(Character) onChanged;
  const _SkillsSection({required this.character, required this.onChanged});

  int _score(String ability) {
    switch (ability) {
      case 'strength':
        return character.strength;
      case 'dexterity':
        return character.dexterity;
      case 'constitution':
        return character.constitution;
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
  Widget build(BuildContext context) {
    final passivePerc = StatCalculator.passivePerception(
      wisdomScore: character.wisdom,
      perceptionProficiency: character.skillProficiencies['perception'] ?? 0,
      characterLevel: character.level,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder)),
      child: Column(children: [
        // Percepção Passiva
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            const Icon(Icons.visibility, color: AppColors.gold, size: 14),
            const SizedBox(width: 6),
            const Text('Percepção Passiva',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const Spacer(),
            Text('$passivePerc',
                style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
        const Divider(height: 1),
        const SizedBox(height: 4),
        // 18 Perícias
        ...DnDConstants.skillOrder.map((skill) {
          final data = DnDConstants.skills[skill]!;
          final abilityKey = data[1];
          final score = _score(abilityKey);
          final profLevel = character.skillProficiencies[skill] ?? 0;
          final val = StatCalculator.skillValue(
            abilityScore: score,
            proficiencyLevel: profLevel,
            characterLevel: character.level,
          );
          final abbr = DnDConstants.abilityAbbr[abilityKey] ?? '';
          return SkillRow(
            skillName: skill,
            skillLabel: data[0],
            abilityAbbr: abbr,
            proficiencyLevel: profLevel,
            value: val,
            onProficiencyChanged: (level) {
              final updated =
                  Map<String, int>.from(character.skillProficiencies);
              updated[skill] = level;
              onChanged(character.copyWith(skillProficiencies: updated));
            },
          );
        }),
      ]),
    );
  }
}

// ── Ataques ───────────────────────────────────────────────────────────────

class _AttacksSection extends ConsumerWidget {
  final Character character;
  const _AttacksSection({required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attacksAsync = ref.watch(attacksProvider(character.id));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionTitle('Ataques & Conjuração',
          trailing: IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.gold, size: 22),
            onPressed: () =>
                ref.read(attacksProvider(character.id).notifier).add(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          )),
      Container(
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder)),
        child: Column(children: [
          // Cabeçalho
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(children: [
              Expanded(
                  flex: 3,
                  child: Text('NOME',
                      style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 9,
                          letterSpacing: 1))),
              Expanded(
                  flex: 2,
                  child: Text('BÔN. ATAQUE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 9,
                          letterSpacing: 1))),
              Expanded(
                  flex: 3,
                  child: Text('DANO/TIPO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 9,
                          letterSpacing: 1))),
              SizedBox(width: 24),
            ]),
          ),
          const Divider(height: 1),
          attacksAsync.when(
            loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.gold, strokeWidth: 2))),
            error: (e, _) => Text('Erro: $e'),
            data: (attacks) => attacks.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                        child: Text('Nenhum ataque. Toque + para adicionar.',
                            style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12,
                                fontStyle: FontStyle.italic))))
                : Column(
                    children: attacks
                        .map((attack) => _AttackRow(
                            attack: attack, characterId: character.id))
                        .toList()),
          ),
        ]),
      ),
    ]);
  }
}

class _AttackRow extends ConsumerWidget {
  final Attack attack;
  final String characterId;
  const _AttackRow({required this.attack, required this.characterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(attacksProvider(characterId).notifier);
    return Dismissible(
      key: Key(attack.id),
      direction: DismissDirection.endToStart,
      background: Container(
          color: AppColors.danger,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.delete, color: Colors.white)),
      onDismissed: (_) => notifier.remove(attack.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(children: [
          Expanded(
              flex: 3,
              child: _InlineTextField(
                value: attack.name,
                hint: 'Espada Longa',
                onChanged: (v) => notifier.atualizar(attack.copyWith(name: v)),
              )),
          Expanded(
              flex: 2,
              child: _InlineTextField(
                value: attack.attackBonus,
                hint: '+5',
                textAlign: TextAlign.center,
                onChanged: (v) =>
                    notifier.atualizar(attack.copyWith(attackBonus: v)),
              )),
          Expanded(
              flex: 3,
              child: _InlineTextField(
                value: attack.damageType,
                hint: '1d8+3 cortante',
                textAlign: TextAlign.center,
                onChanged: (v) =>
                    notifier.atualizar(attack.copyWith(damageType: v)),
              )),
          SizedBox(
              width: 24,
              child: IconButton(
                icon: const Icon(Icons.close,
                    size: 16, color: AppColors.textHint),
                padding: EdgeInsets.zero,
                onPressed: () => notifier.remove(attack.id),
              )),
        ]),
      ),
    );
  }
}

class _InlineTextField extends StatefulWidget {
  final String value;
  final String hint;
  final TextAlign textAlign;
  final ValueChanged<String>? onChanged;

  const _InlineTextField({
    required this.value,
    this.hint = '',
    this.textAlign = TextAlign.start,
    this.onChanged,
  });

  @override
  State<_InlineTextField> createState() => _InlineTextFieldState();
}

class _InlineTextFieldState extends State<_InlineTextField> {
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
  void didUpdateWidget(_InlineTextField old) {
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
  Widget build(BuildContext context) => TextField(
        controller: _ctrl,
        focusNode: _focus,
        textAlign: widget.textAlign,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 12),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),
      );
}

// ── Equipamentos ──────────────────────────────────────────────────────────

class _EquipmentSection extends StatelessWidget {
  final Character character;
  final void Function(Character) onChanged;
  const _EquipmentSection({required this.character, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Moedas
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _CurrencyField('PC', character.copper,
                (v) => onChanged(character.copyWith(copper: v))),
            _CurrencyField('PP', character.silver,
                (v) => onChanged(character.copyWith(silver: v))),
            _CurrencyField('PE', character.electrum,
                (v) => onChanged(character.copyWith(electrum: v))),
            _CurrencyField('PO', character.gold,
                (v) => onChanged(character.copyWith(gold: v))),
            _CurrencyField('PL', character.platinum,
                (v) => onChanged(character.copyWith(platinum: v))),
          ],
        ),
      ),
      const SizedBox(height: 8),
      // Lista de equipamentos
      DndTextField(
        label: 'Itens e equipamentos',
        value: character.equipment,
        maxLines: 6,
        onChanged: (v) => onChanged(character.copyWith(equipment: v)),
      ),
    ]);
  }
}

class _CurrencyField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const _CurrencyField(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final ctrl = TextEditingController(text: '$value');
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: Text(label, style: const TextStyle(color: AppColors.gold)),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 24),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar',
                      style: TextStyle(color: AppColors.textSecondary))),
              ElevatedButton(
                  onPressed: () {
                    onChanged(int.tryParse(ctrl.text) ?? value);
                    Navigator.pop(context);
                  },
                  child: const Text('OK')),
            ],
          ),
        );
      },
      child: Column(children: [
        Text('$value',
            style: const TextStyle(
                color: AppColors.gold,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textHint, fontSize: 9, letterSpacing: 1)),
      ]),
    );
  }
}

// ── Personalidade ─────────────────────────────────────────────────────────

class _PersonalitySection extends StatelessWidget {
  final Character character;
  final void Function(Character) onChanged;
  const _PersonalitySection({required this.character, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      DndTextField(
        label: 'Traços de Personalidade',
        value: character.personalityTraits,
        maxLines: 3,
        onChanged: (v) => onChanged(character.copyWith(personalityTraits: v)),
      ),
      const SizedBox(height: 8),
      DndTextField(
        label: 'Ideais',
        value: character.ideals,
        maxLines: 2,
        onChanged: (v) => onChanged(character.copyWith(ideals: v)),
      ),
      const SizedBox(height: 8),
      DndTextField(
        label: 'Vínculos',
        value: character.bonds,
        maxLines: 2,
        onChanged: (v) => onChanged(character.copyWith(bonds: v)),
      ),
      const SizedBox(height: 8),
      DndTextField(
        label: 'Fraquezas',
        value: character.flaws,
        maxLines: 2,
        onChanged: (v) => onChanged(character.copyWith(flaws: v)),
      ),
    ]);
  }
}

// ── Dropdown Field ────────────────────────────────────────────────────────

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentValue = items.contains(value) ? value : null;
    return DropdownButtonFormField<String>(
      initialValue: currentValue,
      hint: Text(label,
          style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
      decoration: InputDecoration(labelText: label),
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold, size: 18),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item,
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
