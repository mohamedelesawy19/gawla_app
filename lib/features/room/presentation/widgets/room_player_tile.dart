// Package imports:
import 'package:flutter/material.dart';

// Core imports:
import '/core/design_system/borders.dart';
import '/core/design_system/colors.dart';
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';
import '/core/utils/string_utils.dart';
import '/core/widgets/common/avatar_face.dart';

// Feature imports:
import '/features/room/domain/entities/room_player_entity.dart';

class RoomPlayerTile extends StatelessWidget {
  const RoomPlayerTile({
    super.key,
    required this.player,
    required this.isHost,
    this.isViewer = false,
    this.canKick = false,
    this.onKick,
  });

  final RoomPlayerEntity player;
  final bool isHost;
  final bool isViewer;
  final bool canKick;
  final VoidCallback? onKick;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = player.avatarUrl;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isViewer
            ? const BorderSide(color: AppColors.brandAccentCyan, width: 1.4)
            : BorderSide.none,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isHost
                ? Border.all(color: AppColors.brandAccentCyan, width: 2)
                : null,
          ),
          padding: EdgeInsets.all(isHost ? 2 : 0),
          child: ClipOval(
            child: AvatarFace(
              avatarUrl: avatarUrl,
              initials: StringUtils.initials(player.displayName),
            ),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                player.displayName,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyLarge,
              ),
            ),
            if (isViewer) ...[
              const SizedBox(width: 6),
              const _YouChip(color: AppColors.brandAccentCyan),
            ],
          ],
        ),
        trailing: isHost
            ? const Icon(Icons.star_rounded, color: AppColors.brandAccentCyan)
            : (canKick
                  ? IconButton(
                      icon: const Icon(
                        Icons.person_remove_rounded,
                        color: AppColors.statusError,
                      ),
                      tooltip: context.l10n.removePlayer,
                      onPressed: onKick,
                    )
                  : null),
      ),
    );
  }
}

class _YouChip extends StatelessWidget {
  const _YouChip({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppBorders.borderRadiusFull,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          context.l10n.you,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
