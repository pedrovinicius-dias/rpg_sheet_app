// lib/models/character.dart
import 'dart:convert';

class Character {
  final String id;
  final String name;
  final String playerName;
  final String race;
  final String className;
  final int level;
  final String subclass;
  final String background;
  final String alignment;
  final int experience;
  final String? avatarPath;

  // ── Atributos ─────────────────────────────────────────────────────────────
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  // ── Combate ───────────────────────────────────────────────────────────────
  final int armorClass;
  final int initiativeBonus;
  final int speed;
  final int maxHp;
  final int currentHp;
  final int tempHp;
  final String hitDie;
  final int hitDiceUsed;
  final int deathSaveSuccesses;
  final int deathSaveFailures;
  final bool inspiration;

  // ── Proficiências (JSON no banco) ─────────────────────────────────────────
  /// 0 = nenhuma, 1 = proficiente, 2 = expertise
  final Map<String, int> skillProficiencies;

  /// true = proficiente na salvaguarda
  final Map<String, bool> savingThrowProficiencies;

  // ── Equipamentos / Moedas ─────────────────────────────────────────────────
  final String equipment;
  final int copper;
  final int silver;
  final int electrum;
  final int gold;
  final int platinum;

  // ── Personalidade ─────────────────────────────────────────────────────────
  final String personalityTraits;
  final String ideals;
  final String bonds;
  final String flaws;
  final String otherProficiencies;
  final String featuresAndTraits;

  // ── Página 2: Detalhes ────────────────────────────────────────────────────
  final String backstory;
  final String treasures;
  final String allies;
  final String additionalFeatures;
  final String organizationName;
  final String? organizationSymbolPath;
  final String age;
  final String height;
  final String weight;
  final String eyeColor;
  final String skinColor;
  final String hairColor;
  final String? appearancePath;

  // ── Conjuração ────────────────────────────────────────────────────────────
  final String spellcastingClass;
  final String spellcastingAbility;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Character({
    required this.id,
    this.name = '',
    this.playerName = '',
    this.race = '',
    this.className = '',
    this.level = 1,
    this.subclass = '',
    this.background = '',
    this.alignment = '',
    this.experience = 0,
    this.avatarPath,
    this.strength = 10,
    this.dexterity = 10,
    this.constitution = 10,
    this.intelligence = 10,
    this.wisdom = 10,
    this.charisma = 10,
    this.armorClass = 10,
    this.initiativeBonus = 0,
    this.speed = 9,
    this.maxHp = 10,
    this.currentHp = 10,
    this.tempHp = 0,
    this.hitDie = 'd8',
    this.hitDiceUsed = 0,
    this.deathSaveSuccesses = 0,
    this.deathSaveFailures = 0,
    this.inspiration = false,
    this.skillProficiencies = const {},
    this.savingThrowProficiencies = const {},
    this.equipment = '',
    this.copper = 0,
    this.silver = 0,
    this.electrum = 0,
    this.gold = 0,
    this.platinum = 0,
    this.personalityTraits = '',
    this.ideals = '',
    this.bonds = '',
    this.flaws = '',
    this.otherProficiencies = '',
    this.featuresAndTraits = '',
    this.backstory = '',
    this.treasures = '',
    this.allies = '',
    this.additionalFeatures = '',
    this.organizationName = '',
    this.organizationSymbolPath,
    this.age = '',
    this.height = '',
    this.weight = '',
    this.eyeColor = '',
    this.skinColor = '',
    this.hairColor = '',
    this.appearancePath,
    this.spellcastingClass = '',
    this.spellcastingAbility = '',
    required this.createdAt,
    required this.updatedAt,
  });

