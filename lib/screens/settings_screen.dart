import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/chat_provider.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final chatProvider = context.read<ChatProvider>();
    _nameController = TextEditingController(text: chatProvider.userName);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(theme, 'Personalization'),
          const SizedBox(height: 15),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Display Name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onChanged: (value) => chatProvider.updateUserName(value),
          ),
          const SizedBox(height: 30),
          
          _buildSectionHeader(theme, 'AI Engine (Quota Backup)'),
          const SizedBox(height: 15),
          _buildDropdownTile(
            title: 'Provider',
            icon: Icons.hub_outlined,
            value: chatProvider.currentProvider == AiProvider.gemini ? 'Gemini (Google)' : 'Mistral (Backup)',
            items: ['Gemini (Google)', 'Mistral (Backup)'],
            onChanged: (value) {
              if (value == 'Gemini (Google)') {
                chatProvider.setProvider(AiProvider.gemini);
              } else {
                chatProvider.setProvider(AiProvider.mistral);
              }
            },
          ),
          if (chatProvider.currentProvider == AiProvider.mistral)
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 8),
              child: Text(
                "Tip: Mistral is a great free alternative if Gemini reaches its limit.",
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
              ),
            ),
          const SizedBox(height: 30),

          _buildSectionHeader(theme, 'Chat Persona'),
          
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Smart Assistant v1.1.0',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withAlpha(100)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 15),
          Expanded(child: Text(title)),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
