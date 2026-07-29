import '/features/profile/domain/entities/player_entity.dart';

class LevelSystem {
  const LevelSystem._();

  static const int baseXp = 100;
  static const double growthFactor = 1.2;

  static int xpRequiredForLevel(int level) {
    return (baseXp * level * growthFactor).round();
  }

  static double progress(int currentXp, int level) {
    final required = xpRequiredForLevel(level);
    if (required == 0) return 0;
    return (currentXp / required).clamp(0.0, 1.0);
  }
}

extension PlayerLevel on PlayerEntity {
  double get levelProgress => LevelSystem.progress(xp, level);
  int get xpToNextLevel => LevelSystem.xpRequiredForLevel(level) - xp;
}
