import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notification_record.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';
import '../utils/time_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_pill.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (BuildContext context, AppStateProvider appState, Widget? child) {
        if (appState.alerts.isEmpty) {
          return ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            children: const <Widget>[
              EmptyState(
                icon: Icons.inbox_outlined,
                title: 'No Fiverr activity yet',
                subtitle:
                    'When Fiverr notifications are detected, your recent activity timeline will appear here.',
              ),
            ],
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
          itemCount: appState.alerts.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Recent Fiverr detections',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A rolling activity feed of messages, orders, replies, and any other Fiverr notifications captured by the listener service.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
            }

            final NotificationRecord record = appState.alerts[index - 1];
            return GlassCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _iconForType(record.type),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                record.displayTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            StatusPill(
                              label: record.alarmTriggered
                                  ? 'Alarm fired'
                                  : 'Logged only',
                              color: record.alarmTriggered
                                  ? AppColors.emerald
                                  : AppColors.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          record.displayBody,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          TimeUtils.formatDateTime(record.receivedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'message':
        return Icons.chat_bubble_rounded;
      case 'order':
        return Icons.shopping_bag_rounded;
      case 'reply':
        return Icons.reply_all_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }
}
