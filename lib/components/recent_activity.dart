// components/recent_activity.dart
import 'package:flutter/material.dart';
import 'package:nofliesynck/components/presentations/activities_card.dart';
import 'package:nofliesynck/model_general/activity_item.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      ActivityItem(
        icon: Icons.backup,
        title: "Backup Completed",
        subtitle: "Server backup finished successfully",
        time: "2 mins ago",
        color: Colors.green,
      ),
      ActivityItem(
        icon: Icons.warning,
        title: "High CPU Usage",
        subtitle: "Server CPU usage exceeded 80%",
        time: "15 mins ago",
        color: Colors.orange,
      ),
      ActivityItem(
        icon: Icons.security,
        title: "Security Update",
        subtitle: "System security patches installed",
        time: "1 hour ago",
        color: Colors.blue,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Activity",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => ActivityCard(activity: activities[index]),
          ),
        ],
      ),
    );
  }
}
