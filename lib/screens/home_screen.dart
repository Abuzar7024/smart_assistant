import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final conversations = chatProvider.conversations;
    final grouped = _groupConversations(conversations);

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          'Smart Assistant',
          style: TextStyle(fontWeight: FontWeight.bold, color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Dynamic Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeProvider.isDarkMode
                    ? [Colors.teal.shade900, Colors.black]
                    : [Colors.teal.shade50, Colors.white],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, ${chatProvider.userName}!",
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w300),
                      ),
                      Text(
                        "My History",
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms).moveY(begin: 20, end: 0),
                ),
                Expanded(
                  child: conversations.isEmpty
                      ? _buildEmptyState(theme)
                      : ListView.builder(
                          itemCount: grouped.keys.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, sectionIndex) {
                            final groupTitle = grouped.keys.elementAt(sectionIndex);
                            final groupItems = grouped[groupTitle]!;
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                  child: Text(
                                    groupTitle,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.primary.withAlpha(180),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                ...groupItems.asMap().entries.map((entry) {
                                  final convIndex = entry.key;
                                  final conversation = entry.value;
                                  return _ConversationGroupCard(
                                    conversation: conversation,
                                    index: convIndex,
                                    onTap: () {
                                      chatProvider.setActiveConversation(conversation.id);
                                      context.push('/chat/${conversation.id}');
                                    },
                                    onDelete: () => chatProvider.deleteConversation(conversation.id),
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          chatProvider.startNewChat();
          context.push('/chat');
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        label: const Text('New Chat', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
      ).animate().scale(delay: 400.ms),
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
        group = "${date.month}/${date.year}"; // Or month name
      }

      if (!groups.containsKey(group)) {
        groups[group] = [];
      }
      groups[group]!.add(conv);
    }
    return groups;
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: theme.colorScheme.primary.withAlpha(50)),
          const SizedBox(height: 20),
          Text(
            "No conversations yet",
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withAlpha(150)),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              context.read<ChatProvider>().startNewChat();
              context.push('/chat');
            },
            child: const Text('Start your first AI Chat'),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}

class _ConversationGroupCard extends StatelessWidget {
  final dynamic conversation;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ConversationGroupCard({
    required this.conversation, 
    required this.index, 
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lastMessage = conversation.messages.isNotEmpty 
        ? conversation.messages.last.text 
        : 'Empty conversation';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withAlpha(200),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.primary.withAlpha(30)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.chat_bubble_outline, size: 20, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha(150)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
                color: Colors.red.withAlpha(100),
              ),
              Icon(Icons.chevron_right, size: 16, color: theme.colorScheme.onSurface.withAlpha(80)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).moveX(begin: 20, end: 0);
  }
}
