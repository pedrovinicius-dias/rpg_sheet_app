// lib/screens/character_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../providers/character_provider.dart';
import '../models/character.dart';
import 'character/tabs/sheet_tab.dart';
import 'character/tabs/details_tab.dart';
import 'character/tabs/spells_tab.dart';

class CharacterScreen extends ConsumerStatefulWidget {
  final String characterId;
  const CharacterScreen({super.key, required this.characterId});

  @override
  ConsumerState<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends ConsumerState<CharacterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(Character updated) async {
    await ref
        .read(characterDetailProvider(widget.characterId).notifier)
        .saveAndPersist(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ficha salva!'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final charAsync = ref.watch(characterDetailProvider(widget.characterId));

    return charAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Erro: $e')),
      ),
      data: (char) {
        if (char == null) {
          return const Scaffold(
            body: Center(child: Text('Personagem não encontrado')));
        }
        return _CharacterScaffold(
          character: char,
          tabCtrl: _tabCtrl,
          onSave: _save,
          onLocalUpdate: (c) => ref
              .read(characterDetailProvider(widget.characterId).notifier)
              .atualizar(c),
        );
      },
    );
  }
}

class _CharacterScaffold extends StatelessWidget {
  final Character character;
  final TabController tabCtrl;
  final Future<void> Function(Character) onSave;
  final void Function(Character) onLocalUpdate;

  const _CharacterScaffold({
    required this.character,
    required this.tabCtrl,
    required this.onSave,
    required this.onLocalUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (character.className.isNotEmpty) character.className,
      if (character.level > 0) 'Nv. ${character.level}',
      if (character.race.isNotEmpty) character.race,
    ].join(' · ');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(character.name.isEmpty ? 'Sem nome' : character.name),
            if (subtitle.isNotEmpty)
              Text(subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11,
                  fontWeight: FontWeight.w400,
                )),
          ],
        ),
        bottom: TabBar(
          controller: tabCtrl,
          tabs: const [
            Tab(text: 'FICHA'),
            Tab(text: 'DETALHES'),
            Tab(text: 'MAGIAS'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded, color: AppColors.gold),
            tooltip: 'Salvar',
            onPressed: () => onSave(character),
          ),
        ],
      ),
      body: TabBarView(
        controller: tabCtrl,
        children: [
          SheetTab(
            character: character,
            onChanged: onLocalUpdate,
            onSave: onSave,
          ),
          DetailsTab(
            character: character,
            onChanged: onLocalUpdate,
            onSave: onSave,
          ),
          SpellsTab(characterId: character.id, character: character),
        ],
      ),
    );
  }
}
