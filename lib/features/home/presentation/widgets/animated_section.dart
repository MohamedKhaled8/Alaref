import 'package:flutter/material.dart';

class AnimatedSection extends StatelessWidget {
  final bool visible;
  final Widget child;

  const AnimatedSection({
    super.key,
    required this.visible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 450),
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.06),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        child: child,
      ),
    );
  }
}
