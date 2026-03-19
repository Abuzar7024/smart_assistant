import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/suggestion.dart';
import '../models/message.dart';
import '../core/secrets.dart';

enum AiProvider { gemini, mistral }

class ApiService {
  late GenerativeModel _geminiModel;
  AiProvider _currentProvider = AiProvider.gemini;
  
  // Mistral Config
  final String _mistralUrl = "https://api.mistral.ai/v1/chat/completions";
  final String _mistralModel = "open-mistral-7b";

  ApiService() {
    _initGemini();
  }

  void _initGemini() {
    _geminiModel = GenerativeModel(
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

  void setProvider(AiProvider provider) {
    _currentProvider = provider;
  }

  AiProvider get currentProvider => _currentProvider;

  // POST /chat -> Now supports both Gemini and Mistral
  Future<String> sendChatMessage(String message, {List<Message> history = const [], String? systemInstruction}) async {
    if (_currentProvider == AiProvider.gemini) {
      return _sendGeminiMessage(message, history: history, systemInstruction: systemInstruction);
    } else {
      return _sendMistralMessage(message, history: history, systemInstruction: systemInstruction);
    }
  }

  Future<String> _sendGeminiMessage(String message, {List<Message> history = const [], String? systemInstruction}) async {
    try {
      final chatHistory = history.map((m) {
        return m.sender == 'user' ? Content.text(m.text) : Content.model([TextPart(m.text)]);
      }).toList();

      final chat = _geminiModel.startChat(history: chatHistory);
      final content = systemInstruction != null 
          ? Content.multi([TextPart(systemInstruction), TextPart(message)])
          : Content.text(message);

      final response = await chat.sendMessage(content);
      return response.text ?? "I'm sorry, I couldn't generate a response.";
    } catch (e) {
      return "Gemini Error: Quota reached. Please switch to Mistral in Settings or try again later.";
    }
  }

  Future<String> _sendMistralMessage(String message, {List<Message> history = const [], String? systemInstruction}) async {
    if (AppSecrets.mistralApiKey.isEmpty) {
      return "Please set your Mistral API key in secrets.dart to use this provider.";
    }

    try {
      final List<Map<String, String>> messages = [];
      if (systemInstruction != null) {
        messages.add({"role": "system", "content": systemInstruction});
      } else {
        messages.add({"role": "system", "content": "You are a natural and helpful AI assistant."});
      }

      for (var msg in history.take(10)) {
        messages.add({
          "role": msg.sender == 'user' ? "user" : "assistant",
          "content": msg.text,
        });
      }
      messages.add({"role": "user", "content": message});

      final response = await http.post(
        Uri.parse(_mistralUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AppSecrets.mistralApiKey}",
        },
        body: jsonEncode({
          "model": _mistralModel,
          "messages": messages,
          "safe_prompt": false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return "Mistral Error: ${response.statusCode}. Please check your Mistral API Key.";
      }
    } catch (e) {
      return "Mistral Request Error: $e";
    }
  }

  Future<String> generateConversationTitle(List<Message> context) async {
    try {
      final chatContext = context.take(3).map((m) => "${m.sender}: ${m.text}").join("\n");
      final prompt = "Give this chat a natural, human-like title (3-5 words). "
          "Return ONLY the title text:\n\n$chatContext";
          
      final response = await _geminiModel.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? "New Conversation";
    } catch (e) {
      return "New Conversation";
    }
  }

  // hardcoded suggestions
  static String _getSuggestionTitle(int index) {
    const titles = ["How are you?", "Fun fact", "Trip plan", "Movie", "Note", "Simply", "Code", "Up to?", "Book", "Math"];
    return titles[index % titles.length];
  }

  static String _getSuggestionDescription(int index) {
      return "Get a quick starting point for your chat session.";
  }

  Future<SuggestionResponse> getSuggestions({int page = 1, int limit = 10}) async {
    final slice = List.generate(limit, (index) => Suggestion(
      id: index + 1,
      title: _getSuggestionTitle(index),
      description: _getSuggestionDescription(index),
    ));
    return SuggestionResponse(status: "success", data: slice, pagination: Pagination(
      currentPage: page, totalPages: 5, totalItems: 50, limit: limit, hasNext: true, hasPrevious: false
    ));
  }
}
