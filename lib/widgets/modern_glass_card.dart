import 'package:flutter/material.dart';
import 'dart:ui';
import '../utils/modern_theme.dart';

class ModernGlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const ModernGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius,
    this.opacity = 0.1,
    this.borderColor,
    this.borderWidth = 1,
    this.boxShadow,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16);
    final effectiveBorderColor = borderColor ?? 
        (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.5));

    // Light mode needs more opacity to be visible against white background
    final double baseOpacity = isDark ? opacity : (opacity < 0.2 ? 0.6 : opacity);
    
    Widget cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        gradient: gradient ?? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: baseOpacity * 0.8),
            Colors.white.withValues(alpha: baseOpacity * 0.4),
          ],
        ),
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: effectiveBorderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: cardContent,
      );
    }

    return cardContent;
  }
}

class ModernGlassButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final bool isOutlined;
  final bool isLoading;

  const ModernGlassButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.isOutlined = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? ModernTheme.primaryCyan;
    final effectiveTextColor = textColor ?? Colors.black;

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: effectiveTextColor, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: ModernTheme.button.copyWith(color: effectiveTextColor),
        ),
        if (isLoading) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
            ),
          ),
        ],
      ],
    );

    if (isOutlined) {
      return ModernGlassCard(
        width: width,
        height: height ?? 52,
        opacity: 0.05,
        borderColor: effectiveBackgroundColor,
        borderWidth: 2,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(child: buttonContent),
        ),
      );
    }

    return ModernGlassCard(
      width: width,
      height: height ?? 52,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          effectiveBackgroundColor.withValues(alpha: 0.9),
          effectiveBackgroundColor.withValues(alpha: 0.7),
        ],
      ),
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Center(child: buttonContent),
      ),
    );
  }
}

class ModernGlassTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final Color? fillColor;
  final Color? borderColor;

  const ModernGlassTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.fillColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final effectiveBorderColor = borderColor ?? onSurface.withValues(alpha: 0.2);

    return ModernGlassCard(
      opacity: 0.1,
      borderColor: effectiveBorderColor,
      borderWidth: 1,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        style: textTheme.bodyLarge?.copyWith(color: onSurface) ?? TextStyle(color: onSurface, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          hintStyle: textTheme.bodyMedium?.copyWith(color: onSurface.withValues(alpha: 0.5)) ??
              TextStyle(color: onSurface.withValues(alpha: 0.5), fontSize: 14),
          labelStyle: textTheme.bodyMedium?.copyWith(color: onSurface.withValues(alpha: 0.7)) ??
              TextStyle(color: onSurface.withValues(alpha: 0.7), fontSize: 14),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: onSurface.withValues(alpha: 0.7), size: 20)
              : null,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon, color: onSurface.withValues(alpha: 0.7), size: 20),
                  onPressed: onSuffixIconPressed,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
