import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../utils/glass_components.dart';

class EventDetailPage extends StatelessWidget {
  final EventModel event;
  final String? clubName;
  final Color? accentColor;

  const EventDetailPage({
    super.key,
    required this.event,
    this.clubName,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = accentColor ?? Colors.cyanAccent;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color onSurface = colorScheme.onSurface;
    final Color muted = onSurface.withValues(alpha: 0.6);
    final Color subtle = onSurface.withValues(alpha: 0.4);
    final String dateText = DateFormat('d MMMM yyyy', 'tr_TR').format(event.startTime);
    final String timeText = DateFormat('HH:mm').format(event.startTime);

    return AuraScaffold(
      auraColor: color,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.chevron_left_rounded, color: onSurface, size: 32),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '$dateText • $timeText',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  event.title,
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                if (clubName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    clubName!,
                    style: TextStyle(
                      color: muted,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: AuraGlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              borderRadius: 32,
              accentColor: color,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.place_rounded, color: onSurface.withValues(alpha: 0.7), size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              color: onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "ETKİNLİK DETAYI",
                      style: TextStyle(
                        color: subtle,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.description,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.8),
                        fontSize: 16,
                        height: 1.7,
                      ),
                    ),
                    if (event.speakers.isNotEmpty) ...[
                      const SizedBox(height: 40),
                      Text(
                        "KONUŞMACILAR",
                        style: TextStyle(
                          color: subtle,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: event.speakers.map((s) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AuraGlassCard(
                              padding: const EdgeInsets.all(16),
                              borderRadius: 20,
                              accentColor: onSurface.withValues(alpha: 0.2),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colorScheme.surface.withValues(alpha: 0.9),
                                    ),
                                    child: Icon(Icons.person_rounded, color: onSurface, size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.fullName,
                                          style: TextStyle(
                                            color: onSurface,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (s.bio != null && s.bio!.isNotEmpty)
                                          Text(
                                            s.bio!,
                                            style: TextStyle(
                                              color: muted,
                                              fontSize: 13,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
