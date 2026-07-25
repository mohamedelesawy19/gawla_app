// Package imports:
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/localization/localization_helpers.dart';
import '/core/theme/theme_extensions.dart';

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

              // Pin
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.colorScheme.primary.withValues(
                        alpha: 0.45,
                      ),
                      blurRadius: 32,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.location_pin,
                  color: context.colorScheme.surface,
                  size: 46,
                ),
              ),

              const SizedBox(height: 32),

              // Title + tagline
              Text(
                context.l10n.appName,
                style: TextStyle(
                  fontSize: 54,
                  color: context.colorScheme.onSurface,
                  letterSpacing: 2,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.tagline,
                style: TextStyle(
                  fontSize: 10,
                  color: context.colorScheme.primary.withValues(alpha: 0.80),
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
              const SizedBox(height: 14),
              GuestButton(
                onPressed: () => context.read<AuthBloc>().add(
                  const SignInAnonymouslyEvent(),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
