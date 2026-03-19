import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/chat_provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final history = chatProvider.messages;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights History', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _showDeleteDialog(context, chatProvider),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.surfaceContainerHighest.withAlpha(50), theme.colorScheme.surface],
          ),
        ),
        child: history.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_toggle_off, size: 80, color: theme.colorScheme.primary.withAlpha(50)),
                    const SizedBox(height: 16),
                    Text('Your journey is empty', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(150))),
                  ],
                ).animate().fadeIn().scale(),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final message = history[index];
                  final isUser = message.sender == 'user';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outline.withAlpha(30)),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isUser ? theme.colorScheme.primary.withAlpha(30) : theme.colorScheme.secondary.withAlpha(30),
                        child: Icon(
                          isUser ? Icons.person_outline : Icons.auto_awesome_outlined,
                          color: isUser ? theme.colorScheme.primary : theme.colorScheme.secondary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        message.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        DateFormat('MMM dd, hh:mm a').format(message.timestamp),
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withAlpha(120)),
                      ),
                    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: -0.1, end: 0),
                  );
                },
              ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ChatProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purge History?'),
        content: const Text('All previous conversations will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
