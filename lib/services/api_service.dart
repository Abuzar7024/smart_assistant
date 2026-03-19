import 'dart:math';

import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/suggestion.dart';
import '../models/message.dart';

import '../core/secrets.dart';

class ApiService {
  late final GenerativeModel _model;

  ApiService() {
    // The API key is stored in a gitignored 'secrets.dart' file for security.
    // See 'secrets.dart.example' for how to set this up for your own local environment.
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: AppSecrets.geminiApiKey,
    );
  }

  // updateApiKey is no longer needed as the key is hardcoded.
  void updateApiKey(String apiKey) {}

  // Simulated delay to mimic network latency for suggestions if needed
  static const Duration _delay = Duration(milliseconds: 800);

  // Hardcoded suggestions for simulation
  final List<Suggestion> _allSuggestions = List.generate(
    50,
    (index) => Suggestion(
      id: index + 1,
      title: _getSuggestionTitle(index),
      description: _getSuggestionDescription(index),
    ),
  );

  static String _getSuggestionTitle(int index) {
    const titles = [
      "Summarize my notes",
      "Generate email reply",
      "Explain Flutter state management",
      "Recipe for pancakes",
      "Write a short story",
      "Translate to Spanish",
      "Calculate monthly budget",
      "Analyze stock trends",
      "Plan a workout",
      "Debug a Dart exception"
    ];
    return titles[index % titles.length];
  }

  static String _getSuggestionDescription(int index) {
    const descriptions = [
      "Get a concise summary of your text",
      "Create a professional email response",
      "Understand Provider, Riverpod, and Bloc",
      "Simple steps for delicious pancakes",
      "A creative tale about robots",
      "Convert English text to Spanish",
      "Organize your finances effectively",
      "Market analysis for the top 5 stocks",
      "30-minute full body exercise routine",
      "Step-by-step guide to fixing common errors"
    ];
    return descriptions[index % descriptions.length];
  }

  // GET /suggestions?page={page}&limit={limit}
  Future<SuggestionResponse> getSuggestions({int page = 1, int limit = 10}) async {
    await Future.delayed(_delay);

    final start = (page - 1) * limit;
    final end = start + limit;
    final totalItems = _allSuggestions.length;
    final totalPages = (totalItems / limit).ceil();

    final slice = _allSuggestions.sublist(
      min(start, totalItems),
      min(end, totalItems),
    );

    return SuggestionResponse(
      status: "success",
      data: slice,
      pagination: Pagination(
        currentPage: page,
        totalPages: totalPages,
        totalItems: totalItems,
        limit: limit,
        hasNext: page < totalPages,
        hasPrevious: page > 1,
      ),
    );
  }

  // POST /chat -> Now uses Gemini with personalization!
  Future<String> sendChatMessage(String message, {String? systemInstruction}) async {
    try {
      final content = [
        if (systemInstruction != null) Content.text(systemInstruction),
        Content.text(message),
      ];
      final response = await _model.generateContent(content);
      
      return response.text ?? "I'm sorry, I couldn't generate a response.";
    } catch (e) {
      return "Error: $e";
    }
  }

  // Generate a short title based on the first few messages
  Future<String> generateConversationTitle(List<Message> context) async {
    try {
      final chatContext = context.take(3).map((m) => "${m.sender}: ${m.text}").join("\n");
      final prompt = "Summarize this conversation into a short, creative 3-5 word title. "
          "Return ONLY the title text, no quotes or additional formatting:\n\n$chatContext";
          
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? "New Conversation";
    } catch (e) {
      return "New Conversation";
    }
  }

  // GET /chat/history
  Future<List<Message>> getChatHistory() async {
    // In a real app, this would fetch from a database or storage.
    // For now, returning an empty list as we handle history in ChatProvider.
    return [];
  }
}
