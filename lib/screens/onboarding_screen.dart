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

  void _saveKey() async {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid API key')),
      );
      return;
    }

    setState(() => _isSaving = true);
    await context.read<ChatProvider>().updateApiKey(key);
    
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_awesome, size: 60, color: theme.colorScheme.primary),
                  ).animate().scale(duration: 600.ms, curve: Curves.backOut),
                  const SizedBox(height: 30),
                  Text(
                    'Welcome to Smart Assistant',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
                  const SizedBox(height: 10),
                  Text(
                    'To get started, please provide your Google Gemini API key.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withAlpha(150)),
                  ).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),
                  const SizedBox(height: 40),
                  
                  // API Key Input
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Gemini API Key',
                      hintText: 'AIzaSy...',
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.white.withAlpha(150),
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: -20, end: 0),
                  
                  const SizedBox(height: 20),
                  
                  // Help Text
                  TextButton.icon(
                    onPressed: _launchApiKeyUrl,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Don\'t have a key? Get one here'),
                  ).animate().fadeIn(delay: 800.ms),
                  
                  const SizedBox(height: 40),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveKey,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Connect Assistant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ).animate().fadeIn(delay: 1000.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
