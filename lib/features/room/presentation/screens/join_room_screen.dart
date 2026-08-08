// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

// Core imports:
import '/core/design_system/spacing.dart';
import '/core/di/service_locator.dart';
import '/core/extensions/digits_extension.dart';
import '/core/localization/localization_helpers.dart';
import '/core/widgets/buttons/primary_button.dart';
import '/core/widgets/buttons/secondary_button.dart';
import '/core/widgets/dividers/or_divider.dart';
import '/core/widgets/feedback/snackbar.dart';
import '/core/widgets/inputs/code_input_field.dart';

// Feature imports:
import '/features/room/presentation/blocs/room_bloc.dart';

/// Lets a player join an existing room — either by entering a private
/// room's invite code, or via Quick Tournament into an open public room.
///
/// As with [CreateRoomScreen], a successful join does not navigate
/// itself: [SessionBloc]'s room subscription picks up the membership
/// change and [AppRouter]'s redirect takes the user to
/// `/room/:roomId` automatically.
class JoinRoomScreen extends StatelessWidget {
  const JoinRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.get<RoomBloc>(),
      child: const _JoinRoomView(),
    );
  }
}

class _JoinRoomView extends StatefulWidget {
  const _JoinRoomView();

  @override
  State<_JoinRoomView> createState() => _JoinRoomViewState();
}

class _JoinRoomViewState extends State<_JoinRoomView> {
  final _codeController = PinInputController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _joinByCode([String? code]) {
    final code = _codeController.text.trim().normalizeDigits();
    if (code.isEmpty) return;
    context.read<RoomBloc>().add(RoomJoinByCodeEvent(inviteCode: code));
  }

  void _quickTournament() {
    context.read<RoomBloc>().add(const RoomQuickJoinEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.joinRoom)),
      body: BlocListener<RoomBloc, RoomState>(
        listenWhen: (previous, current) =>
            current.hasFailure && current.failure != previous.failure,
        listener: (context, state) =>
            CustomSnackbar.error(context, state.failure!.message),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  context.l10n.enterInviteCode,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                CodeInputField(
                  controller: _codeController,
                  onCompleted: _joinByCode,
                  gap: 12,
                ),
                const SizedBox(height: AppSpacing.xl),
                BlocSelector<RoomBloc, RoomState, bool>(
                  selector: (state) => state.isLoading,
                  builder: (context, isLoading) {
                    return PrimaryButton(
                      isLoading: isLoading,
                      onPressed: _joinByCode,
                      label: context.l10n.joinRoom,
                      icon: Icons.group_add_rounded,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                const OrDivider(),
                const SizedBox(height: AppSpacing.xxl),
                BlocSelector<RoomBloc, RoomState, bool>(
                  selector: (state) => state.isLoading,
                  builder: (context, isLoading) {
                    return SecondaryButton(
                      isLoading: isLoading,
                      onPressed: _quickTournament,
                      label: context.l10n.quickTournament,
                      icon: Icons.flash_on_rounded,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
