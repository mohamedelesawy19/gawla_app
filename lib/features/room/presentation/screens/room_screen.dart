// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/localization/localization_helpers.dart';
import '/core/router/app_routes.dart';
import '/core/session/bloc/session_bloc.dart';
import '/core/widgets/buttons/primary_button.dart';
import '/core/widgets/feedback/error_widget.dart';
import '/core/widgets/feedback/loading_indicator.dart';
import '/core/widgets/feedback/premium_dialog.dart';
import '/core/widgets/feedback/snackbar.dart';

// Feature imports:
import '/features/room/domain/entities/room_entity.dart';
import '/features/room/presentation/blocs/room_bloc.dart';
import '/features/room/presentation/widgets/edit_room_settings_sheet.dart';
import '/features/room/presentation/widgets/room_content.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key, required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: ServiceLocator.get<RoomBloc>(),
      child: _RoomView(roomId: roomId),
    );
  }
}

class _RoomView extends StatefulWidget {
  const _RoomView({required this.roomId});

  final String roomId;

  @override
  State<_RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<_RoomView> {
  @override
  void initState() {
    super.initState();
    // RoomBloc is already watching this room if we arrived here right
    // after a create/join on the previous screen — but on a cold start
    // or app rehydration nothing has kicked off a watch yet, which is
    // exactly the case RoomWatchEvent's doc comment describes as the
    // app shell's responsibility. Guarding on the roomId avoids
    // needlessly restarting an already-live subscription.
    final bloc = context.read<RoomBloc>();
    if (bloc.state.room?.roomId != widget.roomId) {
      bloc.add(RoomWatchEvent(roomId: widget.roomId));
    }
  }

  // Read once rather than watched: a user's own uid is stable for the
  // life of this screen, so there's no reactive-rebuild need here.
  String? get _viewerUid => context.read<SessionBloc>().state.uid;

  void _confirmLeave() {
    showPremiumDialog<void>(
      context: context,
      title: context.l10n.leaveRoomTitle,
      description: context.l10n.leaveRoomDescription,
      dialogType: PremiumDialogType.warning,
      primaryButtonText: context.l10n.leave,
      onPrimaryPressed: () {
        Navigator.of(context).pop();
        HapticFeedback.mediumImpact();
        context.read<RoomBloc>().add(const RoomLeaveEvent());
      },
      secondaryButtonText: context.l10n.cancel,
      onSecondaryPressed: () => Navigator.of(context).pop(),
    );
  }

  void _kick(String targetUid) {
    HapticFeedback.selectionClick();
    context.read<RoomBloc>().add(RoomKickPlayerEvent(targetUid: targetUid));
  }

  void _editSettings(RoomEntity room) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<RoomBloc>(),
        child: EditSettingsSheet(room: room),
      ),
    );
  }

  void _startTournament() {
    HapticFeedback.mediumImpact();
    context.read<RoomBloc>().add(const RoomStartTournamentEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<RoomBloc, RoomState>(
          listenWhen: (previous, current) =>
              (current.hasFailure && current.failure != previous.failure) ||
              (previous.isInRoom && !current.isInRoom && !current.isLoading),
          listener: (context, state) {
            if (state.hasFailure) {
              CustomSnackbar.error(context, state.failure!.message);
            }
            // The room ended (closed, or we just left it) — nothing
            // left to watch here, so hand navigation back to the shell.
            if (!state.isInRoom && !state.isLoading) {
              context.go(AppRoutes.main);
            }
          },
          builder: (context, state) {
            if (state.hasFailure && !state.isInRoom) {
              return ErrorStateWidget(
                message: state.failure!.message,
                onRetry: () => context.read<RoomBloc>().add(
                  RoomWatchEvent(roomId: widget.roomId),
                ),
              );
            }

            if (!state.isInRoom) {
              return const Center(child: LoadingIndicator());
            }

            return RoomContent(
              room: state.room!,
              viewerUid: _viewerUid,
              isPerformingAction: state.isPerformingAction,
              onLeave: _confirmLeave,
              onKick: _kick,
              onEditSettings: () => _editSettings(state.room!),
            );
          },
        ),
      ),
      bottomNavigationBar: BlocSelector<RoomBloc, RoomState, bool>(
        selector: (state) {
          final room = state.room;
          if (room == null) return false;

          return room.isHost(_viewerUid ?? '') && room.canStartTournament;
        },
        builder: (context, canStartTournament) {
          if (!canStartTournament) {
            return const SizedBox.shrink();
          }

          return BlocSelector<RoomBloc, RoomState, bool>(
            selector: (state) => state.isPerformingAction,
            builder: (context, isLoading) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: PrimaryButton(
                  isLoading: isLoading,
                  label: context.l10n.startTournament,
                  onPressed: _startTournament,
                  icon: Icons.stadium_rounded,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
