import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../models/ringtone_profile.dart';
import '../providers/app_state_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/page_routes.dart';
import '../utils/time_utils.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/setting_tile.dart';
import 'permissions_screen.dart';
import 'schedule_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppStateProvider, AuthProvider>(
      builder:
          (
            BuildContext context,
            AppStateProvider appState,
            AuthProvider authProvider,
            Widget? child,
          ) {
            Widget buildSmartToggle({
              required String title,
              String? subtitle,
              required bool value,
              required ValueChanged<bool> onChanged,
            }) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (subtitle != null) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: value,
                      onChanged: onChanged,
                    ),
                  ],
                ),
              );
            }

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
              children: <Widget>[
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tune the alarm, theme, schedule, and Android reliability settings for your Fiverr workflow.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Monitoring schedule',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      SettingTile(
                        icon: Icons.schedule_rounded,
                        title: 'Active hours',
                        subtitle: TimeUtils.formatSchedule(
                          context,
                          appState.settings.schedule,
                        ),
                        onTap: () {
                          Navigator.of(
                            context,
                          ).push(buildFadeRoute<void>(const ScheduleScreen()));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Smart Detection',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Pick the Fiverr alerts that matter most, with privacy-first local storage and optional cloud preference sync.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Trigger alerts for',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      buildSmartToggle(
                        title: 'New Messages',
                        subtitle: 'Catch new Fiverr replies even when your phone is away.',
                        value: appState.settings.notifyNewMessages,
                        onChanged: appState.updateNotifyNewMessages,
                      ),
                      buildSmartToggle(
                        title: 'New Orders',
                        subtitle: 'Alert on fresh Fiverr orders immediately.',
                        value: appState.settings.notifyNewOrders,
                        onChanged: appState.updateNotifyNewOrders,
                      ),
                      buildSmartToggle(
                        title: 'Buyer Requests',
                        subtitle: 'Stay on top of buyer requests for faster turnaround.',
                        value: appState.settings.notifyBuyerRequests,
                        onChanged: appState.updateNotifyBuyerRequests,
                      ),
                      buildSmartToggle(
                        title: 'Custom Offers',
                        subtitle: 'Know when buyers send custom opportunities.',
                        value: appState.settings.notifyCustomOffers,
                        onChanged: appState.updateNotifyCustomOffers,
                      ),
                      buildSmartToggle(
                        title: 'Revisions',
                        subtitle: 'Get notified when a buyer asks for a revision.',
                        value: appState.settings.notifyRevisions,
                        onChanged: appState.updateNotifyRevisions,
                      ),
                      buildSmartToggle(
                        title: 'Cancellations',
                        subtitle: 'Receive alerts on cancellations so you can respond fast.',
                        value: appState.settings.notifyCancellations,
                        onChanged: appState.updateNotifyCancellations,
                      ),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      Text(
                        'Additional filters',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      buildSmartToggle(
                        title: 'Only Important Notifications',
                        subtitle: 'Keep the noise down and stay focused on urgent Fiverr alerts.',
                        value: appState.settings.onlyImportantNotifications,
                        onChanged: appState.updateOnlyImportantNotifications,
                      ),
                      buildSmartToggle(
                        title: 'Keyword-Based Detection',
                        subtitle: 'Scan Fiverr notifications for keywords you care about.',
                        value: appState.settings.keywordDetectionEnabled,
                        onChanged: appState.updateKeywordDetection,
                      ),
                      buildSmartToggle(
                        title: 'Repeat Alerts for Urgent Messages',
                        subtitle: 'Reinforce high-priority Fiverr messages until you acknowledge them.',
                        value: appState.settings.repeatUrgentMessages,
                        onChanged: appState.updateRepeatUrgentMessages,
                      ),
                      buildSmartToggle(
                        title: 'Full-Screen Alarm',
                        subtitle: 'Show a strong alert that cuts through sleep and busy moments.',
                        value: appState.settings.fullScreenAlarm,
                        onChanged: appState.updateFullScreenAlarm,
                      ),
                      buildSmartToggle(
                        title: 'Strong Alerts During Sleep Hours',
                        subtitle: 'Boost reliability while you are away from the phone at night.',
                        value: appState.settings.strongSleepAlerts,
                        onChanged: appState.updateStrongSleepAlerts,
                      ),
                      const Divider(height: 1),
                      const SizedBox(height: 16),
                      buildSmartToggle(
                        title: 'Cloud Sync',
                        subtitle: 'Optional backup and setting sync across devices. Disabled by default.',
                        value: appState.settings.cloudSyncEnabled,
                        onChanged: appState.updateCloudSync,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your Fiverr notifications stay on your device by default.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Alarm experience',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Vibration',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Keep vibrating until the alert is stopped or snoozed.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: appState.settings.vibrationEnabled,
                            onChanged: appState.updateVibration,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Ringtone preset',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: RingtoneProfile.presets.map((
                          RingtoneProfile preset,
                        ) {
                          return ChoiceChip(
                            label: Text(preset.title),
                            selected: appState.settings.ringtoneId == preset.id,
                            onSelected: (_) =>
                                appState.updateRingtone(preset.id),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        RingtoneProfile.byId(
                          appState.settings.ringtoneId,
                        ).description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Alarm volume',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Slider(
                        value: appState.settings.alarmVolume,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        label:
                            '${(appState.settings.alarmVolume * 100).round()}%',
                        onChanged: appState.updateAlarmVolume,
                      ),
                      Text(
                        'Repeat focus pulse every ${appState.settings.repeatSeconds}s while the alert stays active.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Slider(
                        value: appState.settings.repeatSeconds.toDouble(),
                        min: 10,
                        max: 60,
                        divisions: 10,
                        label: '${appState.settings.repeatSeconds}s',
                        onChanged: (double value) =>
                            appState.updateRepeatSeconds(value.round()),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Snooze duration',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <int>[3, 5, 10, 15].map((int minutes) {
                          return ChoiceChip(
                            label: Text('$minutes min'),
                            selected:
                                appState.settings.snoozeMinutes == minutes,
                            onSelected: (_) =>
                                appState.updateSnoozeMinutes(minutes),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                              final bool narrow = constraints.maxWidth < 420;

                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.start,
                                children: <Widget>[
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: narrow
                                          ? constraints.maxWidth
                                          : 0,
                                      maxWidth: narrow
                                          ? constraints.maxWidth
                                          : (constraints.maxWidth / 2) - 6,
                                    ),
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(0, 56),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                      ),
                                      onPressed: appState.isPreviewPlaying
                                          ? appState.stopTonePreview
                                          : appState.previewTone,
                                      icon: Icon(
                                        appState.isPreviewPlaying
                                            ? Icons.stop_circle_outlined
                                            : Icons.play_arrow_rounded,
                                      ),
                                      label: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          appState.isPreviewPlaying
                                              ? 'Stop preview'
                                              : 'Preview tone',
                                        ),
                                      ),
                                    ),
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: narrow
                                          ? constraints.maxWidth
                                          : 0,
                                      maxWidth: narrow
                                          ? constraints.maxWidth
                                          : (constraints.maxWidth / 2) - 6,
                                    ),
                                    child: GradientButton(
                                      isExpanded: false,
                                      label: 'Full alarm test',
                                      icon: Icons.alarm_on_rounded,
                                      onPressed: appState.runFullAlarmTest,
                                    ),
                                  ),
                                ],
                              );
                            },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Theme and guidance',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<AppThemePreference>(
                        key: ValueKey<AppThemePreference>(
                          appState.settings.themePreference,
                        ),
                        initialValue: appState.settings.themePreference,
                        decoration: const InputDecoration(
                          labelText: 'Appearance',
                        ),
                        items: AppThemePreference.values.map((
                          AppThemePreference preference,
                        ) {
                          return DropdownMenuItem<AppThemePreference>(
                            value: preference,
                            child: Text(preference.label),
                          );
                        }).toList(),
                        onChanged: (AppThemePreference? preference) {
                          if (preference != null) {
                            appState.updateTheme(preference);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      SettingTile(
                        icon: Icons.tips_and_updates_rounded,
                        title: 'Permissions and battery setup',
                        subtitle: 'Review Android reliability settings.',
                        onTap: () {
                          Navigator.of(context).push(
                            buildFadeRoute<void>(const PermissionsScreen()),
                          );
                        },
                      ),
                      SettingTile(
                        icon: Icons.auto_stories_rounded,
                        title: 'Replay onboarding',
                        subtitle: 'Open the setup walkthrough again.',
                        onTap: appState.resetOnboarding,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Account',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      if (authProvider.user != null)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundImage: authProvider.user?.photoURL != null
                                ? NetworkImage(authProvider.user!.photoURL!)
                                : null,
                            child: authProvider.user?.photoURL == null
                                ? const Icon(Icons.person_rounded)
                                : null,
                          ),
                          title: Text(
                            authProvider.user?.displayName ?? 'Google user',
                          ),
                          subtitle: Text(authProvider.user?.email ?? ''),
                        ),
                      OutlinedButton.icon(
                        onPressed: authProvider.signOut,
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Sign out'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
    );
  }
}
