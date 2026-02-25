import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../admin_panel.dart';
import 'club_about_tab.dart';
import 'club_events_tab.dart';
import 'club_profile_tab.dart';
import '../models/club.dart';
// import '../models/app_enums.dart';
import '../utils/hex_color.dart';
import '../services/database_service.dart';
import '../utils/glass_components.dart';
import '../widgets/aura_slide_request.dart';

class ClubDetailPage extends StatefulWidget {
  final Club club;

  const ClubDetailPage({
    super.key,
    required this.club,
  });

  @override
  State<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailPageState extends State<ClubDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // AppRole? _userRole;
  String? _roleName;
  bool _hasPendingRequest = false;
  bool _isMember = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkMembershipStatus();
  }

  Future<void> _checkMembershipStatus() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await Supabase.instance.client
          .from('club_members')
          .select('role, status')
          .eq('club_id', widget.club.id)
          .eq('user_id', user.id)
          .order('status', ascending: true) // approved(a) < pending(p) < rejected(r)
          .limit(1)
          .maybeSingle();

      if (mounted) {
        if (data != null) {
          setState(() {
            _isMember = data['status'] == 'approved';
            _hasPendingRequest = data['status'] == 'pending';
            _roleName = data['role'];
            // _userRole = AppRole.fromString(data['role']);
          });
        } else {
          setState(() {
            _isMember = false;
            _hasPendingRequest = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Üyelik kontrol hatası: $e");
    }
  }

  Future<void> _sendMembershipRequest() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('club_members').insert({
        'club_id': widget.club.id,
        'user_id': user.id,
        'role': 'member',
        'status': 'pending',
        'joined_at': DateTime.now().toIso8601String(),
      });
      _checkMembershipStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = hexToColor(widget.club.mainColor);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color onSurface = colorScheme.onSurface;
    final db = DatabaseService();
    final bannerUrl = db.getPublicUrl('clubs', widget.club.bannerPath);
    final logoUrl = db.getPublicUrl('clubs', widget.club.logoPath);
    bool isAdmin = _roleName != null && _roleName != 'member';

    return AuraScaffold(
      auraColor: themeColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: onSurface, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: Icon(Icons.admin_panel_settings_rounded, color: themeColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminPanel(
                        kulupId: widget.club.id.toString(),
                        kulupismi: widget.club.name,
                        primaryColor: themeColor,
                        currentUserRole: _roleName ?? 'member',
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                    child: Column(
                      children: [
                        // Radical Header
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                image: bannerUrl.isNotEmpty
                                    ? DecorationImage(image: NetworkImage(bannerUrl), fit: BoxFit.cover)
                                    : null,
                                color: AuraTheme.kGlassBase,
                              ),
                            ),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, AuraTheme.kMidnightBlack.withValues(alpha: 0.8)],
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, 40),
                              child: AuraGlassCard(
                                padding: const EdgeInsets.all(4),
                                borderRadius: 40,
                                accentColor: themeColor,
                                showGlow: true,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: const BoxDecoration(shape: BoxShape.circle),
                                  child: ClipOval(
                                    child: logoUrl.isNotEmpty
                                        ? Image.network(logoUrl, fit: BoxFit.cover)
                                        : Center(
                                            child: Text(
                                              widget.club.shortName,
                                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: themeColor),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 60),
                        Text(
                          widget.club.name,
                          textAlign: TextAlign.center,
                          style: (Theme.of(context).textTheme.displaySmall ?? const TextStyle(fontSize: 28, fontWeight: FontWeight.w900))
                              .copyWith(fontSize: 28, fontWeight: FontWeight.w900, color: onSurface),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: themeColor.withValues(alpha: 0.5)),
                            color: themeColor.withValues(alpha: 0.1),
                          ),
                          child: Text(
                            widget.club.category,
                            style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Tab Bar
                        AuraGlassCard(
                          padding: const EdgeInsets.all(6),
                          borderRadius: 20,
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: themeColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            labelColor: Colors.black,
                            unselectedLabelColor: onSurface.withValues(alpha: 0.6),
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: const [
                              Tab(text: "Hikaye"),
                              Tab(text: "Sahne"),
                              Tab(text: "Ekip"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                ClubAboutTab(description: widget.club.description),
                ClubEventsTab(kulupId: widget.club.id.toString(), primaryColor: themeColor),
                ClubProfileTab(
                  kulupId: widget.club.id.toString(),
                  kulupIsmi: widget.club.name,
                  primaryColor: themeColor,
                  onTabChanged: (index) => _tabController.animateTo(index),
                ),
              ],
            ),
          ),
          
          // Floating Slide Action
          if (!_isMember)
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: _hasPendingRequest
                  ? AuraGlassCard(
                      accentColor: Colors.orange,
                      showGlow: true,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.hourglass_empty_rounded, color: Colors.orange),
                          const SizedBox(width: 12),
                          Text(
                            "İsteğin Bulutlarda Süzülüyor...",
                            style: TextStyle(color: Colors.orange.shade200, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : AuraSlideRequest(
                      accentColor: themeColor,
                      onConfirm: _sendMembershipRequest,
                    ),
            ),
        ],
      ),
    );
  }
}
