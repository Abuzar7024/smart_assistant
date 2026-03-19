import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';

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

    return Scaffold(
      extendBodyBehindAppBar: true,
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
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
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
                        "My Conversations",
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                    ],
                  ).animate().fadeIn(duration: 600.ms).moveY(begin: 20, end: 0),
                ),
                Expanded(
                  child: conversations.isEmpty
                      ? _buildEmptyState(theme)
                      : ListView.builder(
                          itemCount: conversations.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final conversation = conversations[index];
                            return _ConversationGroupCard(
                              conversation: conversation, 
                              index: index,
                              onTap: () {
                                chatProvider.setActiveConversation(conversation.id);
                                context.push('/chat/${conversation.id}');
                              },
                              onDelete: () => chatProvider.deleteConversation(conversation.id),
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
