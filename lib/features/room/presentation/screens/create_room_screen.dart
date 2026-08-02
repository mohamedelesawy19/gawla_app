// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/design_system/spacing.dart';
import '/core/di/service_locator.dart';
import '/core/localization/localization_helpers.dart';
import '/core/widgets/buttons/primary_button.dart';
import '/core/widgets/feedback/snackbar.dart';

// Feature imports:
import '/features/room/domain/entities/room_enums.dart';
import '/features/room/domain/entities/room_settings_entity.dart';
import '/features/room/presentation/blocs/room_bloc.dart';
import '/features/room/presentation/widgets/room_settings_form.dart';

// NOTE: This file assumes `AppSpacing` follows the conventional xs/sm/md/
// lg/xl scale (only `.lg`/`.xl` were used elsewhere). Swap `.md`/`.sm` for
// literals if those tokens don't exist in `core/design_system/spacing.dart`.

/// Lets the host configure and create a new room.
///
/// Reached from the Home screen's "Create Room" quick action. On a
/// successful [RoomCreateEvent], [RoomBloc] moves into
/// [RoomBlocStatus.inRoom] and starts watching the new room — but this
/// screen does NOT push to the Waiting Room itself. [SessionBloc]'s own
/// room subscription picks up the new membership independently, and
/// [AppRouter]'s redirect then force-navigates to `/room/:roomId`
/// (see app_router.dart's `SessionStatus.inRoom` case). Duplicating that
/// navigation here would fight the router's single source of truth.
class CreateRoomScreen extends StatelessWidget {
  const CreateRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      // RoomBloc coordinates the room across three screens (create,
      // join, waiting room) and must keep driving the room after this
      // screen is popped by the router redirect — so it's provided as
      // the shared instance from DI rather than created fresh here.
      value: ServiceLocator.get<RoomBloc>(),
      child: const _CreateRoomView(),
    );
  }
}

class _CreateRoomView extends StatefulWidget {
  const _CreateRoomView();

  @override
  State<_CreateRoomView> createState() => _CreateRoomViewState();
}

class _CreateRoomViewState extends State<_CreateRoomView> {
  // Local, ephemeral form state — not app state, so it has no business
  // living in RoomBloc. It's only turned into a RoomSettingsEntity at
  // the moment of submission.
  RoomVisibility _visibility = RoomVisibility.public;
  List<String> _miniGameRotation = const [];

  void _submit() {
    context.read<RoomBloc>().add(
      RoomCreateEvent(
        visibility: _visibility,
        settings: RoomSettingsEntity(miniGameRotation: _miniGameRotation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.createRoom)),
      body: BlocListener<RoomBloc, RoomState>(
        listenWhen: (previous, current) =>
            current.hasFailure && current.failure != previous.failure,
        listener: (context, state) =>
            CustomSnackbar.error(context, state.failure!.message),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                160,
              ),
              sliver: SliverToBoxAdapter(
                child: RoomSettingsForm(
                  visibility: _visibility,
                  onVisibilityChanged: (v) => setState(() => _visibility = v),
                  miniGameRotation: _miniGameRotation,
                  onMiniGameRotationChanged: (v) =>
                      setState(() => _miniGameRotation = v),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BlocSelector<RoomBloc, RoomState, bool>(
        selector: (state) => state.isLoading,
        builder: (context, isLoading) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: PrimaryButton(
              isLoading: isLoading,
              label: context.l10n.createRoom,
              onPressed: _submit,
              icon: Icons.stadium_rounded,
            ),
          ),
        ),
      ),
    );
  }
}
