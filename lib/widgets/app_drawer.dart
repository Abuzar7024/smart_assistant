import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final conversations = chatProvider.conversations;
    final grouped = _groupConversations(conversations);

    return Drawer(
      child: Container(
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            // Drawer Header with "New Chat"
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        chatProvider.startNewChat();
                        context.pop(); // Close drawer
                        context.push('/chat');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('New Chat', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: theme.colorScheme.primary.withAlpha(100)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Grouped Conversation List
            Expanded(
              child: ListView.builder(
                itemCount: grouped.keys.length,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, sectionIndex) {
                  final groupTitle = grouped.keys.elementAt(sectionIndex);
                  final groupItems = grouped[groupTitle]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 16, bottom: 8),
                        child: Text(
                          groupTitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(120),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...groupItems.map((conv) => _DrawerItem(
                        conversation: conv,
                        isActive: chatProvider.activeConversationId == conv.id,
                        onTap: () {
                          chatProvider.setActiveConversation(conv.id);
                          context.pop(); // Close drawer
                          context.push('/chat/${conv.id}');
                        },
                      )),
                    ],
                  );
                },
              ),
            ),

            // Bottom Actions
            const Divider(height: 1),
            ListTile(
              leading: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              title: Text(themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode'),
              onTap: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                context.pop();
                context.push('/settings');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Map<String, List<dynamic>> _groupConversations(List<dynamic> conversations) {
    final Map<String, List<dynamic>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));

    for (var conv in conversations) {
      final date = DateTime(conv.createdAt.year, conv.createdAt.month, conv.createdAt.day);
      String group;
      if (date == today) {
        group = "Today";
      } else if (date == yesterday) {
        group = "Yesterday";
      } else if (date.isAfter(lastWeek)) {
        group = "Previous 7 Days";
      } else {
        group = "${date.month}/${date.year}";
      }

      if (!groups.containsKey(group)) {
        groups[group] = [];
      }
      groups[group]!.add(conv);
    }
    return groups;
  }
}

class _DrawerItem extends StatelessWidget {
  final dynamic conversation;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({required this.conversation, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        dense: true,
        selected: isActive,
        selectedTileColor: theme.colorScheme.primary.withAlpha(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(
          conversation.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
        trailing: isActive ? Icon(Icons.bolt, size: 16, color: theme.colorScheme.primary) : null,
      ),
    );
  }
}
