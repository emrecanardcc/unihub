import 'package:flutter/material.dart';
import 'package:unihub/utils/hex_color.dart';
import 'package:unihub/utils/glass_components.dart';
import 'package:unihub/tabs/club_detail_page.dart';
import 'package:unihub/services/auth_service.dart';
import 'package:unihub/services/database_service.dart';
import 'package:unihub/models/club.dart';
import 'package:unihub/models/profile.dart';
import 'package:unihub/widgets/aura_pull_to_refresh.dart';

class DiscoverClubsTab extends StatefulWidget {
  const DiscoverClubsTab({super.key});

  @override
  State<DiscoverClubsTab> createState() => _DiscoverClubsTabState();
}

class _DiscoverClubsTabState extends State<DiscoverClubsTab> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  
  String _searchText = "";
  List<Club> _allClubs = [];
  List<Club> _filteredClubs = [];
  bool _isLoading = true;
  Profile? _profile;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      _profile = await _authService.getCurrentProfile();
      if (_profile != null && _profile!.universityId != null) {
        _allClubs = await _dbService.getDiscoverableClubs(
          _profile!.id,
          _profile!.universityId!,
        );
        _applyFilter();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Kulüpler yüklenemedi: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text;
      _applyFilter();
    });
  }

  void _applyFilter() {
    if (_searchText.isEmpty) {
      _filteredClubs = _allClubs;
    } else {
      final searchLower = _searchText.toLowerCase();
      _filteredClubs = _allClubs.where((club) {
        return club.name.toLowerCase().contains(searchLower) ||
            club.description.toLowerCase().contains(searchLower) ||
            club.tags.any((tag) => tag.toLowerCase().contains(searchLower));
      }).toList();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuraScaffold(
      auraColor: AuraTheme.kAccentCyan,
      body: Column(
        children: [
          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: AuraGlassTextField(
              controller: _searchController,
              hintText: "İlgi alanına göre ara...",
              icon: Icons.search_rounded,
            ),
          ),

          // --- CLUB LIST ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClubs.isEmpty
                    ? _buildEmptyState(_searchText.isNotEmpty
                        ? "Sonuç bulunamadı."
                        : "Okulundaki tüm kulüplere üyesin! 🎉")
                    : AuraPullToRefresh(
                        onRefresh: _loadInitialData,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
                          itemCount: _filteredClubs.length,
                          itemBuilder: (context, index) {
                            final club = _filteredClubs[index];
                            return _buildAuraClubCard(context, club);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAuraClubCard(BuildContext context, Club club) {
    final Color clubColor = hexToColor(club.mainColor);
    final String logoUrl = _dbService.getPublicUrl('clubs', club.logoPath);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color onSurface = colorScheme.onSurface;
    final Color muted = onSurface.withValues(alpha: 0.6);
    final Color subtle = onSurface.withValues(alpha: 0.45);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AuraGlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 32,
        accentColor: clubColor,
        showGlow: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClubDetailPage(club: club),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Gradient Overlay
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        clubColor.withValues(alpha: 0.25),
                        clubColor.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: clubColor.withValues(alpha: 0.4), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: clubColor.withValues(alpha: 0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
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
                                      color: clubColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              club.name,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: onSurface,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: clubColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: clubColor.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                club.category.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: clubColor,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Description & Tags
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: muted,
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: club.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: onSurface.withValues(alpha: 0.12)),
                        ),
                        child: Text(
                          "#$tag",
                          style: TextStyle(
                            color: subtle,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
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
