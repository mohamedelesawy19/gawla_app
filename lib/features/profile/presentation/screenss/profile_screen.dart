// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/localization/localization_helpers.dart';
import '/core/session/bloc/session_bloc.dart';
import '/core/widgets/feedback/error_widget.dart';
import '/core/widgets/feedback/loading_indicator.dart';
import '/core/widgets/feedback/premium_dialog.dart';
import '/core/widgets/feedback/snackbar.dart';

// Features imports:
import '/features/auth/presentation/bloc/auth_bloc.dart';
import '/features/profile/presentation/blocs/profile_bloc.dart';
import '/features/profile/presentation/widgets/edit_profile_sheet.dart';
import '/features/profile/presentation/widgets/profile_content.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServiceLocator.get<AuthBloc>(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  @override
  void initState() {
    super.initState();
    final uid = context.read<SessionBloc>().state.uid!;
    context.read<ProfileBloc>().add(GetProfileEvent(uid: uid));
  }

  Future<void> _refresh() async {
    final bloc = context.read<ProfileBloc>();
    final uid = context.read<SessionBloc>().state.uid!;
    bloc.add(GetProfileEvent(uid: uid));
    // Wait for the fetch triggered above to settle so the refresh
    // indicator doesn't dismiss before new data arrives.
    await bloc.stream
        .firstWhere((state) => state is! ProfileLoading)
        .timeout(const Duration(seconds: 8), onTimeout: () => bloc.state);
  }

  void _onLogout() {
    showPremiumDialog<void>(
      context: context,
      title: context.l10n.logoutTitle,
      description: context.l10n.logoutDescription,
      dialogType: PremiumDialogType.error,
      primaryButtonText: context.l10n.logout,
      onPrimaryPressed: () =>
          context.read<AuthBloc>().add(const SignOutEvent()),
      secondaryButtonText: context.l10n.cancel,
      onSecondaryPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileError && state.profile != null) {
              CustomSnackbar.error(context, state.failure.message);
            }
          },
          builder: (context, state) {
            return switch (state) {
              ProfileInitial() ||
              ProfileLoading() => const Center(child: LoadingIndicator()),
              ProfileLoaded(:final profile) => ProfileContent(
                profile: profile,
                isSaving: false,
                onEditTap: () =>
                    showEditProfileSheet(context, profile: profile),
                onLogoutTap: _onLogout,
                onRefresh: _refresh,
              ),
              ProfileUpdating(:final profile) =>
                profile != null
                    ? ProfileContent(
                        profile: profile,
                        isSaving: true,
                        onEditTap: () {}, // editing is already in flight
                        onLogoutTap: () {},
                        onRefresh: _refresh,
                      )
                    : const Center(child: LoadingIndicator()),
              ProfileError(:final profile) =>
                profile != null
                    ? ProfileContent(
                        profile: profile,
                        isSaving: false,
                        onEditTap: () =>
                            showEditProfileSheet(context, profile: profile),
                        onLogoutTap: _onLogout,
                        onRefresh: _refresh,
                      )
                    : ErrorStateWidget(
                        message: state.failure.message,
                        onRetry: () => context.read<ProfileBloc>().add(
                          GetProfileEvent(
                            uid: context.read<SessionBloc>().state.uid!,
                          ),
                        ),
                      ),
            };
          },
        ),
      ),
    );
  }
}
