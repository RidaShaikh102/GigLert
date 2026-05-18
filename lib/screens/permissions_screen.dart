import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_backdrop.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/status_pill.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (BuildContext context, AppStateProvider appState, Widget? child) {
        return AppBackdrop(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(title: const Text('Android Permissions')),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: <Widget>[
                Text(
                  'These Android permissions and settings keep the notification listener, foreground monitoring, full-screen alerts, and snooze alarms reliable.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _PermissionRow(
                        title: 'Post notifications',
                        body:
                            'Required on Android 13+ so setup reminders and helper notifications can appear.',
                        ready:
                            appState.permissionState.postNotificationsGranted,
                        actionLabel: 'Request bundle',
                        onTap: appState.requestNotificationBundle,
                      ),
                      const SizedBox(height: 18),
                      _PermissionRow(
                        title: 'Notification access',
                        body:
                            'Allows the native listener service to detect notifications from the official Fiverr Android app.',
                        ready: appState
                            .permissionState
                            .notificationListenerEnabled,
                        actionLabel: 'Open settings',
                        onTap: appState.openNotificationAccessSettings,
                      ),
                      const SizedBox(height: 18),
                      _PermissionRow(
                        title: 'Battery optimization exclusion',
                        body:
                            'Prevents aggressive vendors from killing the monitoring service during active work hours.',
                        ready:
                            appState.permissionState.batteryOptimizationIgnored,
                        actionLabel: 'Open battery settings',
                        onTap: appState.openBatteryOptimizationSettings,
                      ),
                      const SizedBox(height: 18),
                      _PermissionRow(
                        title: 'Exact alarms',
                        body:
                            'Needed for accurate snooze wakeups and re-alert timing.',
                        ready: appState.permissionState.exactAlarmGranted,
                        actionLabel: 'Open alarm settings',
                        onTap: appState.openExactAlarmSettings,
                      ),
                      const SizedBox(height: 18),
                      _PermissionRow(
                        title: 'Full-screen intents',
                        body:
                            'Allows the alarm activity to appear over the lock screen when a Fiverr alert arrives.',
                        ready: appState.permissionState.fullScreenIntentGranted,
                        actionLabel: 'Request bundle',
                        onTap: appState.requestNotificationBundle,
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
                        'If Android blocks notification access',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'On Android 13 and newer, sideloaded apps can be treated as restricted until you explicitly trust them. Open GigLert in system App info, tap the three-dot menu, choose Allow restricted settings, then return here and enable Notification access again.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'If Google Play Protect blocks the APK during installation, use a properly signed release build or distribute it through Google Play / Internal App Sharing instead of installing from Downloads or chat apps.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: <Widget>[
                          OutlinedButton.icon(
                            onPressed: appState.openAppDetailsSettings,
                            icon: const Icon(Icons.settings_rounded),
                            label: const Text('Open app info'),
                          ),
                          OutlinedButton.icon(
                            onPressed: appState.openNotificationAccessSettings,
                            icon: const Icon(
                              Icons.notifications_active_rounded,
                            ),
                            label: const Text('Retry notification access'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                GradientButton(
                  label: 'Refresh permission status',
                  icon: Icons.refresh_rounded,
                  onPressed: appState.refreshPermissions,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.title,
    required this.body,
    required this.ready,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String body;
  final bool ready;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            StatusPill(
              label: ready ? 'Ready' : 'Action needed',
              color: ready ? AppColors.emerald : AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(body, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}
