import 'dart:ui';
import 'package:flutter/material.dart';

class AuraTheme {
  // --- CORE COLORS ---
  static const Color kMidnightBlack = Color(0xFF050505);
  static const Color kDeepSpace = Color(0xFF0A0A12);
  static const Color kNeonCyan = Color(0xFF00FBFF);
  static const Color kElectricPurple = Color(0xFF8E2DE2);
  static const Color kHotPink = Color(0xFFF000FF);
  static const Color kAccentCyan = Color(0xFF00E5FF);
  
  // --- GLASS CONSTANTS ---
  static const double kBlurSigma = 25.0;
  static const double kBorderWidth = 0.8;
  static final Color kGlassBase = Colors.white.withValues(alpha: 0.05);
  static final Color kGlassBorder = Colors.white.withValues(alpha: 0.12);

  // --- GRADIENTS ---
  static LinearGradient auraGradient(Color auraColor) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        auraColor.withValues(alpha: 0.3),
        auraColor.withValues(alpha: 0.05),
        Colors.transparent,
      ],
    );
  }

  static const LinearGradient kCyberMesh = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      kMidnightBlack,
      Color(0xFF0D0D1A),
      kMidnightBlack,
    ],
  );

  // --- TEXT STYLES ---
  static const TextStyle kHeadingDisplay = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w900,
    color: Colors.white,
    letterSpacing: -1.0,
    fontFamily: 'Inter',
  );

  static const TextStyle kBodySubtle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: Color(0xFFB0B0B0),
    height: 1.5,
  );
}

// --- RADICAL GLASS CONTAINER ---
class AuraGlassCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool showGlow;
  final double? width;
  final double? height;

  const AuraGlassCard({
    super.key,
    required this.child,
    this.accentColor,
    this.borderRadius = 28,
    this.padding,
    this.margin,
    this.onTap,
    this.showGlow = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Light Mode Glass: More opaque white, stronger shadows
    // Dark Mode Glass: Very transparent white, subtle shadows
    final Color glassColor = isDark 
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFF3F4F6).withValues(alpha: 0.55);
        
    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFD1D5DB).withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        width: width,
        height: height,
        child: Stack(
          children: [
          if (showGlow && accentColor != null)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor!.withValues(alpha: isDark ? 0.4 : 0.25),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                ),
              ),
            ),
            
            // Glass Effect
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: AuraTheme.kBlurSigma, sigmaY: AuraTheme.kBlurSigma),
                child: Container(
                  padding: padding ?? const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: glassColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: borderColor,
                      width: AuraTheme.kBorderWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- AURA SCAFFOLD ---
class AuraScaffold extends StatelessWidget {
  final Widget body;
  final Color? auraColor;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;

  const AuraScaffold({
    super.key,
    required this.body,
    this.auraColor,
    this.bottomNavigationBar,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Stack(
        children: [
          // Background Mesh (Only for Dark Mode or Custom Gradient for Light)
          if (isDark)
            Positioned.fill(
              child: Container(decoration: const BoxDecoration(gradient: AuraTheme.kCyberMesh)),
            ),
          
          // Dynamic Aura Glow
          if (auraColor != null)
            Positioned(
              top: -150,
              right: -100,
              child: _AuraOrb(color: auraColor!, size: 400),
            ),
          
          Positioned(
            bottom: -100,
            left: -100,
            child: _AuraOrb(color: auraColor?.withValues(alpha: 0.5) ?? AuraTheme.kNeonCyan, size: 300),
          ),

          SafeArea(child: body),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class _AuraOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _AuraOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// --- AURA GLASS TEXTFIELD ---
class AuraGlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData? icon;
  final TextInputType keyboardType;
  final int maxLines;

  const AuraGlassTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    final Color fieldColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFF3F4F6).withValues(alpha: 0.8);
    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : const Color(0xFFD1D5DB).withValues(alpha: 0.7);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: fieldColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(color: onSurface, fontSize: 15),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: onSurface.withValues(alpha: 0.5)),
              prefixIcon: icon != null ? Icon(icon, color: onSurface.withValues(alpha: 0.6), size: 20) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}
