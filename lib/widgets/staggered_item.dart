import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StaggeredItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final double slideOffset;

  const StaggeredItem({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 400),
    this.slideOffset = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: (50 * index).ms)
        .fadeIn(duration: duration, curve: Curves.easeOut)
        .slideY(begin: 0.2, end: 0, duration: duration, curve: Curves.easeOut);
  }
}
