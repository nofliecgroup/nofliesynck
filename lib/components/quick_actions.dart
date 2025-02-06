// components/quick_actions_panel.dart
import 'package:flutter/material.dart';

class QuickActionsPanel extends StatelessWidget {
  const QuickActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickActionCard(
                  icon: Icons.backup,
                  label: 'Backup',
                  color: Colors.blue,
                  onTap: () {
                    // Implement backup action
                  },
                ),
                const SizedBox(width: 16),
                _QuickActionCard(
                  icon: Icons.cloud_upload,
                  label: 'Sync',
                  color: Colors.green,
                  onTap: () {
                    // Implement sync action
                  },
                ),
                const SizedBox(width: 16),
                _QuickActionCard(
                  icon: Icons.settings,
                  label: 'Configure',
                  color: Colors.orange,
                  onTap: () {
                    // Implement configuration action
                  },
                ),
                const SizedBox(width: 16),
                _QuickActionCard(
                  icon: Icons.auto_fix_high,
                  label: 'Optimize',
                  color: Colors.purple,
                  onTap: () {
                    // Implement optimization action
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}