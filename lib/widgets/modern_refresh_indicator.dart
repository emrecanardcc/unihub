import 'package:flutter/material.dart';
import '../utils/modern_theme.dart';

class ModernRefreshIndicator extends StatelessWidget {
  final Widget child;
  final RefreshCallback onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double edgeOffset;

  const ModernRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? colorScheme.primary,
      backgroundColor: backgroundColor ?? colorScheme.surface.withValues(alpha: 0.9),
      displacement: displacement,
      edgeOffset: edgeOffset,
      strokeWidth: 3.0,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      notificationPredicate: (notification) {
        return notification.depth == 0;
      },
      child: child,
    );
  }
}

class ModernPullToRefreshWrapper extends StatefulWidget {
  final Widget child;
  final RefreshCallback onRefresh;
  final String? refreshMessage;
  final Color? indicatorColor;
  final Color? backgroundColor;

  const ModernPullToRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.refreshMessage,
    this.indicatorColor,
    this.backgroundColor,
  });

  @override
  State<ModernPullToRefreshWrapper> createState() => _ModernPullToRefreshWrapperState();
}

class _ModernPullToRefreshWrapperState extends State<ModernPullToRefreshWrapper> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    
    setState(() => _isRefreshing = true);
    
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ModernRefreshIndicator(
      onRefresh: _handleRefresh,
      color: widget.indicatorColor,
      backgroundColor: widget.backgroundColor,
      child: Stack(
        children: [
          widget.child,
          if (_isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (widget.indicatorColor ?? colorScheme.primary).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              widget.indicatorColor ?? ModernTheme.primaryCyan,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.refreshMessage ?? 'Yenileniyor...',
                          style: TextStyle(
                            color: widget.indicatorColor ?? colorScheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom refresh indicator with animation
class AnimatedRefreshIndicator extends StatefulWidget {
  final Widget child;
  final RefreshCallback onRefresh;
  final Color? color;
  final Color? backgroundColor;

  const AnimatedRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
  });

  @override
  State<AnimatedRefreshIndicator> createState() => _AnimatedRefreshIndicatorState();
}

class _AnimatedRefreshIndicatorState extends State<AnimatedRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    _controller.forward();
    await widget.onRefresh();
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: widget.color ?? colorScheme.primary,
      backgroundColor: widget.backgroundColor ?? colorScheme.surface.withValues(alpha: 0.95),
      displacement: 60.0,
      strokeWidth: 3.0,
      notificationPredicate: (notification) {
        if (notification is OverscrollNotification) {
          if (notification.overscroll > 20) {
            _controller.forward();
          } else if (notification.overscroll < 10) {
            _controller.reverse();
          }
        }
        return notification.depth == 0;
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: 0.8 + (_fadeAnimation.value * 0.2),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
