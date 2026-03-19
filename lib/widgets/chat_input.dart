import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final bool isEnabled;

  const ChatInput({
    super.key, 
    required this.controller, 
    required this.onSend, 
    required this.isEnabled
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: isEnabled,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: isEnabled ? 'Ask me anything...' : 'Assistant is thinking...',
                  hintStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(80)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHigh.withAlpha(isEnabled ? 255 : 120),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  prefixIcon: Icon(Icons.bolt, color: theme.colorScheme.primary.withAlpha(isEnabled ? 200 : 80)),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty && isEnabled) {
                    onSend(value);
                    controller.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: 300.ms,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isEnabled
                    ? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primary.withAlpha(180)])
                    : LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade300]),
                boxShadow: isEnabled
                    ? [BoxShadow(color: theme.colorScheme.primary.withAlpha(60), blurRadius: 8, offset: const Offset(0, 4))]
                    : [],
              ),
              child: IconButton(
                onPressed: isEnabled
                    ? () {
                        if (controller.text.isNotEmpty) {
                          onSend(controller.text);
                          controller.clear();
                        }
                      }
                    : null,
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
