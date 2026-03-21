// lib/core/constants/dnd_constants.dart

class DnDConstants {
  // ── Atributos ─────────────────────────────────────────────────────────────
  static const List<String> abilities = [
    'strength', 'dexterity', 'constitution',
    'intelligence', 'wisdom', 'charisma',
  ];

  static const Map<String, String> abilityNames = {
    'strength': 'Força',
    'dexterity': 'Destreza',
    'constitution': 'Constituição',
    'intelligence': 'Inteligência',
    'wisdom': 'Sabedoria',
    'charisma': 'Carisma',
  };

  static const Map<String, String> abilityAbbr = {
    'strength': 'FOR',
    'dexterity': 'DES',
    'constitution': 'CON',
    'intelligence': 'INT',
    'wisdom': 'SAB',
    'charisma': 'CAR',
  };

  // ── Perícias ──────────────────────────────────────────────────────────────
  // key -> [nome PT-BR, atributo associado]
  static const Map<String, List<String>> skills = {
    'acrobatics':      ['Acrobacia', 'dexterity'],
    'arcana':          ['Arcanismo', 'intelligence'],
    'athletics':       ['Atletismo', 'strength'],
    'performance':     ['Atuação', 'charisma'],
    'deception':       ['Enganação', 'charisma'],
    'stealth':         ['Furtividade', 'dexterity'],
    'history':         ['História', 'intelligence'],
    'intimidation':    ['Intimidação', 'charisma'],
    'insight':         ['Intuição', 'wisdom'],
    'investigation':   ['Investigação', 'intelligence'],
    'animal_handling': ['Lidar c/ Animais', 'wisdom'],
    'medicine':        ['Medicina', 'wisdom'],
    'nature':          ['Natureza', 'intelligence'],
    'perception':      ['Percepção', 'wisdom'],
    'persuasion':      ['Persuasão', 'charisma'],
    'sleight_of_hand': ['Prestidigitação', 'dexterity'],
    'religion':        ['Religião', 'intelligence'],
    'survival':        ['Sobrevivência', 'wisdom'],
  };

  // Ordem de exibição das perícias (igual à ficha oficial)
  static const List<String> skillOrder = [
    'acrobatics', 'arcana', 'athletics', 'performance', 'deception',
    'stealth', 'history', 'intimidation', 'insight', 'investigation',
    'animal_handling', 'medicine', 'nature', 'perception', 'persuasion',
    'sleight_of_hand', 'religion', 'survival',
  ];

  // ── Classes ───────────────────────────────────────────────────────────────
  static const List<String> classes = [
    'Bárbaro', 'Bardo', 'Bruxo', 'Clérigo', 'Druida', 'Feiticeiro',
    'Guerreiro', 'Ladino', 'Mago', 'Monge', 'Paladino', 'Patrulheiro',
  ];

  static const Map<String, String> classHitDie = {
    'Bárbaro': 'd12', 'Bardo': 'd8', 'Bruxo': 'd8', 'Clérigo': 'd8',
    'Druida': 'd8', 'Feiticeiro': 'd6', 'Guerreiro': 'd10', 'Ladino': 'd8',
    'Mago': 'd6', 'Monge': 'd8', 'Paladino': 'd10', 'Patrulheiro': 'd10',
  };

  // ── Raças ─────────────────────────────────────────────────────────────────
  static const List<String> races = [
    'Anão', 'Draconato', 'Elfo', 'Gnomo', 'Halfling', 'Humano',
    'Meio-Elfo', 'Meio-Orc', 'Tiefling',
  ];

  // ── Alinhamentos ──────────────────────────────────────────────────────────
  static const List<String> alignments = [
    'Leal e Bom', 'Neutro e Bom', 'Caótico e Bom',
    'Leal e Neutro', 'Neutro', 'Caótico e Neutro',
    'Leal e Mau', 'Neutro e Mau', 'Caótico e Mau',
  ];

  // ── Antecedentes ──────────────────────────────────────────────────────────
  static const List<String> backgrounds = [
    'Acólito', 'Artesão de Guilda', 'Artista', 'Charlatão', 'Criminoso',
    'Eremita', 'Forasteiro', 'Herói do Povo', 'Marinheiro', 'Nobre',
    'Órfão', 'Sábio', 'Soldado',
  ];

  // ── Atributos de conjuração ───────────────────────────────────────────────
  static const List<String> spellcastingAbilities = [
    'intelligence', 'wisdom', 'charisma',
  ];

  // ── Dados de vida ─────────────────────────────────────────────────────────
  static const List<String> hitDice = ['d4', 'd6', 'd8', 'd10', 'd12'];

  // ── Moedas ────────────────────────────────────────────────────────────────
  static const Map<String, String> currencies = {
    'copper': 'PC',
    'silver': 'PP',
    'electrum': 'PE',
    'gold': 'PO',
    'platinum': 'PL',
  };
}
