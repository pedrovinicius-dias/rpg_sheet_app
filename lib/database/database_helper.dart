// lib/database/database_helper.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/character.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;
  static const int _version = 1;
  static const String _dbName = 'dnd_sheet.db';

  // ── Inicialização ─────────────────────────────────────────────────────────
  static Future<void> init() async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    _db ??= await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'dnd_sheet_app', _dbName);
    await Directory(dirname(path)).create(recursive: true);
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE characters (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL DEFAULT '',
        player_name TEXT DEFAULT '',
        race TEXT DEFAULT '',
        class_name TEXT DEFAULT '',
        level INTEGER DEFAULT 1,
        subclass TEXT DEFAULT '',
        background TEXT DEFAULT '',
        alignment TEXT DEFAULT '',
        experience INTEGER DEFAULT 0,
        avatar_path TEXT,
        strength INTEGER DEFAULT 10,
        dexterity INTEGER DEFAULT 10,
        constitution INTEGER DEFAULT 10,
        intelligence INTEGER DEFAULT 10,
        wisdom INTEGER DEFAULT 10,
        charisma INTEGER DEFAULT 10,
        armor_class INTEGER DEFAULT 10,
        initiative_bonus INTEGER DEFAULT 0,
        speed INTEGER DEFAULT 9,
        max_hp INTEGER DEFAULT 10,
        current_hp INTEGER DEFAULT 10,
        temp_hp INTEGER DEFAULT 0,
        hit_die TEXT DEFAULT 'd8',
        hit_dice_used INTEGER DEFAULT 0,
        death_save_successes INTEGER DEFAULT 0,
        death_save_failures INTEGER DEFAULT 0,
        inspiration INTEGER DEFAULT 0,
        skill_proficiencies TEXT DEFAULT '{}',
        saving_throw_proficiencies TEXT DEFAULT '{}',
        equipment TEXT DEFAULT '',
        copper INTEGER DEFAULT 0,
        silver INTEGER DEFAULT 0,
        electrum INTEGER DEFAULT 0,
        gold INTEGER DEFAULT 0,
        platinum INTEGER DEFAULT 0,
        personality_traits TEXT DEFAULT '',
        ideals TEXT DEFAULT '',
        bonds TEXT DEFAULT '',
        flaws TEXT DEFAULT '',
        other_proficiencies TEXT DEFAULT '',
        features_traits TEXT DEFAULT '',
        backstory TEXT DEFAULT '',
        treasures TEXT DEFAULT '',
        allies TEXT DEFAULT '',
        additional_features TEXT DEFAULT '',
        organization_name TEXT DEFAULT '',
        organization_symbol_path TEXT,
        age TEXT DEFAULT '',
        height TEXT DEFAULT '',
        weight TEXT DEFAULT '',
        eye_color TEXT DEFAULT '',
        skin_color TEXT DEFAULT '',
        hair_color TEXT DEFAULT '',
        appearance_path TEXT,
        spellcasting_class TEXT DEFAULT '',
        spellcasting_ability TEXT DEFAULT '',
        created_at INTEGER,
        updated_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE attacks (
        id TEXT PRIMARY KEY,
        character_id TEXT NOT NULL,
        name TEXT DEFAULT '',
        attack_bonus TEXT DEFAULT '',
        damage_type TEXT DEFAULT '',
        sort_order INTEGER DEFAULT 0,
        FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE spells (
        id TEXT PRIMARY KEY,
        character_id TEXT NOT NULL,
        name TEXT DEFAULT '',
        circle INTEGER DEFAULT 0,
        is_prepared INTEGER DEFAULT 0,
        description TEXT DEFAULT '',
        image_path TEXT,
        sort_order INTEGER DEFAULT 0,
        FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE spell_slots (
        character_id TEXT NOT NULL,
        circle INTEGER NOT NULL,
        total INTEGER DEFAULT 0,
        used INTEGER DEFAULT 0,
        PRIMARY KEY (character_id, circle),
        FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
      )
    ''');
  }

  // ── CHARACTERS ────────────────────────────────────────────────────────────

  Future<void> insertCharacter(Character c) async {
    final db = await database;
    await db.insert('characters', c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCharacter(Character c) async {
    final db = await database;
    await db.update('characters', c.toMap(),
        where: 'id = ?', whereArgs: [c.id]);
  }

  Future<void> deleteCharacter(String id) async {
    final db = await database;
    await db.delete('characters', where: 'id = ?', whereArgs: [id]);
    // Imagens do personagem
    final dir = await _characterImagesDir(id);
    if (await dir.exists()) await dir.delete(recursive: true);
  }

  Future<List<Character>> getAllCharacters() async {
    final db = await database;
    final rows = await db.query('characters', orderBy: 'updated_at DESC');
    return rows.map(Character.fromMap).toList();
  }

  Future<Character?> getCharacter(String id) async {
    final db = await database;
    final rows = await db.query('characters', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Character.fromMap(rows.first);
  }

  // ── ATTACKS ───────────────────────────────────────────────────────────────

  Future<void> insertAttack(Attack a) async {
    final db = await database;
    await db.insert('attacks', a.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateAttack(Attack a) async {
    final db = await database;
    await db.update('attacks', a.toMap(),
        where: 'id = ?', whereArgs: [a.id]);
  }

  Future<void> deleteAttack(String id) async {
    final db = await database;
    await db.delete('attacks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Attack>> getAttacks(String characterId) async {
    final db = await database;
    final rows = await db.query('attacks',
        where: 'character_id = ?',
        whereArgs: [characterId],
        orderBy: 'sort_order ASC');
    return rows.map(Attack.fromMap).toList();
  }

  // ── SPELLS ────────────────────────────────────────────────────────────────

  Future<void> insertSpell(Spell s) async {
    final db = await database;
    await db.insert('spells', s.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSpell(Spell s) async {
    final db = await database;
    await db.update('spells', s.toMap(),
        where: 'id = ?', whereArgs: [s.id]);
  }

  Future<void> deleteSpell(String id) async {
    final db = await database;
    await db.delete('spells', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Spell>> getSpells(String characterId) async {
    final db = await database;
    final rows = await db.query('spells',
        where: 'character_id = ?',
        whereArgs: [characterId],
        orderBy: 'circle ASC, sort_order ASC');
    return rows.map(Spell.fromMap).toList();
  }

  // ── SPELL SLOTS ───────────────────────────────────────────────────────────

  Future<void> upsertSpellSlot(SpellSlot slot) async {
    final db = await database;
    await db.insert('spell_slots', slot.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SpellSlot>> getSpellSlots(String characterId) async {
    final db = await database;
    final rows = await db.query('spell_slots',
        where: 'character_id = ?',
        whereArgs: [characterId],
        orderBy: 'circle ASC');
    // Garante que todos os círculos 1-9 existam
    final existing = {for (var r in rows) (r['circle'] as int): SpellSlot.fromMap(r)};
    return List.generate(9, (i) => existing[i + 1] ??
        SpellSlot(characterId: characterId, circle: i + 1));
  }

  // ── IMAGENS ───────────────────────────────────────────────────────────────

  Future<Directory> _characterImagesDir(String characterId) async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(join(appDir.path, 'dnd_sheet_app', 'characters', characterId));
  }

  Future<String> saveImage(String characterId, String sourcePath, String name) async {
    final dir = await _characterImagesDir(characterId);
    await dir.create(recursive: true);
    final ext = sourcePath.split('.').last;
    final dest = join(dir.path, '$name.$ext');
    await File(sourcePath).copy(dest);
    return dest;
  }
}
