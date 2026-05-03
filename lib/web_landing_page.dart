import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

class WebLandingPage extends StatefulWidget {
  const WebLandingPage({super.key});

  @override
  State<WebLandingPage> createState() => _WebLandingPageState();
}

class _WebLandingPageState extends State<WebLandingPage> {
  // Renk Paleti
  final Color _background = const Color(0xFF131313);
  final Color _surfaceDim = const Color(0xFF131313);
  final Color _surfaceContainerLow = const Color(0xFF1C1B1B);
  final Color _surfaceContainerHigh = const Color(0xFF2A2A2A);
  final Color _surfaceContainerHighest = const Color(0xFF353534);
  final Color _primary = const Color(0xFF4CD6FB);
  final Color _primaryContainer = const Color(0xFF00B4D8);
  final Color _onPrimary = const Color(0xFF003642);
  final Color _onSurface = const Color(0xFFE5E2E1);
  final Color _onSurfaceVariant = const Color(0xFFBCC9CE);
  final Color _error = const Color(0xFFFFB4AB);
  final Color _zinc400 = const Color(0xFFA1A1AA);
  final Color _zinc500 = const Color(0xFF71717A);
  final Color _zinc950 = const Color(0xFF09090B);

  final String _fontHeadline = 'Manrope';
  final String _fontBody = 'Inter';

  final ScrollController _scrollController = ScrollController();

