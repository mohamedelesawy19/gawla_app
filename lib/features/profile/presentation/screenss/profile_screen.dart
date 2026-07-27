// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/design_system/spacing.dart';
import '/core/widgets/feedback/error_widget.dart';
import '/core/widgets/feedback/loading_indicator.dart';
import '/core/widgets/feedback/snackbar.dart';

// Feature imports:
import '/features/profile/domain/entities/player_entity.dart';
import '/features/profile/presentation/blocs/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            CustomSnackbar.error(context, state.failure.message);
          }
        },
        builder: (context, state) {
          final profile = switch (state) {
            ProfileLoaded(:final profile) => profile,
            ProfileUpdating(:final profile) => profile,
            ProfileError(:final profile) => profile,
            _ => null,
          };

          if (profile == null) {
            if (state is ProfileError) {
              return ErrorStateWidget(
                message: state.failure.message,
                onRetry: () =>
                    context.read<ProfileBloc>().add(GetProfileEvent(uid: uid)),
              );
            }
            return const Center(child: LoadingIndicator());
          }

          final isUpdating = state is ProfileUpdating;

          return _ProfileForm(
            profile: profile,
            isUpdating: isUpdating,
            onSave: (newName) => context.read<ProfileBloc>().add(
              UpdateProfileEvent(uid: uid, displayName: newName),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm({
    required this.profile,
    required this.isUpdating,
    required this.onSave,
  });

  final PlayerEntity profile;
  final bool isUpdating;
  final ValueChanged<String> onSave;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.displayName);
  }

  @override
  void didUpdateWidget(covariant _ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the field in sync if the name changed from elsewhere (e.g. the
    // update round-tripped) while preserving in-progress local edits.
    if (oldWidget.profile.displayName != widget.profile.displayName &&
        _nameController.text == oldWidget.profile.displayName) {
      _nameController.text = widget.profile.displayName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return ListView(
      padding: AppSpacing.paddingLg,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: profile.avatarUrl != null
              ? NetworkImage(profile.avatarUrl!)
              : null,
          child: profile.avatarUrl == null
              ? Text(
                  profile.displayName.isNotEmpty
                      ? profile.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 28),
                )
              : null,
        ),
        AppSpacing.verticalSpaceXxl,
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Display name',
            border: OutlineInputBorder(),
          ),
        ),
        AppSpacing.verticalSpaceMd,
        FilledButton(
          onPressed: widget.isUpdating
              ? null
              : () => widget.onSave(_nameController.text),
          child: widget.isUpdating
              ? const LoadingIndicator(size: .small)
              : const Text('Save'),
        ),
        const Divider(height: 40),
        _StatTile(label: 'Level', value: '${profile.level}'),
        _StatTile(label: 'Coins', value: '${profile.coins}'),
        _StatTile(label: 'Gems', value: '${profile.gems}'),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: Text(value, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
