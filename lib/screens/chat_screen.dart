import 'package:go_router/go_router.dart';
import '../models/conversation.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';
import '../widgets/app_drawer.dart';
import '../widgets/chat_input.dart';
import '../widgets/typing_indicator.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatScreen extends StatefulWidget {
  final String? conversationId;
  const ChatScreen({super.key, this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().setActiveConversation(widget.conversationId);
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final theme = Theme.of(context);

    // Get current conversation title
    String appBarTitle = 'Smart Assistant';
    if (chatProvider.activeConversationId != null) {
      final conv = chatProvider.conversations.firstWhere(
        (c) => c.id == chatProvider.activeConversationId,
        orElse: () => Conversation(id: '', title: 'Smart Assistant', createdAt: DateTime.now(), messages: []),
      );
      appBarTitle = conv.title;
    }

    // Scroll to bottom whenever messages list changes
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Column(
          children: [
            Text(appBarTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (chatProvider.isTyping)
              Text('typing...', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context, chatProvider),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: chatProvider.messages.length + (chatProvider.isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == chatProvider.messages.length) {
                    return const TypingIndicator().animate().fadeIn();
                  }

                  final message = chatProvider.messages[index];
                  return _MessageBubble(message: message)
                      .animate()
                      .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
                },
              ),
            ),
            ChatInput(
              controller: _controller,
              onSend: (text) => chatProvider.sendMessage(text),
              isEnabled: !chatProvider.isTyping,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ChatProvider provider) {
    final conversationId = provider.activeConversationId;
    if (conversationId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Conversation?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('This will permanently delete this entire chat session.'),
        actions: [
          裙
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              provider.deleteConversation(conversationId);
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back to Home
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == 'user';
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [theme.colorScheme.primary, theme.colorScheme.primary.withAlpha(220)],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [theme.colorScheme.surfaceContainerHigh, theme.colorScheme.surfaceContainerHigh.withAlpha(180)],
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: isUser ? const Radius.circular(24) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isUser ? 20 : 10),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Text(
                DateFormat('hh:mm a').format(message.timestamp),
                style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withAlpha(100), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
