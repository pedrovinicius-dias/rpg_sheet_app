// lib/screens/home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../providers/character_provider.dart';
import '../models/character.dart';
import 'character_screen.dart';
import 'create_character_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersAsync = ref.watch(characterListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('D&D Sheet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAbout(context),
          ),
        ],
      ),
      body: charactersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold)),
        error: (e, _) => Center(
          child: Text('Erro: $e',
            style: const TextStyle(color: AppColors.danger))),
        data: (chars) => chars.isEmpty
            ? _EmptyState(onCreateTap: () => _createCharacter(context, ref))
            : _CharacterGrid(characters: chars),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createCharacter(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nova Ficha'),
      ),
    );
  }

  Future<void> _createCharacter(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push<Character>(
      context,
      MaterialPageRoute(builder: (_) => const CreateCharacterScreen()),
    );
    if (result != null) {
      ref.read(characterListProvider.notifier).reload();
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'D&D Sheet App',
      applicationVersion: '0.1.1',
      applicationLegalese: '© 2026 Pedro Vinícius | Uso pessoal\nD&D é marca registrada da Wizards of the Coast\nTodos os Direitos Reservados',
    );
  }
}

// ── Character Grid ────────────────────────────────────────────────────────

class _CharacterGrid extends ConsumerWidget {
  final List<Character> characters;
  const _CharacterGrid({required this.characters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: characters.length,
        itemBuilder: (_, i) => _CharacterCard(
          character: characters[i],
          onDelete: () => _confirmDelete(context, ref, characters[i]),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Character char) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Deletar ${char.name}?',
          style: const TextStyle(color: AppColors.gold)),
        content: const Text(
          'Esta ação é irreversível. Todos os dados e imagens serão apagados.',
          style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deletar')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(characterListProvider.notifier).deleteCharacter(char.id);
    }
  }
}

// ── Character Card ────────────────────────────────────────────────────────

class _CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onDelete;

  const _CharacterCard({required this.character, required this.onDelete});

  String get _initials {
    final parts = character.name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0];
    return '${parts.first[0]}${parts.last[0]}';
  }

  Color get _hpColor {
    final pct = character.maxHp > 0
        ? character.currentHp / character.maxHp : 0.0;
    if (pct > 0.5) return AppColors.hpFull;
    if (pct > 0.25) return AppColors.hpMid;
    return AppColors.hpLow;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CharacterScreen(characterId: character.id),
        ),
      ),
      onLongPress: onDelete,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          // Avatar
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: AppColors.surfaceVariant,
              child: character.avatarPath != null &&
                      File(character.avatarPath!).existsSync()
                  ? Image.file(File(character.avatarPath!),
                      fit: BoxFit.cover)
                  : Center(
                      child: Text(_initials,
                        style: const TextStyle(
                          color: AppColors.gold, fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ))),
            ),
          ),
          // Infos
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(character.name.isEmpty ? 'Sem nome' : character.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14,
                      fontWeight: FontWeight.w700,
                    )),
                  const SizedBox(height: 2),
                  Text(
                    '${character.className.isEmpty ? "—" : character.className}'
                    ' ${character.level}'
                    '${character.race.isEmpty ? "" : " · ${character.race}"}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11,
                    )),
                  const Spacer(),
                  // HP bar
                  Row(children: [
                    const Icon(Icons.favorite,
                      size: 10, color: AppColors.danger),
                    const SizedBox(width: 4),
                    Expanded(child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: character.maxHp > 0
                            ? (character.currentHp / character.maxHp).clamp(0, 1)
                            : 0,
                        backgroundColor: AppColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation(_hpColor),
                        minHeight: 4,
                      ),
                    )),
                    const SizedBox(width: 4),
                    Text('${character.currentHp}/${character.maxHp}',
                      style: TextStyle(
                        color: _hpColor, fontSize: 9,
                        fontWeight: FontWeight.w600,
                      )),
                  ]),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyState({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.menu_book_rounded,
          size: 72, color: AppColors.cardBorder),
        const SizedBox(height: 16),
        const Text('Nenhuma ficha ainda',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 18)),
        const SizedBox(height: 8),
        const Text('Crie seu primeiro personagem!',
          style: TextStyle(color: AppColors.textHint, fontSize: 14)),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onCreateTap,
          icon: const Icon(Icons.add),
          label: const Text('Criar Personagem'),
        ),
      ]),
    );
  }
}
