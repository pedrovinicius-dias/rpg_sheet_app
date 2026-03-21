// lib/core/utils/stat_calculator.dart

class StatCalculator {
  // ── Modificador de Atributo ────────────────────────────────────────────────
  /// Fórmula: (valor - 10) / 2, arredondado pra baixo
  static int modifier(int score) => ((score - 10) / 2).floor();

  /// Formata o modificador com sinal: "+3", "-1", "+0"
  static String modifierStr(int score) {
    final mod = modifier(score);
    return mod >= 0 ? '+$mod' : '$mod';
  }

  // ── Bônus de Proficiência ─────────────────────────────────────────────────
  /// Baseado no nível do personagem (1-20)
  static int proficiencyBonus(int level) {
    if (level <= 4)  return 2;
    if (level <= 8)  return 3;
    if (level <= 12) return 4;
    if (level <= 16) return 5;
    return 6;
  }

  // ── Perícias ──────────────────────────────────────────────────────────────
  /// proficiencyLevel: 0 = nenhuma, 1 = proficiente, 2 = expertise
  static int skillValue({
    required int abilityScore,
    required int proficiencyLevel,
    required int characterLevel,
  }) {
    final mod = modifier(abilityScore);
    final prof = proficiencyBonus(characterLevel);
    switch (proficiencyLevel) {
      case 2: return mod + (prof * 2); // Expertise
      case 1: return mod + prof;       // Proficiente
      default: return mod;             // Sem proficiência
    }
  }

  static String skillValueStr({
    required int abilityScore,
    required int proficiencyLevel,
    required int characterLevel,
  }) {
    final val = skillValue(
      abilityScore: abilityScore,
      proficiencyLevel: proficiencyLevel,
      characterLevel: characterLevel,
    );
    return val >= 0 ? '+$val' : '$val';
  }

  // ── Salvaguardas ──────────────────────────────────────────────────────────
  static int savingThrowValue({
    required int abilityScore,
    required bool isProficient,
    required int characterLevel,
  }) {
    final mod = modifier(abilityScore);
    return isProficient ? mod + proficiencyBonus(characterLevel) : mod;
  }

  static String savingThrowStr({
    required int abilityScore,
    required bool isProficient,
    required int characterLevel,
  }) {
    final val = savingThrowValue(
      abilityScore: abilityScore,
      isProficient: isProficient,
      characterLevel: characterLevel,
    );
    return val >= 0 ? '+$val' : '$val';
  }

  // ── Percepção Passiva ─────────────────────────────────────────────────────
  static int passivePerception({
    required int wisdomScore,
    required int perceptionProficiency,
    required int characterLevel,
  }) {
    return 10 + skillValue(
      abilityScore: wisdomScore,
      proficiencyLevel: perceptionProficiency,
      characterLevel: characterLevel,
    );
  }

  // ── CD de Magia ───────────────────────────────────────────────────────────
  static int spellSaveDC({
    required int spellcastingAbilityScore,
    required int characterLevel,
  }) {
    return 8 + proficiencyBonus(characterLevel) + modifier(spellcastingAbilityScore);
  }

  // ── Modificador de Ataque Mágico ─────────────────────────────────────────
  static int spellAttackBonus({
    required int spellcastingAbilityScore,
    required int characterLevel,
  }) {
    return proficiencyBonus(characterLevel) + modifier(spellcastingAbilityScore);
  }

  static String spellAttackBonusStr({
    required int spellcastingAbilityScore,
    required int characterLevel,
  }) {
    final val = spellAttackBonus(
      spellcastingAbilityScore: spellcastingAbilityScore,
      characterLevel: characterLevel,
    );
    return val >= 0 ? '+$val' : '$val';
  }

  // ── Iniciativa ────────────────────────────────────────────────────────────
  static int initiative(int dexterityScore, {int bonus = 0}) =>
      modifier(dexterityScore) + bonus;

  static String initiativeStr(int dexterityScore, {int bonus = 0}) {
    final val = initiative(dexterityScore, bonus: bonus);
    return val >= 0 ? '+$val' : '$val';
  }

  // ── HP máximo estimado ────────────────────────────────────────────────────
  /// Estimativa: dado de vida máximo no nível 1, média nos seguintes
  static int estimatedMaxHp({
    required String hitDie,
    required int level,
    required int constitutionScore,
  }) {
    final conMod = modifier(constitutionScore);
    final maxDie = _dieValue(hitDie);
    final avgDie = ((maxDie / 2) + 1).floor();
    return maxDie + conMod + (avgDie + conMod) * (level - 1);
  }

  static int _dieValue(String die) {
    switch (die) {
      case 'd4': return 4;
      case 'd6': return 6;
      case 'd8': return 8;
      case 'd10': return 10;
      case 'd12': return 12;
      default: return 8;
    }
  }

  // ── Formatação geral ──────────────────────────────────────────────────────
  static String formatBonus(int value) => value >= 0 ? '+$value' : '$value';
}