  // ── copyWith ───────────────────────────────────────────────────────────────
  Character copyWith({
    String? name, String? playerName, String? race, String? className,
    int? level, String? subclass, String? background, String? alignment,
    int? experience, String? avatarPath,
    int? strength, int? dexterity, int? constitution, int? intelligence,
    int? wisdom, int? charisma,
    int? armorClass, int? initiativeBonus, int? speed,
    int? maxHp, int? currentHp, int? tempHp, String? hitDie,
    int? hitDiceUsed, int? deathSaveSuccesses, int? deathSaveFailures,
    bool? inspiration,
    Map<String, int>? skillProficiencies,
    Map<String, bool>? savingThrowProficiencies,
    String? equipment, int? copper, int? silver, int? electrum,
    int? gold, int? platinum,
    String? personalityTraits, String? ideals, String? bonds,
    String? flaws, String? otherProficiencies, String? featuresAndTraits,
    String? backstory, String? treasures, String? allies,
    String? additionalFeatures, String? organizationName,
    String? organizationSymbolPath, String? age, String? height,
    String? weight, String? eyeColor, String? skinColor, String? hairColor,
    String? appearancePath,
    String? spellcastingClass, String? spellcastingAbility,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      playerName: playerName ?? this.playerName,
      race: race ?? this.race,
      className: className ?? this.className,
      level: level ?? this.level,
      subclass: subclass ?? this.subclass,
      background: background ?? this.background,
      alignment: alignment ?? this.alignment,
      experience: experience ?? this.experience,
      avatarPath: avatarPath ?? this.avatarPath,
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      constitution: constitution ?? this.constitution,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
      armorClass: armorClass ?? this.armorClass,
      initiativeBonus: initiativeBonus ?? this.initiativeBonus,
      speed: speed ?? this.speed,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      tempHp: tempHp ?? this.tempHp,
      hitDie: hitDie ?? this.hitDie,
      hitDiceUsed: hitDiceUsed ?? this.hitDiceUsed,
      deathSaveSuccesses: deathSaveSuccesses ?? this.deathSaveSuccesses,
      deathSaveFailures: deathSaveFailures ?? this.deathSaveFailures,
      inspiration: inspiration ?? this.inspiration,
      skillProficiencies: skillProficiencies ?? this.skillProficiencies,
      savingThrowProficiencies: savingThrowProficiencies ?? this.savingThrowProficiencies,
      equipment: equipment ?? this.equipment,
      copper: copper ?? this.copper,
      silver: silver ?? this.silver,
      electrum: electrum ?? this.electrum,
      gold: gold ?? this.gold,
      platinum: platinum ?? this.platinum,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      ideals: ideals ?? this.ideals,
      bonds: bonds ?? this.bonds,
      flaws: flaws ?? this.flaws,
      otherProficiencies: otherProficiencies ?? this.otherProficiencies,
      featuresAndTraits: featuresAndTraits ?? this.featuresAndTraits,
      backstory: backstory ?? this.backstory,
      treasures: treasures ?? this.treasures,
      allies: allies ?? this.allies,
      additionalFeatures: additionalFeatures ?? this.additionalFeatures,
      organizationName: organizationName ?? this.organizationName,
      organizationSymbolPath: organizationSymbolPath ?? this.organizationSymbolPath,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      eyeColor: eyeColor ?? this.eyeColor,
      skinColor: skinColor ?? this.skinColor,
      hairColor: hairColor ?? this.hairColor,
      appearancePath: appearancePath ?? this.appearancePath,
      spellcastingClass: spellcastingClass ?? this.spellcastingClass,
      spellcastingAbility: spellcastingAbility ?? this.spellcastingAbility,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // ── Serialização ──────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'player_name': playerName,
    'race': race,
    'class_name': className,
    'level': level,
    'subclass': subclass,
    'background': background,
    'alignment': alignment,
    'experience': experience,
    'avatar_path': avatarPath,
    'strength': strength,
    'dexterity': dexterity,
    'constitution': constitution,
    'intelligence': intelligence,
    'wisdom': wisdom,
    'charisma': charisma,
    'armor_class': armorClass,
    'initiative_bonus': initiativeBonus,
    'speed': speed,
    'max_hp': maxHp,
    'current_hp': currentHp,
    'temp_hp': tempHp,
    'hit_die': hitDie,
    'hit_dice_used': hitDiceUsed,
    'death_save_successes': deathSaveSuccesses,
    'death_save_failures': deathSaveFailures,
    'inspiration': inspiration ? 1 : 0,
    'skill_proficiencies': jsonEncode(skillProficiencies),
    'saving_throw_proficiencies': jsonEncode(savingThrowProficiencies),
    'equipment': equipment,
    'copper': copper,
    'silver': silver,
    'electrum': electrum,
    'gold': gold,
    'platinum': platinum,
    'personality_traits': personalityTraits,
    'ideals': ideals,
    'bonds': bonds,
    'flaws': flaws,
    'other_proficiencies': otherProficiencies,
    'features_traits': featuresAndTraits,
    'backstory': backstory,
    'treasures': treasures,
    'allies': allies,
    'additional_features': additionalFeatures,
    'organization_name': organizationName,
    'organization_symbol_path': organizationSymbolPath,
    'age': age,
    'height': height,
    'weight': weight,
    'eye_color': eyeColor,
    'skin_color': skinColor,
    'hair_color': hairColor,
    'appearance_path': appearancePath,
    'spellcasting_class': spellcastingClass,
    'spellcasting_ability': spellcastingAbility,
    'created_at': createdAt.millisecondsSinceEpoch,
    'updated_at': updatedAt.millisecondsSinceEpoch,
  };

  factory Character.fromMap(Map<String, dynamic> m) {
    Map<String, int> skillProf = {};
    Map<String, bool> saveProf = {};
    try {
      final raw = jsonDecode(m['skill_proficiencies'] ?? '{}') as Map;
      skillProf = raw.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
    } catch (_) {}
    try {
      final raw = jsonDecode(m['saving_throw_proficiencies'] ?? '{}') as Map;
      saveProf = raw.map((k, v) => MapEntry(k.toString(), v == true || v == 1));
    } catch (_) {}

    return Character(
      id: m['id'],
      name: m['name'] ?? '',
      playerName: m['player_name'] ?? '',
      race: m['race'] ?? '',
      className: m['class_name'] ?? '',
      level: m['level'] ?? 1,
      subclass: m['subclass'] ?? '',
      background: m['background'] ?? '',
      alignment: m['alignment'] ?? '',
      experience: m['experience'] ?? 0,
      avatarPath: m['avatar_path'],
      strength: m['strength'] ?? 10,
      dexterity: m['dexterity'] ?? 10,
      constitution: m['constitution'] ?? 10,
      intelligence: m['intelligence'] ?? 10,
      wisdom: m['wisdom'] ?? 10,
      charisma: m['charisma'] ?? 10,
      armorClass: m['armor_class'] ?? 10,
      initiativeBonus: m['initiative_bonus'] ?? 0,
      speed: m['speed'] ?? 9,
      maxHp: m['max_hp'] ?? 10,
      currentHp: m['current_hp'] ?? 10,
      tempHp: m['temp_hp'] ?? 0,
      hitDie: m['hit_die'] ?? 'd8',
      hitDiceUsed: m['hit_dice_used'] ?? 0,
      deathSaveSuccesses: m['death_save_successes'] ?? 0,
      deathSaveFailures: m['death_save_failures'] ?? 0,
      inspiration: (m['inspiration'] ?? 0) == 1,
      skillProficiencies: skillProf,
      savingThrowProficiencies: saveProf,
      equipment: m['equipment'] ?? '',
      copper: m['copper'] ?? 0,
      silver: m['silver'] ?? 0,
      electrum: m['electrum'] ?? 0,
      gold: m['gold'] ?? 0,
      platinum: m['platinum'] ?? 0,
      personalityTraits: m['personality_traits'] ?? '',
      ideals: m['ideals'] ?? '',
      bonds: m['bonds'] ?? '',
      flaws: m['flaws'] ?? '',
      otherProficiencies: m['other_proficiencies'] ?? '',
      featuresAndTraits: m['features_traits'] ?? '',
      backstory: m['backstory'] ?? '',
      treasures: m['treasures'] ?? '',
      allies: m['allies'] ?? '',
      additionalFeatures: m['additional_features'] ?? '',
      organizationName: m['organization_name'] ?? '',
      organizationSymbolPath: m['organization_symbol_path'],
      age: m['age'] ?? '',
      height: m['height'] ?? '',
      weight: m['weight'] ?? '',
      eyeColor: m['eye_color'] ?? '',
      skinColor: m['skin_color'] ?? '',
      hairColor: m['hair_color'] ?? '',
      appearancePath: m['appearance_path'],
      spellcastingClass: m['spellcasting_class'] ?? '',
      spellcastingAbility: m['spellcasting_ability'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(m['created_at'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(m['updated_at'] ?? 0),
    );
  }
}

// ── Attack ─────────────────────────────────────────────────────────────────

class Attack {
  final String id;
  final String characterId;
  final String name;
  final String attackBonus;
  final String damageType;
  final int sortOrder;

  const Attack({
    required this.id,
    required this.characterId,
    this.name = '',
    this.attackBonus = '',
    this.damageType = '',
    this.sortOrder = 0,
  });

  Attack copyWith({
    String? name, String? attackBonus, String? damageType, int? sortOrder,
  }) => Attack(
    id: id, characterId: characterId,
    name: name ?? this.name,
    attackBonus: attackBonus ?? this.attackBonus,
    damageType: damageType ?? this.damageType,
    sortOrder: sortOrder ?? this.sortOrder,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'character_id': characterId,
    'name': name, 'attack_bonus': attackBonus,
    'damage_type': damageType, 'sort_order': sortOrder,
  };

  factory Attack.fromMap(Map<String, dynamic> m) => Attack(
    id: m['id'], characterId: m['character_id'],
    name: m['name'] ?? '', attackBonus: m['attack_bonus'] ?? '',
    damageType: m['damage_type'] ?? '', sortOrder: m['sort_order'] ?? 0,
  );
}

// ── Spell ──────────────────────────────────────────────────────────────────

class Spell {
  final String id;
  final String characterId;
  final String name;
  final int circle; // 0 = truque
  final bool isPrepared;
  final String description;
  final String? imagePath;
  final int sortOrder;

  const Spell({
    required this.id,
    required this.characterId,
    this.name = '',
    this.circle = 0,
    this.isPrepared = false,
    this.description = '',
    this.imagePath,
    this.sortOrder = 0,
  });

  Spell copyWith({
    String? name, int? circle, bool? isPrepared,
    String? description, String? imagePath, int? sortOrder,
  }) => Spell(
    id: id, characterId: characterId,
    name: name ?? this.name,
    circle: circle ?? this.circle,
    isPrepared: isPrepared ?? this.isPrepared,
    description: description ?? this.description,
    imagePath: imagePath ?? this.imagePath,
    sortOrder: sortOrder ?? this.sortOrder,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'character_id': characterId,
    'name': name, 'circle': circle,
    'is_prepared': isPrepared ? 1 : 0,
    'description': description, 'image_path': imagePath,
    'sort_order': sortOrder,
  };

  factory Spell.fromMap(Map<String, dynamic> m) => Spell(
    id: m['id'], characterId: m['character_id'],
    name: m['name'] ?? '', circle: m['circle'] ?? 0,
    isPrepared: (m['is_prepared'] ?? 0) == 1,
    description: m['description'] ?? '',
    imagePath: m['image_path'],
    sortOrder: m['sort_order'] ?? 0,
  );
}

// ── SpellSlot ──────────────────────────────────────────────────────────────

class SpellSlot {
  final String characterId;
  final int circle;
  final int total;
  final int used;

  const SpellSlot({
    required this.characterId,
    required this.circle,
    this.total = 0,
    this.used = 0,
  });

  int get remaining => (total - used).clamp(0, total);

  SpellSlot copyWith({int? total, int? used}) => SpellSlot(
    characterId: characterId, circle: circle,
    total: total ?? this.total, used: used ?? this.used,
  );

  Map<String, dynamic> toMap() => {
    'character_id': characterId, 'circle': circle,
    'total': total, 'used': used,
  };

  factory SpellSlot.fromMap(Map<String, dynamic> m) => SpellSlot(
    characterId: m['character_id'], circle: m['circle'],
    total: m['total'] ?? 0, used: m['used'] ?? 0,
  );
}
