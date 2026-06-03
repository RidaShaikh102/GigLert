import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/home_shell.dart';
import '../widgets/app_backdrop.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';

class EmailSignInScreen extends StatefulWidget {
  const EmailSignInScreen({super.key});

  @override
  State<EmailSignInScreen> createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isRegistering = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn(AuthProvider authProvider) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_isRegistering) {
      await authProvider.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      await authProvider.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }

    if (!mounted) {
      return;
    }

    if (authProvider.isSignedIn && authProvider.errorMessage == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const HomeShell(),
        ),
      );
      return;
    }

    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
    }
  }

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
              Text(
                _isRegistering ? 'Create Account' : 'Sign In',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 14),
              Text(
                _isRegistering
                    ? 'Create an account with your email to get started'
                    : 'Sign in with your email address and password',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              GlassCard(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email address',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !authProvider.isSigningIn,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      obscureText: _obscurePassword,
                      enabled: !authProvider.isSigningIn,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (authProvider.errorMessage != null)
                GlassCard(
                  child: Text(
                    authProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                )
              else
                SizedBox.fromSize(size: Size.zero),
              const SizedBox(height: 22),
              GradientButton(
                label: authProvider.isSigningIn
                    ? (_isRegistering
                        ? 'Creating account...'
                        : 'Signing in...')
                    : (_isRegistering ? 'Create Account' : 'Sign In'),
                icon: _isRegistering ? Icons.person_add_rounded : Icons.login_rounded,
                onPressed: authProvider.isSigningIn
                    ? null
                    : () => _handleSignIn(authProvider),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: authProvider.isSigningIn
                      ? null
                      : () {
                          setState(() {
                            _isRegistering = !_isRegistering;
                            authProvider.clearError();
                            _emailController.clear();
                            _passwordController.clear();
                          });
                        },
                  child: Text(
                    _isRegistering
                        ? 'Already have an account? Sign In'
                        : "Don't have an account? Create one",
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back to Google Sign In'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
