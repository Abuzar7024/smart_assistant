import 'dart:math';

import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/suggestion.dart';
import '../models/message.dart';

import '../core/secrets.dart';

class ApiService {
  late final GenerativeModel _model;

  ApiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AppSecrets.geminiApiKey,
      systemInstruction: Content.system(
        "You are a helpful, professional, yet very natural and friendly AI assistant. "
        "Your goal is to provide generic and high-quality assistance in a conversational manner. "
        "Avoid overly clinical or robotic phrasing. Speak like a supportive human assistant. "
        "Keep your responses concise but warm."
      ),
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
      "How are you today?",
      "Tell me a fun fact",
      "Plan a quick trip",
      "Suggest a good movie",
      "Help me write a note",
      "Explain something simply",
      "Give me a coding tip",
      "What are you up to?",
      "Recommend a book",
      "Solve a math problem"
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

  // POST /chat -> Now uses history for context-aware, natural responses
  Future<String> sendChatMessage(String message, {List<Message> history = const [], String? systemInstruction}) async {
    try {
      final chatHistory = history.map((m) {
        return m.sender == 'user' ? Content.text(m.text) : Content.model([TextPart(m.text)]);
      }).toList();

      // Combine model system instruction with dynamic session instruction if both exist
      final chat = _model.startChat(history: chatHistory);
      
      final content = systemInstruction != null 
          ? Content.multi([TextPart(systemInstruction), TextPart(message)])
          : Content.text(message);

      final response = await chat.sendMessage(content);
      
      return response.text ?? "I'm sorry, I couldn't generate a response.";
    } catch (e) {
      return "Error: $e";
    }
  }

  // Generate a short title based on the first few messages
  Future<String> generateConversationTitle(List<Message> context) async {
    try {
      final chatContext = context.take(3).map((m) => "${m.sender}: ${m.text}").join("\n");
      final prompt = "Give this chat a natural, human-like title (3-5 words) that a person would actually give it. "
          "Avoid robotic summaries like 'Discussion about...'. Just the title text, no quotes:\n\n$chatContext";
          
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
