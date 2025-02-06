import 'package:flutter/material.dart';

class QuickActionDialog extends StatelessWidget {
  const QuickActionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Quick Actions"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.add_task),
            title: const Text("New Task"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.computer),
            title: const Text("Add Server"),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}