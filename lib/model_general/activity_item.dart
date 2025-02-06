// models/activity_item.dart
import 'package:flutter/material.dart';

class ActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });
}

// components/search_bar.dart
class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search servers, tasks, or commands...",
          hintStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 14,
          ),
          icon: Icon(
            Icons.search,
            color: Theme.of(context).hintColor,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
