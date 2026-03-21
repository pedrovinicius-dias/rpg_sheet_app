// lib/screens/character/tabs/details_tab.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/character.dart';
import '../../../providers/character_provider.dart';
import '../../widgets/dnd_widgets.dart';

class DetailsTab extends ConsumerWidget {
  final Character character;
  final void Function(Character) onChanged;
  final Future<void> Function(Character) onSave;

  const DetailsTab({
    super.key,
    required this.character,
    required this.onChanged,
    required this.onSave,
  });

  Future<void> _pickImage(
      BuildContext context, WidgetRef ref, String name,
      void Function(String) onPath) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final saved = await ref.read(repositoryProvider)
        .saveImage(character.id, picked.path, name);
    onPath(saved);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Aparência Física ─────────────────────────────────────────────────
        const SectionTitle('Aparência Física'),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Imagem de aparência
          GestureDetector(
            onTap: () => _pickImage(
              context, ref, 'appearance',
              (p) => onChanged(character.copyWith(appearancePath: p))),
            child: Container(
              width: 120, height: 160,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold, width: 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: character.appearancePath != null &&
                      File(character.appearancePath!).existsSync()
                  ? Image.file(File(character.appearancePath!), fit: BoxFit.cover)
                  : _noImagePlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          // Campos de aparência
          Expanded(child: Column(children: [
            Row(children: [
              Expanded(child: DndTextField(
                label: 'Idade', value: character.age,
                onChanged: (v) => onChanged(character.copyWith(age: v)))),
              const SizedBox(width: 8),
              Expanded(child: DndTextField(
                label: 'Altura', value: character.height,
                onChanged: (v) => onChanged(character.copyWith(height: v)))),
            ]),
            const SizedBox(height: 8),
            DndTextField(
              label: 'Peso', value: character.weight,
              onChanged: (v) => onChanged(character.copyWith(weight: v))),
            const SizedBox(height: 8),
            DndTextField(
              label: 'Cor dos Olhos', value: character.eyeColor,
              onChanged: (v) => onChanged(character.copyWith(eyeColor: v))),
            const SizedBox(height: 8),
            DndTextField(
              label: 'Cor da Pele', value: character.skinColor,
              onChanged: (v) => onChanged(character.copyWith(skinColor: v))),
            const SizedBox(height: 8),
            DndTextField(
              label: 'Cor do Cabelo', value: character.hairColor,
              onChanged: (v) => onChanged(character.copyWith(hairColor: v))),
          ])),
        ]),

        // ── História ─────────────────────────────────────────────────────────
        const SectionTitle('História do Personagem'),
        DndTextField(
          label: 'Backstory, motivações, eventos marcantes...',
          value: character.backstory,
          maxLines: 10,
          onChanged: (v) => onChanged(character.copyWith(backstory: v)),
        ),

        // ── Aliados & Organizações ────────────────────────────────────────────
        const SectionTitle('Aliados & Organizações'),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(children: [
            DndTextField(
              label: 'Nome da Organização',
              value: character.organizationName,
              onChanged: (v) =>
                  onChanged(character.copyWith(organizationName: v)),
            ),
            const SizedBox(height: 8),
            DndTextField(
              label: 'Aliados, membros, descrição...',
              value: character.allies,
              maxLines: 6,
              onChanged: (v) => onChanged(character.copyWith(allies: v)),
            ),
          ])),
          const SizedBox(width: 12),
          // Símbolo da organização
          GestureDetector(
            onTap: () => _pickImage(
              context, ref, 'org_symbol',
              (p) => onChanged(character.copyWith(organizationSymbolPath: p))),
            child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: character.organizationSymbolPath != null &&
                      File(character.organizationSymbolPath!).existsSync()
                  ? Image.file(File(character.organizationSymbolPath!),
                      fit: BoxFit.cover)
                  : _symbolPlaceholder(),
            ),
          ),
        ]),

        // ── Características Adicionais ─────────────────────────────────────
        const SectionTitle('Características e Talentos Adicionais'),
        DndTextField(
          label: 'Habilidades adicionais, overflow da ficha principal...',
          value: character.additionalFeatures,
          maxLines: 8,
          onChanged: (v) => onChanged(character.copyWith(additionalFeatures: v)),
        ),

        // ── Tesouros ──────────────────────────────────────────────────────────
        const SectionTitle('Tesouros'),
        DndTextField(
          label: 'Relíquias, artefatos, itens especiais...',
          value: character.treasures,
          maxLines: 5,
          onChanged: (v) => onChanged(character.copyWith(treasures: v)),
        ),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _noImagePlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_outline, color: AppColors.cardBorder, size: 40),
        SizedBox(height: 6),
        Text('Toque para\nadicionar foto',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textHint, fontSize: 11)),
      ],
    );
  }

  Widget _symbolPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, color: AppColors.cardBorder, size: 28),
        SizedBox(height: 4),
        Text('Símbolo', textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textHint, fontSize: 10)),
      ],
    );
  }
}
