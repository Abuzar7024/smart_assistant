import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/chat_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isSaving = false;

  Future<void> _launchApiKeyUrl() async {
    final url = Uri.parse('https://aistudio.google.com/app/apikey');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch URL')),
        );
      }
    }
  }

  String _selectedTone = 'Friendly';
  String _selectedStyle = 'Expressive';

  void _saveOnboardingData() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final chatProvider = context.read<ChatProvider>();
    await chatProvider.updateUserName(name);
    await chatProvider.updatePreferences(tone: _selectedTone, style: _selectedStyle);
    
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.colorScheme.primary.withAlpha(50), Colors.white],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                   Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_awesome, size: 60, color: theme.colorScheme.primary),
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 30),
                  Text(
                    'Let\'s Personalize Your AI',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
                  
                  const SizedBox(height: 40),
                  
                  // Name Section
                  _buildSectionLabel(theme, 'Step 1: Your Name'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'e.g. Abuzar',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.white.withAlpha(200),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  
                  const SizedBox(height: 30),
                  
                  // Tone Section
                  _buildSectionLabel(theme, 'Step 2: Assistant Tone'),
                  const SizedBox(height: 10),
                  _buildSelectionChipRow(
                    items: ['Friendly', 'Professional', 'Humorous', 'Sarcastic'],
                    selectedItem: _selectedTone,
                    onSelected: (item) => setState(() => _selectedTone = item),
                  ).animate().fadeIn(delay: 600.ms),
                  
                  const SizedBox(height: 30),
                  
                  // Style Section
                  _buildSectionLabel(theme, 'Step 3: Assistant Style'),
                  const SizedBox(height: 10),
                  _buildSelectionChipRow(
                    items: ['Expressive', 'Minimalist', 'Emoji-heavy', 'Text-only'],
                    selectedItem: _selectedStyle,
                    onSelected: (item) => setState(() => _selectedStyle = item),
                  ).animate().fadeIn(delay: 800.ms),
                  
                  const SizedBox(height: 60),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveOnboardingData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Complete Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ).animate().fadeIn(delay: 1000.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSelectionChipRow({
    required List<String> items,
    required String selectedItem,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        final isSelected = item == selectedItem;
        return ChoiceChip(
          label: Text(item),
          selected: isSelected,
          onSelected: (_) => onSelected(item),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          selectedColor: Theme.of(context).colorScheme.primary.withAlpha(50),
          labelStyle: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
            fontWeight: isSelected ? FontWeight.bold : null,
          ),
        );
      }).toList(),
    );
  }
}
