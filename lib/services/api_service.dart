import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/suggestion.dart';
import '../models/message.dart';
import '../core/secrets.dart';

enum AiProvider { gemini, mistral, groq }

class ApiService {
  late GenerativeModel _geminiModel;
  AiProvider _currentProvider = AiProvider.mistral; // Default to Mistral as per user request
  
  // Mistral Config
  final String _mistralUrl = "https://api.mistral.ai/v1/chat/completions";
  final String _mistralModel = "open-mistral-7b";

  // Groq Config
  final String _groqUrl = "https://api.groq.com/openai/v1/chat/completions";
  final String _groqModel = "llama3-8b-8192";

  ApiService({AiProvider? initialProvider}) {
    _currentProvider = initialProvider ?? AiProvider.mistral;
    _initGemini();
  }

  void _initGemini() {
    _geminiModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AppSecrets.geminiApiKey,
      systemInstruction: Content.system(
        "You are a helpful, professional, yet very natural and friendly AI assistant. "
        "Speak like a supportive human. Keep responses concise and warm."
      ),
    );
  }

  void setProvider(AiProvider provider) {
    _currentProvider = provider;
  }

  AiProvider get currentProvider => _currentProvider;

  Future<String> sendChatMessage(String message, {List<Message> history = const [], String? systemInstruction}) async {
    switch (_currentProvider) {
      case AiProvider.gemini:
        return _sendGeminiMessage(message, history: history, systemInstruction: systemInstruction);
      case AiProvider.mistral:
        return _sendMistralMessage(message, history: history, systemInstruction: systemInstruction);
      case AiProvider.groq:
        return _sendGroqMessage(message, history: history, systemInstruction: systemInstruction);
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
      return response.text ?? "No response from Gemini.";
    } catch (e) {
      return "Gemini Error: Quota reached. Please try Mistral or Groq in Settings.";
    }
  }

  Future<String> _sendMistralMessage(String message, {List<Message> history = const [], String? systemInstruction}) async {
    return _sendOpenAiCompatible(
      url: _mistralUrl,
      model: _mistralModel,
      apiKey: AppSecrets.mistralApiKey,
      message: message,
      history: history,
      systemInstruction: systemInstruction,
      providerName: "Mistral",
    );
  }

  Future<String> _sendGroqMessage(String message, {List<Message> history = const [], String? systemInstruction}) async {
    return _sendOpenAiCompatible(
      url: _groqUrl,
      model: _groqModel,
      apiKey: AppSecrets.groqApiKey,
      message: message,
      history: history,
      systemInstruction: systemInstruction,
      providerName: "Groq",
    );
  }

  Future<String> _sendOpenAiCompatible({
    required String url,
    required String model,
    required String apiKey,
    required String message,
    required List<Message> history,
    required String? systemInstruction,
    required String providerName,
  }) async {
    if (apiKey.isEmpty) return "Please set your $providerName API key in secrets.dart.";
    try {
      final List<Map<String, String>> messages = [];
      messages.add({"role": "system", "content": systemInstruction ?? "You are a natural AI assistant."});
      for (var msg in history.take(10)) {
        messages.add({"role": msg.sender == 'user' ? "user" : "assistant", "content": msg.text});
      }
      messages.add({"role": "user", "content": message});

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $apiKey"},
        body: jsonEncode({"model": model, "messages": messages}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return "$providerName Error: ${response.statusCode}. Check your key in Settings.";
      }
    } catch (e) {
      return "$providerName Request Error: $e";
    }
  }

  Future<String> generateConversationTitle(List<Message> context) async {
    try {
      final chatContext = context.take(3).map((m) => "${m.sender}: ${m.text}").join("\n");
      final prompt = "Give this chat a natural, human-like title (3-5 words). Return ONLY the title:\n\n$chatContext";
      final response = await _geminiModel.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? "New Conversation";
    } catch (e) {
      return "New Conversation";
    }
  }

  Future<SuggestionResponse> getSuggestions({int page = 1, int limit = 10}) async {
    final slice = List.generate(limit, (index) => Suggestion(
      id: index + 1,
      title: ["How are you?", "Fun fact", "Trip plan", "Movie", "Note", "Simply", "Code", "Up to?", "Book", "Math"][index % 10],
      description: "Get a quick starting point for your chat session.",
    ));
    return SuggestionResponse(status: "success", data: slice, pagination: Pagination(
      currentPage: page, totalPages: 5, totalItems: 50, limit: limit, hasNext: true, hasPrevious: false
    ));
  }
}
