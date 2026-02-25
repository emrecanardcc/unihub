import 'package:flutter/material.dart';
import 'package:unihub/tabs/discover_tab.dart';
import 'package:unihub/tabs/my_clubs_tab.dart';
import 'package:unihub/tabs/modern_user_profile_tab.dart';
import 'package:unihub/tabs/events_discovery_tab.dart';
import 'package:unihub/utils/glass_components.dart';
import 'package:unihub/widget/notification_bell.dart';

class MainHub extends StatefulWidget {
  const MainHub({super.key});

  @override
  State<MainHub> createState() => _MainHubState();
}

class _MainHubState extends State<MainHub> {
  int _pageIndex = 1; // Start at "My Clubs"
  
  // Page List
  final List<Widget> _pages = [
    const DiscoverClubsTab(),   // 0: Keşfet (Kulüpler)
    const EventsDiscoveryTab(), // 1: Etkinlikler (YENİ)
    const MyClubsTab(),         // 2: Kulüplerim (Ana Sayfa)
    const ModernUserProfileTab(),     // 3: Profil
  ];

  /* void _openAIChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AIChatSheet(),
    );
  } */

  @override
  Widget build(BuildContext context) {
    return AuraScaffold(
      auraColor: AuraTheme.kAccentCyan, // Default neutral aura
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'UniHub',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _pageIndex == 0
                        ? "Keşfet"
                        : _pageIndex == 1
                            ? "Etkinlikler"
                            : _pageIndex == 2
                                ? "Kulüplerim"
                                : "Profil",
                    key: ValueKey<int>(_pageIndex),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: NotificationBell(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _pageIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 20),
        child: AuraGlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
          borderRadius: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.explore_rounded, "Keşfet"),
              _buildNavItem(1, Icons.calendar_today_rounded, "Etkinlikler"),
              _buildNavItem(2, Icons.home_rounded, "Kulüplerim"),
              _buildNavItem(3, Icons.person_rounded, "Profil"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _pageIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _pageIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutQuint,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? AuraTheme.kAccentCyan.withValues(alpha: 0.15) : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AuraTheme.kAccentCyan.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 1,
                )
              ] : [],
            ),
            child: Icon(
              icon,
              color: isSelected ? AuraTheme.kAccentCyan : Colors.white.withValues(alpha: 0.3),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isSelected ? 1.0 : 0.0,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AuraTheme.kAccentCyan,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
