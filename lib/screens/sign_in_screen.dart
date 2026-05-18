import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/app_backdrop.dart';
import '../widgets/app_logo.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (
        BuildContext context,
        AuthProvider authProvider,
        Widget? child,
      ) {
        return AppBackdrop(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: <Widget>[
              const SizedBox(height: 20),
              const AppLogo(showWordmark: true),
              const SizedBox(height: 30),
              Text(
                'Premium alerting for high-response freelancers',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 14),
              Text(
                'Log in with Google to sync your schedule, alarm preferences, and account settings across devices using Firebase free tier services.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _FeatureRow(
                      icon: Icons.notifications_active_rounded,
                      title: 'Fiverr-only notification detection',
                    ),
                    const SizedBox(height: 16),
                    _FeatureRow(
                      icon: Icons.alarm_rounded,
                      title: 'Loud alarm, vibration, and full-screen alert',
                    ),
                    const SizedBox(height: 16),
                    _FeatureRow(
                      icon: Icons.cloud_done_rounded,
                      title: 'Firebase-backed preferences and login persistence',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (!authProvider.firebaseConfigured)
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Firebase is not ready on this build',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Firebase is not configured for this platform yet. Run FlutterFire for this target and enable Google Sign-In in Firebase Authentication before trying to log in.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              else if (!authProvider.googleSignInSupported)
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Google sign-in is unavailable here',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'This build can open the app, but Google authentication is only enabled once the current platform has matching FlutterFire and Google Sign-In setup. Android with a refreshed google-services.json is the primary supported path right now.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              if (authProvider.errorMessage != null) ...<Widget>[
                const SizedBox(height: 18),
                GlassCard(
                  child: Text(
                    authProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              GradientButton(
                label: authProvider.isSigningIn
                    ? 'Connecting Google account...'
                    : 'Continue with Google',
                icon: Icons.login_rounded,
                onPressed: authProvider.firebaseConfigured &&
                        authProvider.googleSignInSupported &&
                        !authProvider.isSigningIn
                    ? () => authProvider.signInWithGoogle()
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: scheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
