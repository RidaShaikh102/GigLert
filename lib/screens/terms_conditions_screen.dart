import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
          Text(title, style: Theme.of(context).textTheme.titleLarge),
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
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          children: <Widget>[
            Text(
              'By using Giglert, you agree to these terms. Giglert is a Fiverr notification monitoring tool that helps you stay on top of important messages, orders, revisions, cancellations, and buyer activity.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            buildSection(
              context,
              title: 'Use of the app',
              paragraphs: <String>[
                'Giglert is provided for personal use to monitor Fiverr notifications and deliver alerting functionality. Your continued use of the app means you accept the required permissions and the way the app processes notification metadata.',
                'The app is not affiliated with Fiverr and does not replace Fiverr’s official app or website.',
              ],
            ),
            buildSection(
              context,
              title: 'Permissions and access',
              paragraphs: <String>[
                'Giglert requests notification access so it can monitor notification events and trigger alerts for relevant Fiverr activity based on your settings. You control this access in your Android app settings.',
                'Giglert may also request notification posting, exact alarm, full-screen intent, and battery optimization exemption permissions to keep alerting reliable on Android devices. These permissions are part of the core monitoring experience.',
              ],
            ),

            buildSection(
              context,
              title: 'Local data storage',
              paragraphs: <String>[
                'Giglert stores your preferences, schedule settings, and optional alert history locally on your device. If you sign in and enable cloud sync, the app may also store profile details and preference settings in Firebase Firestore.',
                'You can disable cloud sync anytime and continue to use the app with local-only notification monitoring.',
              ],
            ),
            buildSection(
              context,
              title: 'No guarantee',
              paragraphs: <String>[
                'While the app is designed to support Fiverr notification monitoring, we cannot guarantee that every notification will be detected. Notification delivery and app behavior may vary based on the device, operating system version, and third-party apps.',
                'You are responsible for maintaining the necessary permissions and notification access to keep the app working. If permissions are revoked, Giglert may not be able to detect alerts reliably.',
              ],
            ),
            buildSection(
              context,
              title: 'Disclaimer',
              paragraphs: <String>[
                'Giglert is provided as-is without warranties. To the fullest extent permitted by law, we disclaim liability for any direct or indirect damages arising from the use of the app, including missed Fiverr activity or incorrect notifications.',
              ],
            ),
            buildSection(
              context,
              title: 'Changes to terms',
              paragraphs: <String>[
                'We may update these terms to reflect app improvements and changes in how data is handled. Continued use after changes indicates acceptance of the updated terms.',
              ],
            ),
          ],
        ),
      ),
    );
  }
}
