// components/header.dart
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "NOFLIE SYNCK",
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "System Administration Dashboard",
            style: TextStyle(
              color: Colors.black12.withValues(alpha: 0.9),
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          const SearchBar(),
        ],
      ),
    );
  }
}
