import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';
import '../widgets/app_backdrop.dart';
import '../widgets/app_logo.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/status_pill.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  static const List<_OnboardingPageData> _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      title: 'Never miss a Fiverr buyer again',
      body:
          'GigLert turns urgent Fiverr notifications into impossible-to-miss alarms built for freelancers who cannot afford late replies.',
      eyebrow: 'Welcome',
      icon: Icons.rocket_launch_rounded,
      chipLabel: 'Startup-ready MVP',
    ),
    _OnboardingPageData(
      title: 'Detection works through Android notification access',
      body:
          'The app listens only for the official Fiverr package and extracts message, order, and reply details without reacting to unrelated apps. All detected Fiverr notification metadata is kept on your phone and is not shared externally, for privacy and security.',
      eyebrow: 'How it works',
      icon: Icons.notifications_active_rounded,
      chipLabel: 'com.fiverr.fiverr',
    ),
    _OnboardingPageData(
      title: 'Alert only during your selected work window',
      body:
          'Choose the hours when you want to be reachable. Outside that schedule, GigLert keeps logging activity but stays quiet.',
      eyebrow: 'Smart scheduling',
      icon: Icons.schedule_rounded,
      chipLabel: 'Custom active hours',
    ),
    _OnboardingPageData(
      title: 'Grant notification access for reliable detection',
      body:
          'Android requires a one-time permission so the native listener can receive Fiverr alerts in the background. If Android says the setting is restricted for security reasons, first allow restricted settings from GigLert app info, then return and enable notification access.',
      eyebrow: 'Permission setup',
      icon: Icons.shield_outlined,
      chipLabel: 'Required',
      actionLabel: 'Open notification access',
    ),
    _OnboardingPageData(
      title: 'Allow battery exemptions for long-running monitoring',
      body:
          'Some devices aggressively stop background services. Battery optimization exclusions keep alarms dependable during client hours.',
      eyebrow: 'Battery guidance',
      icon: Icons.battery_charging_full_rounded,
      chipLabel: 'Recommended',
      actionLabel: 'Open battery settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next(AppStateProvider appState) async {
    if (_currentPage == _pages.length - 1) {
      await appState.completeOnboarding();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppStateProvider appState = context.read<AppStateProvider>();

    return AppBackdrop(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          children: <Widget>[
            const Row(children: <Widget>[AppLogo(showWordmark: true)]),
            const SizedBox(height: 20),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  final _OnboardingPageData page = _pages[index];

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  StatusPill(
                                    label: page.chipLabel,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    icon: Icons.auto_awesome_rounded,
                                  ),
                                  const SizedBox(height: 22),
                                  Container(
                                    width: 86,
                                    height: 86,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.14),
                                    ),
                                    child: Icon(
                                      page.icon,
                                      size: 42,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    page.eyebrow,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    page.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displayMedium,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    page.body,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                  if (page.actionLabel != null) ...<Widget>[
                                    const SizedBox(height: 24),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        if (index == 3) {
                                          await appState
                                              .openNotificationAccessSettings();
                                        } else if (index == 4) {
                                          await appState
                                              .openBatteryOptimizationSettings();
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.open_in_new_rounded,
                                      ),
                                      label: Text(page.actionLabel!),
                                    ),
                                  ],
                                  if (index == 3) ...<Widget>[
                                    const SizedBox(height: 12),
                                    Text(
                                      'Tip: If you installed the APK outside Google Play and Android shows a security warning, open App info, tap the three-dot menu, and choose Allow restricted settings.',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 12),
                                    OutlinedButton.icon(
                                      onPressed:
                                          appState.openAppDetailsSettings,
                                      icon: const Icon(Icons.settings_rounded),
                                      label: const Text('Open app info'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                _pages.length,
                (int index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            GradientButton(
              label: _currentPage == _pages.length - 1
                  ? 'Continue to sign in'
                  : 'Next',
              onPressed: () => _next(appState),
              icon: Icons.arrow_forward_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.body,
    required this.eyebrow,
    required this.icon,
    required this.chipLabel,
    this.actionLabel,
  });

  final String title;
  final String body;
  final String eyebrow;
  final IconData icon;
  final String chipLabel;
  final String? actionLabel;
}
