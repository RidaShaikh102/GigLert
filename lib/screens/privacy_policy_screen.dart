import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget buildSection(
    BuildContext context, {
    required String title,
    required List<String> paragraphs,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ...paragraphs.map(
            (String paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                paragraph,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          children: <Widget>[
            Text(
              'Giglert is a notification monitoring tool built to help Fiverr sellers notice important messages, orders, revisions, cancellations, and buyer activity faster. Our privacy approach is designed around local device processing and explicit user control.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            buildSection(
              context,
              title: 'Notification access',
              paragraphs: <String>[
                'The app requests Android notification access so it can detect incoming Fiverr notifications in real time. This access is used to read notification metadata such as title, body text, package name, and arrival time only when a notification appears.',
                'We use this information to classify Fiverr activity, decide whether to trigger an alert, and present the alert details inside the app. Notification data is processed on-device and is not shared with third parties except as described in this policy.',
              ],
            ),
            buildSection(
              context,
              title: 'Local storage',
              paragraphs: <String>[
                'Giglert stores your monitoring preferences, schedule settings, sound and vibration choices, and optional alert history on your device using shared preferences. This lets the app remember your settings and keep alarms working consistently.',
                'Local storage is the default behavior. Even without signing in, you can use the app and keep your Fiverr notification monitoring working locally.',
              ],
            ),
            buildSection(
              context,
              title: 'Optional cloud sync',
              paragraphs: <String>[
                'Signing in with Google enables optional cloud sync to store app preferences and account profile details. If you enable cloud sync, we store your display name, email, photo URL, and preferences in Firebase Firestore so your settings can follow you across devices.',
                'We do not send full notification content to the cloud as part of the current preferences sync flow. Cloud sync is optional and can be turned off at any time in settings.',
              ],
            ),
            buildSection(
              context,
              title: 'Why other permissions are needed',
              paragraphs: <String>[
                'Notification permission allows the app to present local alerts and setup reminders. We also request exact alarm and full-screen intent permissions to make sure Fiverr alerts can wake the device reliably when you need them most.',
                'Battery optimization exclusion is suggested so the alarm and notification listener remain active while your phone is idle. This permission is only requested to keep the monitoring experience dependable, not to collect extra data.',
              ],
            ),
            buildSection(
              context,
              title: 'No analytics or ads',
              paragraphs: <String>[
                'Giglert does not collect analytics data or serve advertisements. The app is built to minimize data collection and keep Fiverr notification monitoring focused on your device.',
              ],
            ),
            buildSection(
              context,
              title: 'Changes to this policy',
              paragraphs: <String>[
                'We may update this privacy policy to reflect improvements in the app or changes in data handling. If the app changes how it uses notification data or cloud sync, we will clearly update this policy.',
              ],
            ),
          ],
        ),
      ),
    );
  }
}
