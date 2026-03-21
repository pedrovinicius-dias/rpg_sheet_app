// lib/screens/create_character_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/dnd_constants.dart';
import '../models/character.dart';
import '../providers/character_provider.dart';

class CreateCharacterScreen extends ConsumerStatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  ConsumerState<CreateCharacterScreen> createState() =>
      _CreateCharacterScreenState();
}

class _CreateCharacterScreenState
    extends ConsumerState<CreateCharacterScreen> {
  final _nameCtrl = TextEditingController();
  final _playerCtrl = TextEditingController();
  String _race = '';
  String _class = '';
  String _background = '';
  String _alignment = '';
  int _level = 1;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _playerCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Dê um nome ao seu personagem!')));
      return;
    }
    setState(() => _loading = true);
    try {
      final now = DateTime.now();
      final hitDie = DnDConstants.classHitDie[_class] ?? 'd8';
      final baseChar = Character(
        id: '', // será substituído no repository
        name: _nameCtrl.text.trim(),
        playerName: _playerCtrl.text.trim(),
        race: _race,
        className: _class,
        level: _level,
        background: _background,
        alignment: _alignment,
        hitDie: hitDie,
        maxHp: 10,
        currentHp: 10,
        createdAt: now,
        updatedAt: now,
      );
      // Cria via notifier (que usa o repository internamente)
      final created = await ref
          .read(characterListProvider.notifier)
          .createCharacter(name: baseChar.name);

      // Atualiza com os demais campos
      final withDetails = created.copyWith(
        playerName: _playerCtrl.text.trim(),
        race: _race,
        className: _class,
        level: _level,
        background: _background,
        alignment: _alignment,
        hitDie: hitDie,
      );
      await ref.read(repositoryProvider).save(withDetails);

      if (mounted) Navigator.pop(context, withDetails);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar personagem: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Personagem')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Título decorativo
          const Text('Crie Seu Herói',
            style: TextStyle(
              color: AppColors.gold, fontSize: 26,
              fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text(
            'Você pode alterar todos esses dados depois, na ficha completa.',
            style: TextStyle(color: AppColors.textHint, fontSize: 13)),
          const SizedBox(height: 24),

          // ── Identidade ─────────────────────────────────────────────────────
          _sectionTitle('Identidade'),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Nome do Personagem *',
              prefixIcon: Icon(Icons.person, color: AppColors.gold, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _playerCtrl,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Nome do Jogador',
              prefixIcon: Icon(Icons.sports_esports,
                color: AppColors.gold, size: 18),
            ),
          ),
          const SizedBox(height: 20),

          // ── Classe & Raça ──────────────────────────────────────────────────
          _sectionTitle('Classe & Raça'),
          _dropdown('Classe', DnDConstants.classes, _class,
            (v) => setState(() => _class = v)),
          const SizedBox(height: 12),
          _dropdown('Raça', DnDConstants.races, _race,
            (v) => setState(() => _race = v)),
          const SizedBox(height: 12),
          // Nível
          Row(children: [
            const Text('Nível inicial:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                color: AppColors.gold),
              onPressed: _level > 1
                  ? () => setState(() => _level--)
                  : null,
            ),
            Text('$_level',
              style: const TextStyle(
                color: AppColors.gold, fontSize: 22,
                fontWeight: FontWeight.w700)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.gold),
              onPressed: _level < 20
                  ? () => setState(() => _level++)
                  : null,
            ),
          ]),
          const SizedBox(height: 20),

          // ── Antecedente & Alinhamento ──────────────────────────────────────
          _sectionTitle('Antecedente & Alinhamento'),
          _dropdown('Antecedente', DnDConstants.backgrounds, _background,
            (v) => setState(() => _background = v)),
          const SizedBox(height: 12),
          _dropdown('Alinhamento', DnDConstants.alignments, _alignment,
            (v) => setState(() => _alignment = v)),
          const SizedBox(height: 40),

          // Classe do dado de vida (informativo)
          if (_class.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder)),
              child: Row(children: [
                const Icon(Icons.casino, color: AppColors.gold, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Dado de Vida: ${DnDConstants.classHitDie[_class] ?? "d8"}',
                  style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
              ]),
            ),
          const SizedBox(height: 24),

          // ── Botão criar ────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _create,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
              child: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                  : const Text('⚔  Criar Personagem',
                      style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.gold, fontSize: 11,
        fontWeight: FontWeight.w700, letterSpacing: 1.5)),
  );

  Widget _dropdown(String label, List<String> items, String current,
      ValueChanged<String> onChanged) {
    final val = items.contains(current) ? current : null;
    return DropdownButtonFormField<String>(
      initialValue: val,
      hint: Text(label,
        style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
      decoration: InputDecoration(labelText: label),
      dropdownColor: AppColors.surface,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold, size: 18),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
      )).toList(),
      onChanged: (v) { if (v != null) onChanged(v); },
    );
  }
}
