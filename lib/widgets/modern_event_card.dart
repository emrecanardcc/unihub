import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../utils/modern_theme.dart';
import 'modern_glass_card.dart';

class ModernEventCard extends StatelessWidget {
  final EventModel event;
  final String? clubName;
  final Color? accentColor;
  final VoidCallback? onTap;

  const ModernEventCard({
    super.key,
    required this.event,
    this.clubName,
    this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = accentColor ?? ModernTheme.primaryCyan;
    final dateText = DateFormat('d MMMM yyyy', 'tr_TR').format(event.startTime);
    final timeText = DateFormat('HH:mm').format(event.startTime);
    final hasSpeakers = event.speakers.isNotEmpty;

    return ModernGlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and time
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        themeColor.withValues(alpha: 0.8),
                        themeColor.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$dateText • $timeText',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                if (hasSpeakers)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people,
                          color: themeColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${event.speakers.length}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Event title
            Text(
              event.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Event description
            Text(
              event.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: themeColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.location,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
                if (clubName != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: themeColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      clubName!,
                      style: TextStyle(
                        color: themeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (hasSpeakers) ...[
              const SizedBox(height: 12),
              // Speakers preview
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: Stack(
                        children: [
                          for (int i = 0; i < event.speakers.length && i < 3; i++)
                            Positioned(
                              left: i * 20,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: themeColor.withValues(alpha: 0.2),
                                  border: Border.all(
                                    color: themeColor,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    event.speakers[i].fullName.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      color: themeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (event.speakers.length > 3)
                            Positioned(
                              left: 60,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.1),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '+${event.speakers.length - 3}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 14,
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 14,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}