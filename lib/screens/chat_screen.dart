import 'package:go_router/go_router.dart';
import '../models/conversation.dart';
import '../providers/chat_provider.dart';
import '../models/message.dart';
import '../widgets/app_drawer.dart';
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