  // Hedef bölümler için GlobalKey'ler
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _founderKey = GlobalKey();
  final GlobalKey _footerKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _openMail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'emrecanardc.dev@gmail.com',
      query: 'subject=Kulüpi Hakkında',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

Future<void> _showPrivacyPolicy() async {
    // web klasörünün içindeki privacy.html dosyasına yönlendirir
    final Uri url = Uri.parse('privacy.html'); 

    try {
      await launchUrl(url, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Gizlilik politikası açılamadı: $e');
    }
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            right: -250,
            child: _buildGlowOrb(_primary.withOpacity(0.1), 500, 120),
          ),

          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildHeroSection(context),
                _buildProblemSolutionSection(context),
                Container(
                  key: _featuresKey,
                  child: _buildFeaturesGrid(context),
                ),
                Container(
                  key: _founderKey,
                  child: _buildFounderSection(),
                ),
                _buildDownloadSection(context),
                Container(
                  key: _footerKey,
                  child: _buildFooter(context),
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildNavbar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          color: _zinc950.withOpacity(0.6),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Kulüpi",
                    style: TextStyle(
                      color: _primary,
                      fontFamily: _fontHeadline,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  if (!isMobile)
                    Row(
                      children: [
                        _AnimatedTextLink(
                          text: "Özellikler",
                          defaultColor: _zinc400,
                          hoverColor: Colors.white,
                          onTap: () => _scrollToSection(_featuresKey),
                        ),
                        const SizedBox(width: 40),
                        _AnimatedTextLink(
                          text: "Kurucumuz",
                          defaultColor: _zinc400,
                          hoverColor: Colors.white,
                          onTap: () => _scrollToSection(_founderKey),
                        ),
                        const SizedBox(width: 40),
                        _AnimatedTextLink(
                          text: "Sözleşmeler",
                          defaultColor: _zinc400,
                          hoverColor: Colors.white,
                          onTap: () => _scrollToSection(_footerKey),
                        ),
                      ],
                    ),
                  _HoverScale(
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primary, _primaryContainer],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      child: Text(
                        "UYGULAMAYI İNDİR",
                        style: TextStyle(
                          color: _onPrimary,
                          fontFamily: _fontBody,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1024;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 32,
        right: 32,
        top: isMobile ? 120 : 160,
        bottom: 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Column(
                  crossAxisAlignment:
                      isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _primary.withOpacity(0.1),
                        border: Border.all(color: _primary.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.security, color: _primary, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            "KAMPÜSÜN YENİ NESİL HALİ",
                            style: TextStyle(
                              color: _primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    RichText(
                      textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: _fontHeadline,
                          color: _onSurface,
                          fontSize: isMobile ? 48 : 72,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -2,
                        ),
                        children: [
                          const TextSpan(text: "Kampüs Sosyalliğini\n"),
                          TextSpan(
                            text: "Cebinde Keşfet",
                            style: TextStyle(
                              color: _primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Kulüpi ile etkinlikleri kaçırma, topluluklara katıl ve kampüs hayatının nabzını tut. Tüm üniversite deneyimi tek bir platformda.",
                      textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      style: TextStyle(
                        color: _onSurfaceVariant,
                        fontFamily: _fontBody,
                        fontSize: isMobile ? 18 : 20,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment:
                          isMobile ? WrapAlignment.center : WrapAlignment.start,
                      children: [
                        _HoverScale(
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_primary, _primaryContainer],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _primary.withOpacity(0.2),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            child: Text(
                              "Hemen Başla",
                              style: TextStyle(
                                color: _onPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        _HoverScale(
                          onTap: () => _scrollToSection(_featuresKey),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _surfaceContainerHighest,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            child: Text(
                              "Daha Fazla Bilgi",
                              style: TextStyle(
                                color: _onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isMobile) const SizedBox(width: 64),
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Container(
                  height: 600,
                  margin: EdgeInsets.only(top: isMobile ? 64 : 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (!isMobile)
                        Positioned(
                          bottom: 0,
                          left: 20,
                          child: Transform.rotate(
                            angle: -0.1,
                            child: _buildRealMockupCard(
                              280,
                              500,
                              'assets/mockup2.png',
                            ),
                          ),
                        ),
                      Positioned(
                        right: isMobile ? null : 0,
                        child: Transform.rotate(
                          angle: 0.05,
                          child: _buildRealMockupCard(
                            320,
                            560,
                            'assets/mockup1.png',
                          ),
                        ),
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

  Widget _buildProblemSolutionSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1024;
    return Container(
      width: double.infinity,
      color: _surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Container(
                  margin: EdgeInsets.only(bottom: isMobile ? 64 : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 48.0),
                          child: Column(
                            children: [
                              _HoverScale(
                                child: _infoCard(
                                  "WhatsApp Kaosu",
                                  "Yüzlerce grupta kaybolan önemli duyurular.",
                                  Icons.warning_amber_rounded,
                                  _error,
                                  _surfaceDim,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _HoverScale(
                                child: _infoCard(
                                  "Eski Yöntemler",
                                  "Fiziksel formlar ve manuel yoklamalarla vakit kaybı.",
                                  Icons.schedule,
                                  _error,
                                  _surfaceDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            _HoverScale(
                              child: _infoCard(
                                "Dijital Verimlilik",
                                "Tek bir platformdan etkinlik takibi ve anlık bildirim.",
                                Icons.bolt,
                                _primary,
                                _primary.withOpacity(0.05),
                                borderColor: _primary.withOpacity(0.2),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _HoverScale(
                              child: _infoCard(
                                "Hızlı Giriş",
                                "QR kod ile saniyeler içinde giriş ve analiz.",
                                Icons.qr_code_2,
                                _primary,
                                _primary.withOpacity(0.05),
                                borderColor: _primary.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isMobile) const SizedBox(width: 80),
              Expanded(
                flex: isMobile ? 0 : 1,
                child: Column(
                  crossAxisAlignment:
                      isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    RichText(
                      textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: _fontHeadline,
                          color: _onSurface,
                          fontSize: isMobile ? 40 : 48,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                        children: [
                          const TextSpan(text: "Karmaşayı Bırakın,\n"),
                          TextSpan(
                            text: "Geleceğe Odaklanın",
                            style: TextStyle(color: _primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Üniversite topluluklarını yönetmek hiç bu kadar kolay olmamıştı. WhatsApp gruplarının gürültüsünden kurtulun ve profesyonel bir kampüs deneyimi sunun.",
                      textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      style: TextStyle(
                        color: _onSurfaceVariant,
                        fontSize: 18,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: 96,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 120),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              Text(
                "Her Şey Kontrolün Altında",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: _fontHeadline,
                  color: _onSurface,
                  fontSize: isMobile ? 36 : 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Kulüpi, bir öğrenciden diğerine kampüs hayatını kolaylaştırmak için tasarlandı.",
                textAlign: TextAlign.center,
                style: TextStyle(color: _onSurfaceVariant, fontSize: 18),
              ),
              const SizedBox(height: 64),
              if (isMobile)
                Column(
                  children: [
                    _HoverScale(child: _bentoCardLarge()),
                    const SizedBox(height: 24),
                    _HoverScale(child: _bentoCardQR()),
                    const SizedBox(height: 24),
                    _HoverScale(child: _bentoCardFeed()),
                    const SizedBox(height: 24),
                    _HoverScale(child: _bentoCardImage()),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: _HoverScale(child: _bentoCardLarge()),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 4,
                          child: _HoverScale(child: _bentoCardQR()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: _HoverScale(child: _bentoCardFeed()),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 7,
                          child: _HoverScale(child: _bentoCardImage()),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bentoCardLarge() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kulüp Yönetimi",
            style: TextStyle(
              fontFamily: _fontHeadline,
              color: _onSurface,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Üye yönetimi, duyuru paylaşımı ve finansal takibi tek bir merkezden profesyonelce gerçekleştirin.",
            style: TextStyle(color: _onSurfaceVariant, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _bentoCardQR() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: _surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.qr_code_scanner, color: _primary, size: 64),
          const SizedBox(height: 24),
          Text(
            "QR Check-in",
            style: TextStyle(
              fontFamily: _fontHeadline,
              color: _primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Etkinlik girişlerinde kuyrukları bitirin. QR kodunuzu okutun ve içeri girin.",
            style: TextStyle(color: _onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _bentoCardFeed() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: _surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.dynamic_feed, color: _primary, size: 24),
          ),
          const Spacer(),
          Text(
            "Anlık Akış",
            style: TextStyle(
              fontFamily: _fontHeadline,
              color: _onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Kampüsünüzdeki tüm topluluklardan anlık haberler tek akışta.",
            style: TextStyle(color: _onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _bentoCardImage() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_primary, _primaryContainer]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '"Kulüpi ile kampüs daha sosyal, daha dijital."',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: _fontHeadline,
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildFounderSection() {
    return Container(
      width: double.infinity,
      color: _surfaceDim,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primary, const Color(0xFFA1CDDD)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 64,
                  backgroundColor: _surfaceContainerHighest,
                  child: Icon(Icons.person, size: 50, color: _primary),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Kulüpi'nin Arkasındaki Vizyon",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: _fontHeadline,
                  color: _onSurface,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "KULÜPİ KURUCUSU",
                style: TextStyle(
                  color: _primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Emre Can ARDIÇ",
                style: TextStyle(
                  color: _onSurface,
                  fontSize: 20,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                " Matematik ve Bilgisayar Bilimleri öğrencisi olarak, kampüs hayatının dijital karmaşası beni bu platformu inşa etmeye itti. Kulüpi, sadece bir uygulama değil; öğrenci topluluklarının potansiyelini maksimize etmek için tasarlanmış bir ekosistemdir.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _onSurfaceVariant,
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  height: 1.8,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadSection(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 40 : 80),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, _primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  "Hemen İndir",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _fontHeadline,
                    color: Colors.white,
                    fontSize: isMobile ? 48 : 64,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Üniversite hayatını cebine sığdır. Ücretsiz indirin ve kampüsün bir parçası olun.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: [
                    _HoverScale(
                      child: _storeBtn("App Store", Icons.apple, "Available on"),
                    ),
                    _HoverScale(
                      child: _storeBtn(
                        "Google Play",
                        Icons.android,
                        "Get it on",
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _storeBtn(String store, IconData icon, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                store,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Container(
      width: double.infinity,
      color: _zinc950,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Kulüpi",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isMobile ? 32 : 0),
              Wrap(
                spacing: 32,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _AnimatedTextLink(
                    text: "Gizlilik Politikası",
                    defaultColor: _zinc500,
                    hoverColor: _primary,
                    onTap: _showPrivacyPolicy,
                  ),
                  _AnimatedTextLink(
                    text: "İletişim",
                    defaultColor: _zinc500,
                    hoverColor: _primary,
                    onTap: _openMail,
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 32 : 0),
              Text(
                "© 2026 Kulüpi. Tüm hakları saklıdır.",
                style: TextStyle(
                  color: _zinc500,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(
    String title,
    String desc,
    IconData icon,
    Color iconColor,
    Color bgColor, {
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 36),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontFamily: _fontHeadline,
              color: _onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              color: _onSurfaceVariant,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealMockupCard(double width, double height, String imagePath) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 35,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.image_not_supported,
                color: Colors.white24,
                size: 50,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlowOrb(Color color, double size, double blur) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _HoverScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _HoverScale({required this.child, this.onTap});

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap ?? () {},
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}

class _AnimatedTextLink extends StatefulWidget {
  final String text;
  final Color defaultColor;
  final Color hoverColor;
  final VoidCallback? onTap;

  const _AnimatedTextLink({
    required this.text,
    required this.defaultColor,
    required this.hoverColor,
    this.onTap,
  });

  @override
  State<_AnimatedTextLink> createState() => _AnimatedTextLinkState();
}

class _AnimatedTextLinkState extends State<_AnimatedTextLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap ?? () {},
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            color: _isHovered ? widget.hoverColor : widget.defaultColor,
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: _isHovered ? FontWeight.bold : FontWeight.w600,
          ),
          child: Text(
            widget.text.toUpperCase(),
            style: const TextStyle(letterSpacing: 1),
          ),
        ),
      ),
    );
  }
}