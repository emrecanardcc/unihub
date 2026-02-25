import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../utils/glass_components.dart';
import '../models/event.dart';
import '../services/database_service.dart';
import 'event_detail_page.dart';
import '../widgets/aura_pull_to_refresh.dart';

class ClubEventsTab extends StatefulWidget {
  final String kulupId;
  final Color primaryColor;

  const ClubEventsTab({
    super.key,
    required this.kulupId,
    required this.primaryColor,
  });

  @override
  State<ClubEventsTab> createState() => _ClubEventsTabState();
}

class _ClubEventsTabState extends State<ClubEventsTab> {
  final DatabaseService _dbService = DatabaseService();
  bool _eventsLoading = false;
  List<EventModel> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _eventsLoading = true);
    try {
      final events = await _dbService.getClubEvents(int.parse(widget.kulupId));
      if (mounted) {
        setState(() {
          _events = events;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Etkinlikler yüklenemedi: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _eventsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuraPullToRefresh(
      onRefresh: _loadEvents,
      accentColor: widget.primaryColor,
      child: _eventsLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                  itemCount: _events.length,
                  itemBuilder: (context, index) => _buildEventCard(_events[index]),
                ),
    );
  }

  Widget _buildEmptyState() {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_rounded, size: 64, color: onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            "Henüz Sahne Alan Etkinlik Yok",
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.6),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    final dateText = DateFormat('d MMM yyyy', 'tr_TR').format(event.startTime);
    final timeText = DateFormat('HH:mm').format(event.startTime);
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    final Color muted = onSurface.withValues(alpha: 0.6);
    final Color subtle = onSurface.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AuraGlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        accentColor: widget.primaryColor,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailPage(
                event: event,
                accentColor: widget.primaryColor,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: widget.primaryColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          dateText,
                          style: TextStyle(
                            color: widget.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeText,
                        style: TextStyle(
                          color: subtle,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: muted,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
