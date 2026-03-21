// lib/repositories/character_repository.dart
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/character.dart';

class CharacterRepository {
  final _db = DatabaseHelper();
  final _uuid = const Uuid();

  // ── Characters ─────────────────────────────────────────────────────────────

  Future<List<Character>> getAll() => _db.getAllCharacters();

  Future<Character?> getById(String id) => _db.getCharacter(id);

  Future<Character> create({String name = 'Novo Personagem'}) async {
    final now = DateTime.now();
    final char = Character(
      id: _uuid.v4(),
      name: name,
      createdAt: now,
      updatedAt: now,
    );
    await _db.insertCharacter(char);
    return char;
  }

  Future<void> save(Character character) => _db.updateCharacter(character);

  Future<void> delete(String id) => _db.deleteCharacter(id);

  // ── Attacks ────────────────────────────────────────────────────────────────

  Future<List<Attack>> getAttacks(String characterId) =>
      _db.getAttacks(characterId);

  Future<Attack> addAttack(String characterId) async {
    final attack = Attack(
      id: _uuid.v4(),
      characterId: characterId,
      sortOrder: DateTime.now().millisecondsSinceEpoch,
    );
    await _db.insertAttack(attack);
    return attack;
  }

  Future<void> saveAttack(Attack attack) => _db.updateAttack(attack);

  Future<void> deleteAttack(String id) => _db.deleteAttack(id);

  // ── Spells ─────────────────────────────────────────────────────────────────

  Future<List<Spell>> getSpells(String characterId) =>
      _db.getSpells(characterId);

  Future<Spell> addSpell(String characterId, {int circle = 0}) async {
    final spell = Spell(
      id: _uuid.v4(),
      characterId: characterId,
      circle: circle,
      sortOrder: DateTime.now().millisecondsSinceEpoch,
    );
    await _db.insertSpell(spell);
    return spell;
  }

  Future<void> saveSpell(Spell spell) => _db.updateSpell(spell);

  Future<void> deleteSpell(String id) => _db.deleteSpell(id);

  // ── Spell Slots ────────────────────────────────────────────────────────────

  Future<List<SpellSlot>> getSpellSlots(String characterId) =>
      _db.getSpellSlots(characterId);

  Future<void> saveSpellSlot(SpellSlot slot) => _db.upsertSpellSlot(slot);

  // ── Images ─────────────────────────────────────────────────────────────────

  Future<String> saveImage(
      String characterId, String sourcePath, String name) =>
      _db.saveImage(characterId, sourcePath, name);
}
