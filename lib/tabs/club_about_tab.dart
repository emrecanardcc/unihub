import 'package:flutter/material.dart';
import '../utils/glass_components.dart';

class ClubAboutTab extends StatelessWidget {
  final String description;

  const ClubAboutTab({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: AuraGlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 28,
        child: Text(
          description,
          style: TextStyle(
            fontSize: 16,
            height: 1.8,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
