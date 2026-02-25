import 'package:flutter/material.dart';
import '../utils/glass_components.dart';

class EventListTile extends StatelessWidget {
  final String title;
  final String description;
  final Color themeColor;

  const EventListTile({
    super.key,
    required this.title,
    required this.description,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AuraGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      accentColor: themeColor,
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.calendar_month, color: themeColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(
          description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
