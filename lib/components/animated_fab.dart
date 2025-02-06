// components/animated_fab.dart
import 'package:flutter/material.dart';

class AnimatedFloatingActionButton extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final VoidCallback onPressed;

  const AnimatedFloatingActionButton({
    super.key,
    required this.fadeAnimation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: fadeAnimation,
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: const Text("Quick Action"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}