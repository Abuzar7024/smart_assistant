import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/chat_provider.dart';
import '../providers/suggestions_provider.dart';
import '../providers/theme_provider.dart';
import '../models/suggestion.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SuggestionsProvider>().fetchSuggestions();
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<SuggestionsProvider>().fetchSuggestions();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestionsProvider = Provider.of<SuggestionsProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

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
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/history'),
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
            child: RefreshIndicator(
              onRefresh: () => suggestionsProvider.fetchSuggestions(isRefresh: true),
              child: suggestionsProvider.isLoading && suggestionsProvider.suggestions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello, ${context.watch<ChatProvider>().userName}!",
                                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w300),
                              ),
                              Text(
                                "How can I help you today?",
                                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                              ),
                            ],
                          ).animate().fadeIn(duration: 600.ms).moveY(begin: 20, end: 0),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: suggestionsProvider.suggestions.length + (suggestionsProvider.isLoadingMore ? 1 : 0),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              if (index == suggestionsProvider.suggestions.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }

                              final suggestion = suggestionsProvider.suggestions[index];
                              return _SuggestionCard(suggestion: suggestion, index: index);
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chat'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        label: const Text('Start Chat', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.auto_awesome),
      ).animate().scale(delay: 400.ms),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final Suggestion suggestion;
  final int index;

  const _SuggestionCard({required this.suggestion, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/chat', extra: suggestion.title),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10), // Updated to withAlpha
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: theme.colorScheme.primary.withAlpha(30)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.description,
                      style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150), fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.primary.withAlpha(120)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index % 10 * 50).ms).moveX(begin: 30, end: 0);
  }
}
