// Core imports:
import '/core/utils/string_utils.dart';

// Feature imports:
import '/features/profile/domain/entities/player_entity.dart';

extension PlayerInitials on PlayerEntity {
  String get initials => StringUtils.initials(displayName);
}
