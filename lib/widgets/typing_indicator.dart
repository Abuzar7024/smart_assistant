import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh.withAlpha(150),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(theme, 0),
            _dot(theme, 1),
            _dot(theme, 2),
          ],
        ),
      ),
    );
  }

  Widget _dot(ThemeData theme, int index) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha(160), shape: BoxShape.circle),
    ).animate(onPlay: (c) => c.repeat()).scale(delay: (index * 150).ms, duration: 400.ms, curve: Curves.easeInOut).fadeIn();
  }
}
