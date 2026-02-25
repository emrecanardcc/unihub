import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/glass_components.dart';

class BadgeGrid extends StatelessWidget {
  final String clubId;
  final String userId;
  final Color themeColor;

  const BadgeGrid({
    super.key,
    required this.clubId,
    required this.userId,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('badges')
          .select()
          .eq('club_id', clubId)
          .eq('user_id', userId)
          .asStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return AuraGlassCard(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            accentColor: themeColor.withValues(alpha: 0.5),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 40,
                  color: Colors.white54,
                ),
                const SizedBox(height: 5),
                const Text(
                  "Henüz kazanılmış rozet yok.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8,
          ),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var badge = snapshot.data![index];
            return AuraGlassCard(
              padding: EdgeInsets.zero,
              accentColor: themeColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.star, color: themeColor, size: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badge['badgeName'] ?? 'Rozet',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
