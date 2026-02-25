import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../utils/glass_components.dart';

class AuraPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? accentColor;

  const AuraPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.accentColor,
  });

  @override
  State<AuraPullToRefresh> createState() => _AuraPullToRefreshState();
}

class _AuraPullToRefreshState extends State<AuraPullToRefresh> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRefreshing = false;
  double _pullDistance = 0;
  bool _hasHapticTriggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.accentColor ?? AuraTheme.kAccentCyan;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isRefreshing = true;
          _hasHapticTriggered = false;
        });
        _controller.repeat();
        await widget.onRefresh();
        if (mounted) {
          setState(() {
            _isRefreshing = false;
            _pullDistance = 0;
          });
          _controller.stop();
        }
      },
      color: Colors.transparent, // Hide default indicator
      backgroundColor: Colors.transparent,
      strokeWidth: 0,
      displacement: 60,
      notificationPredicate: (notification) {
        if (notification is ScrollUpdateNotification) {
          final double metrics = notification.metrics.pixels;
          if (metrics < 0) {
            setState(() {
              _pullDistance = metrics.abs();
            });
            
            if (_pullDistance > 80 && !_hasHapticTriggered && !_isRefreshing) {
              HapticFeedback.mediumImpact();
              _hasHapticTriggered = true;
            }
          } else {
            if (_pullDistance != 0) {
              setState(() {
                _pullDistance = 0;
              });
            }
          }
        }
        return defaultScrollNotificationPredicate(notification);
      },
      child: Stack(
        children: [
          widget.child,
          
          // Custom Aura Pull Animation
          if (_pullDistance > 0 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 100,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      double progress = (_pullDistance / 100).clamp(0.0, 1.0);
                      if (_isRefreshing) progress = 1.0;
                      
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background Glow
                          Container(
                            width: 60 * progress,
                            height: 60 * progress,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(
                                    alpha: _isRefreshing 
                                        ? (0.4 + 0.2 * math.sin(_controller.value * math.pi * 2))
                                        : (0.3 * progress)
                                  ),
                                  blurRadius: _isRefreshing ? 30 : 20 * progress,
                                  spreadRadius: _isRefreshing ? 10 : 5 * progress,
                                ),
                              ],
                            ),
                          ),
                          
                          // Rotating Aura Ring
                          Transform.rotate(
                            angle: _isRefreshing ? _controller.value * 2 * math.pi : progress * math.pi,
                            child: SizedBox(
                              width: 40 * progress,
                              height: 40 * progress,
                              child: CustomPaint(
                                painter: AuraRefreshPainter(
                                  color: accent,
                                  progress: _isRefreshing ? 0.8 : progress,
                                  isRefreshing: _isRefreshing,
                                ),
                              ),
                            ),
                          ),
                          
                          // Center Icon
                          Icon(
                            _isRefreshing ? Icons.auto_awesome_rounded : Icons.arrow_downward_rounded,
                            size: 16 * progress,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: progress),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AuraRefreshPainter extends CustomPainter {
  final Color color;
  final double progress;
  final bool isRefreshing;

  AuraRefreshPainter({
    required this.color,
    required this.progress,
    required this.isRefreshing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    if (isRefreshing) {
      canvas.drawArc(rect, 0, 2 * math.pi * 0.7, false, paint);
    } else {
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, paint);
    }
    
    // Add some "aura" dots
    final dotPaint = Paint()
      ..color = color.withValues(alpha: progress * 0.5)
      ..style = PaintingStyle.fill;
      
    for (int i = 0; i < 3; i++) {
      double angle = (2 * math.pi / 3) * i;
      if (isRefreshing) angle += progress * 2 * math.pi;
      
      double x = size.width / 2 + (size.width / 2 + 5) * math.cos(angle);
      double y = size.height / 2 + (size.height / 2 + 5) * math.sin(angle);
      
      canvas.drawCircle(Offset(x, y), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant AuraRefreshPainter oldDelegate) => 
    oldDelegate.progress != progress || oldDelegate.isRefreshing != isRefreshing;
}
