import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/glass_components.dart';

class AuraSlideRequest extends StatefulWidget {
  final VoidCallback onConfirm;
  final Color accentColor;
  final String label;

  const AuraSlideRequest({
    super.key,
    required this.onConfirm,
    required this.accentColor,
    this.label = "İstek Göndermek için Kaydır",
  });

  @override
  State<AuraSlideRequest> createState() => _AuraSlideRequestState();
}

class _AuraSlideRequestState extends State<AuraSlideRequest> with SingleTickerProviderStateMixin {
  double _dragValue = 0.0;
  bool _isConfirmed = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double handleSize = 60.0;
        double trackHeight = 70.0;
        double maxDrag = maxWidth - handleSize - 10;

        return Container(
          height: trackHeight,
          width: maxWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(trackHeight / 2),
            color: AuraTheme.kGlassBase,
            border: Border.all(
              color: widget.accentColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Shimmering Label Text
              Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: (1.0 - (_dragValue / maxDrag)).clamp(0.0, 1.0),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Glowing Track Fill
              Positioned(
                left: 5,
                child: Container(
                  height: trackHeight - 10,
                  width: _dragValue + handleSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(trackHeight / 2),
                    gradient: LinearGradient(
                      colors: [
                        widget.accentColor.withValues(alpha: 0.4),
                        widget.accentColor.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
              ),

              // The Handle
              Positioned(
                left: 5 + _dragValue,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isConfirmed) return;
                    setState(() {
                      _dragValue = (_dragValue + details.delta.dx).clamp(0.0, maxDrag);
                    });
                    if (_dragValue >= maxDrag * 0.9) {
                      HapticFeedback.heavyImpact();
                    } else {
                      HapticFeedback.selectionClick();
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isConfirmed) return;
                    if (_dragValue >= maxDrag * 0.95) {
                      setState(() {
                        _dragValue = maxDrag;
                        _isConfirmed = true;
                      });
                      HapticFeedback.vibrate();
                      widget.onConfirm();
                    } else {
                      setState(() {
                        _dragValue = 0.0;
                      });
                    }
                  },
                  child: ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.05).animate(
                      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                    ),
                    child: Container(
                      width: handleSize,
                      height: handleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.accentColor,
                        boxShadow: [
                          BoxShadow(
                            color: widget.accentColor.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
