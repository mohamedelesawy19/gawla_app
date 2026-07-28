// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/design_system/colors.dart';
import '/core/design_system/spacing.dart';
import '/core/localization/localization_helpers.dart';

// Feature imports:
import '/features/auth/presentation/bloc/auth_bloc.dart';
import '/features/auth/presentation/widgets/google_button.dart';
import '/features/auth/presentation/widgets/guest_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 7),

              // Gawla logo
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: AppColors.brandPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowBrandGlow,
                      blurRadius: 32,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.iconOnBrand,
                  size: 46,
                ),
              ),

              AppSpacing.verticalSpaceXl,

              // Title + tagline
              Text(
                context.l10n.appName,
                style: const TextStyle(
                  fontSize: 54,
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                  height: 1,
                ),
              ),
              AppSpacing.verticalSpaceSm,
              Text(
                context.l10n.tagline,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.brandAccentCyan,
                  letterSpacing: 3.5,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(flex: 8),

              // Buttons
              GoogleButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(const SignInWithGoogleEvent()),
              ),
              AppSpacing.verticalSpaceMd,
              GuestButton(
                onPressed: () => context.read<AuthBloc>().add(
                  const SignInAnonymouslyEvent(),
                ),
              ),

              AppSpacing.verticalSpaceXxl,
            ],
          ),
        ),
      ),
    );
  }
}
