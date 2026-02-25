import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unihub/utils/hex_color.dart';
import 'package:unihub/widget/sponsor_banner.dart';
import 'package:unihub/utils/glass_components.dart';
import 'package:unihub/tabs/club_detail_page.dart';
import 'package:unihub/services/database_service.dart';
import 'package:unihub/models/club.dart';
import 'package:unihub/models/app_enums.dart';
import 'package:unihub/widgets/aura_pull_to_refresh.dart';
import 'package:unihub/widgets/staggered_item.dart';

class MyClubsTab extends StatefulWidget {
  const MyClubsTab({super.key});

  @override
  State<MyClubsTab> createState() => _MyClubsTabState();
}

class _MyClubsTabState extends State<MyClubsTab> {
  final DatabaseService _dbService = DatabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _myClubs = [];

  @override
  void initState() {
    super.initState();
    _loadMyClubs();
  }

  Future<void> _loadMyClubs() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      // Fetch both approved and pending clubs
      final results = await Future.wait([
        _dbService.getUserClubs(user.id),
        _dbService.getUserPendingRequests(user.id),
      ]);

      final approvedData = results[0];
      final pendingData = results[1];
      
      List<Map<String, dynamic>> processedClubs = [];
      final Set<int> addedClubIds = {};
      
      // Process approved clubs
      for (var item in approvedData) {
        if (item['clubs'] != null) {
          final club = Club.fromJson(item['clubs']);
          if (addedClubIds.add(club.id)) {
            processedClubs.add({
              'club': club,
              'role': AppRole.fromString(item['role']),
              'status': 'approved',
            });
          }
        }
      }

      // Process pending clubs
      for (var item in pendingData) {
        if (item['clubs'] != null) {
          final club = Club.fromJson(item['clubs']);
          // Only add if not already present (prioritize approved)
          if (addedClubIds.add(club.id)) {
            processedClubs.add({
              'club': club,
              'role': AppRole.fromString(item['role']),
              'status': 'pending',
            });
          }
        }
      }

      // Sıralama: Önce status (approved > pending), sonra rol
      processedClubs.sort((a, b) {
        if (a['status'] != b['status']) {
          return a['status'] == 'approved' ? -1 : 1;
        }
        final roleA = a['role'] as AppRole;
        final roleB = b['role'] as AppRole;
        return _getRolePriority(roleA).compareTo(_getRolePriority(roleB));
      });

      setState(() {
        _myClubs = processedClubs;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Kulüplerim yüklenemedi: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _getRolePriority(AppRole role) {
    switch (role) {
      case AppRole.president:
        return 0;
      case AppRole.vicePresident:
        return 1;
      case AppRole.coordinator:
        return 2;
      case AppRole.member:
        return 3;
    }
  }

  String _getRoleLabel(AppRole role) {
    switch (role) {
      case AppRole.president:
        return 'Başkan';
      case AppRole.vicePresident:
        return 'Başkan Yrd.';
      case AppRole.coordinator:
        return 'Koordinatör';
      case AppRole.member:
        return 'Üye';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuraScaffold(
      auraColor: AuraTheme.kAccentCyan,
      body: Column(
        children: [
          const SizedBox(height: 20),
          
          // Sponsor Banner Wrapper
          Padding(
             padding: const EdgeInsets.symmetric(horizontal: 24),
             child: AuraGlassCard(
               padding: EdgeInsets.zero,
               borderRadius: 24,
               child: const SponsorBanner(),
             ),
          ),

          const SizedBox(height: 24),

          // --- CLUB LIST ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AuraTheme.kAccentCyan))
                : _myClubs.isEmpty
                    ? _buildEmptyState()
                    : AuraPullToRefresh(
                        onRefresh: _loadMyClubs,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                          itemCount: _myClubs.length,
                          itemBuilder: (context, index) {
                            final item = _myClubs[index];
                            final Club club = item['club'];
                            final AppRole role = item['role'];
                            final Color clubColor = hexToColor(club.mainColor);

                            return StaggeredItem(
                              index: index,
                              child: _buildAuraClubListTile(
                                context,
                                club,
                                role,
                                clubColor,
                                item['status'] == 'pending',
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          ),
          const SizedBox(height: 20),
          Text(
            "Henüz bir kulübe katılmadın.",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Keşfet sekmesinden yeni kulüpler bulabilirsin!",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuraClubListTile(
    BuildContext context,
    Club club,
    AppRole role,
    Color color,
    bool isPending,
  ) {
    final String logoUrl = _dbService.getPublicUrl('clubs', club.logoPath);
    final Color accentColor = isPending ? Colors.orange : color;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AuraGlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 32,
        accentColor: accentColor,
        showGlow: !isPending,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClubDetailPage(club: club),
            ),
          );
        },
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left Aura Strip
              Container(
                width: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accentColor,
                      accentColor.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(32)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Logo with Glow
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: logoUrl.isNotEmpty
                              ? Image.network(logoUrl, fit: BoxFit.cover)
                              : Center(
                                  child: Text(
                                    club.shortName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: accentColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              club.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: onSurface,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: accentColor.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isPending)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 6),
                                          child: Icon(Icons.hourglass_empty_rounded, size: 12, color: Colors.orange),
                                        ),
                                      Text(
                                        (isPending ? 'ONAY BEKLIYOR' : _getRoleLabel(role)).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: accentColor,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: onSurface.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
