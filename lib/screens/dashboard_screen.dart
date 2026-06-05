import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/page_routes.dart';
import '../utils/time_utils.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/status_pill.dart';
import 'permissions_screen.dart';
import 'schedule_screen.dart';

import '../services/analytics_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    final String? userId = context.read<AuthProvider>().user?.uid;
    AnalyticsService.instance.logDashboardView(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, AppStateProvider>(
      builder:
          (
            BuildContext context,
            AuthProvider authProvider,
            AppStateProvider appState,
            Widget? child,
          ) {
            final DateTime now = DateTime.now();
            final String userName =
                authProvider.user?.displayName?.split(' ').first ??
                'Freelancer';
            final bool insideWindow = appState.settings.schedule.contains(now);
            final bool fullyConfigured =
                appState.permissionState.completedCount >= 4;
            final String headline = !appState.settings.monitoringEnabled
                ? 'Monitoring is paused'
                : !fullyConfigured
                ? 'Finish setup to arm background detection'
                : insideWindow
                ? 'Alerts are armed for your current shift'
                : 'Waiting for your next monitoring window';

            return RefreshIndicator(
              onRefresh: appState.refreshPermissions,
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
                children: <Widget>[
                  Text(
                    '${TimeUtils.greetingFor(now)}, $userName',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Fiverr response cockpit',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 18),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Current status',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    headline,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                appState.toggleMonitoring(
                                  !appState.settings.monitoringEnabled,
                                );
                              },
                              icon: Icon(
                                appState.settings.monitoringEnabled
                                    ? Icons.pause_circle_outline_rounded
                                    : Icons.play_circle_outline_rounded,
                              ),
                              label: Text(
                                appState.settings.monitoringEnabled
                                    ? 'Turn off monitoring'
                                    : 'Turn on monitoring',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: <Widget>[
                            StatusPill(
                              label: appState.settings.monitoringEnabled
                                  ? 'Monitoring on'
                                  : 'Monitoring off',
                              color: appState.settings.monitoringEnabled
                                  ? AppColors.emerald
                                  : AppColors.warning,
                              icon: appState.settings.monitoringEnabled
                                  ? Icons.check_circle_rounded
                                  : Icons.pause_circle_outline_rounded,
                            ),
                            StatusPill(
                              label: TimeUtils.formatSchedule(
                                context,
                                appState.settings.schedule,
                              ),
                              color: Theme.of(context).colorScheme.primary,
                              icon: Icons.schedule_rounded,
                            ),
                            StatusPill(
                              label:
                                  '${appState.permissionState.completedCount}/5 permissions ready',
                              color: fullyConfigured
                                  ? AppColors.emerald
                                  : AppColors.warning,
                              icon: Icons.shield_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: GradientButton(
                                label: 'Run alarm test',
                                icon: Icons.sensors_rounded,
                                onPressed: appState.runFullAlarmTest,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: GlassCard(
                          onTap: () {
                            Navigator.of(context).push(
                              buildFadeRoute<void>(const ScheduleScreen()),
                            );
                          },
                          child: _QuickMetric(
                            title: 'Active hours',
                            value: TimeUtils.formatSchedule(
                              context,
                              appState.settings.schedule,
                            ),
                            icon: Icons.access_time_filled_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: GlassCard(
                          onTap: () {
                            Navigator.of(context).push(
                              buildFadeRoute<void>(const PermissionsScreen()),
                            );
                          },
                          child: _QuickMetric(
                            title: 'Permissions',
                            value:
                                '${appState.permissionState.completedCount}/5 ready',
                            icon: Icons.fact_check_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                'Last detected Fiverr activity',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            if (appState.lastNotification != null)
                              StatusPill(
                                label: appState.lastNotification!.type
                                    .toUpperCase(),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (appState.lastNotification == null)
                          Text(
                            'No Fiverr activity has been detected on this device yet. Once the native listener catches a notification, it will appear here.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                appState.lastNotification!.displayTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                appState.lastNotification!.displayBody,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                TimeUtils.formatDateTime(
                                  appState.lastNotification!.receivedAt,
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Permission checklist',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 14),
                        _ChecklistRow(
                          title: 'Notification access',
                          ready: appState
                              .permissionState
                              .notificationListenerEnabled,
                        ),
                        _ChecklistRow(
                          title: 'Post notifications',
                          ready:
                              appState.permissionState.postNotificationsGranted,
                        ),
                        _ChecklistRow(
                          title: 'Battery optimization excluded',
                          ready: appState
                              .permissionState
                              .batteryOptimizationIgnored,
                        ),
                        _ChecklistRow(
                          title: 'Exact alarms enabled',
                          ready: appState.permissionState.exactAlarmGranted,
                        ),
                        _ChecklistRow(
                          title: 'Full-screen intents allowed',
                          ready:
                              appState.permissionState.fullScreenIntentGranted,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              buildFadeRoute<void>(const PermissionsScreen()),
                            );
                          },
                          icon: const Icon(Icons.tune_rounded),
                          label: const Text('Review setup'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }
}

class _QuickMetric extends StatelessWidget {
  const _QuickMetric({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.title, required this.ready});

  final String title;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: <Widget>[
          Icon(
            ready ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: ready ? AppColors.emerald : AppColors.warning,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
    );
  }
}
