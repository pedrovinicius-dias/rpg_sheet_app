// lib/providers/character_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character.dart';
import '../repositories/character_repository.dart';

// ── Repository provider ────────────────────────────────────────────────────

final repositoryProvider = Provider<CharacterRepository>(
  (_) => CharacterRepository(),
);

// ── Lista de personagens ───────────────────────────────────────────────────

class CharacterListNotifier extends AsyncNotifier<List<Character>> {
  @override
  Future<List<Character>> build() async {
    return ref.read(repositoryProvider).getAll();
  }

  Future<Character> createCharacter({String name = 'Novo Personagem'}) async {
    final repo = ref.read(repositoryProvider);
    final character = await repo.create(name: name);
    state = AsyncData([character, ...state.valueOrNull ?? []]);
    return character;
  }

  Future<void> deleteCharacter(String id) async {
    await ref.read(repositoryProvider).delete(id);
    state = AsyncData(
      (state.valueOrNull ?? []).where((c) => c.id != id).toList(),
    );
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(repositoryProvider).getAll());
  }
}

final characterListProvider =
    AsyncNotifierProvider<CharacterListNotifier, List<Character>>(
  CharacterListNotifier.new,
);

// ── Personagem aberto (detalhe) ────────────────────────────────────────────

class CharacterDetailNotifier extends FamilyAsyncNotifier<Character?, String> {
  @override
  Future<Character?> build(String id) async {
    return ref.read(repositoryProvider).getById(id);
  }

  Future<void> save(Character atualizard) async {
    await ref.read(repositoryProvider).save(atualizard);
    state = AsyncData(atualizard);
    // Atualiza também a lista
    ref.read(characterListProvider.notifier).reload();
  }

  @override
  void atualizar(Character atualizard) {
    // Atualiza o estado local sem salvar no banco (para UI responsiva)
    state = AsyncData(atualizard);
  }

  Future<void> saveAndPersist(Character atualizard) => save(atualizard);
}

final characterDetailProvider =
    AsyncNotifierProviderFamily<CharacterDetailNotifier, Character?, String>(
  CharacterDetailNotifier.new,
);

// ── Ataques ────────────────────────────────────────────────────────────────

class AttacksNotifier extends FamilyAsyncNotifier<List<Attack>, String> {
  @override
  Future<List<Attack>> build(String characterId) async {
    return ref.read(repositoryProvider).getAttacks(characterId);
  }

  Future<void> add() async {
    final characterId = arg;
    final attack = await ref.read(repositoryProvider).addAttack(characterId);
    state = AsyncData([...state.valueOrNull ?? [], attack]);
  }

  @override
  Future<void> atualizar(Attack attack) async {
    await ref.read(repositoryProvider).saveAttack(attack);
    state = AsyncData(
      (state.valueOrNull ?? []).map((a) => a.id == attack.id ? attack : a).toList(),
    );
  }

  Future<void> remove(String id) async {
    await ref.read(repositoryProvider).deleteAttack(id);
    state = AsyncData(
      (state.valueOrNull ?? []).where((a) => a.id != id).toList(),
    );
  }
}

final attacksProvider =
    AsyncNotifierProviderFamily<AttacksNotifier, List<Attack>, String>(
  AttacksNotifier.new,
);

// ── Magias ─────────────────────────────────────────────────────────────────

class SpellsNotifier extends FamilyAsyncNotifier<List<Spell>, String> {
  @override
  Future<List<Spell>> build(String characterId) async {
    return ref.read(repositoryProvider).getSpells(characterId);
  }

  Future<void> add({int circle = 0}) async {
    final characterId = arg;
    final spell = await ref.read(repositoryProvider)
        .addSpell(characterId, circle: circle);
    state = AsyncData([...state.valueOrNull ?? [], spell]);
  }

  @override
  Future<void> updateSpell(Spell spell) async {
    await ref.read(repositoryProvider).saveSpell(spell);
    state = AsyncData(
      (state.valueOrNull ?? [])
          .map((s) => s.id == spell.id ? spell : s)
          .toList(),
    );
  }

  Future<void> remove(String id) async {
    await ref.read(repositoryProvider).deleteSpell(id);
    state = AsyncData(
      (state.valueOrNull ?? []).where((s) => s.id != id).toList(),
    );
  }
}

final spellsProvider =
    AsyncNotifierProviderFamily<SpellsNotifier, List<Spell>, String>(
  SpellsNotifier.new,
);

// ── Espaços de magia ───────────────────────────────────────────────────────

class SpellSlotsNotifier
    extends FamilyAsyncNotifier<List<SpellSlot>, String> {
  @override
  Future<List<SpellSlot>> build(String characterId) async {
    return ref.read(repositoryProvider).getSpellSlots(characterId);
  }

  Future<void> atualizarSlot(SpellSlot slot) async {
    await ref.read(repositoryProvider).saveSpellSlot(slot);
    state = AsyncData(
      (state.valueOrNull ?? [])
          .map((s) => s.circle == slot.circle ? slot : s)
          .toList(),
    );
  }
}

final spellSlotsProvider =
    AsyncNotifierProviderFamily<SpellSlotsNotifier, List<SpellSlot>, String>(
  SpellSlotsNotifier.new,
);
