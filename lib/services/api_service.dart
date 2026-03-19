import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/suggestion.dart';
import '../models/message.dart';
import '../core/secrets.dart';

enum AiProvider { gemini, mistral, groq, openRouter }

class ApiService {
  late GenerativeModel _geminiModel;
  AiProvider _currentProvider = AiProvider.mistral;
  
  // Mistral Config
  final String _mistralUrl = "https://api.mistral.ai/v1/chat/completions";
  final String _mistralModel = "open-mistral-7b";

  // Groq Config
  final String _groqUrl = "https://api.groq.com/openai/v1/chat/completions";
  final String _groqModel = "llama3-8b-8192";

  // OpenRouter Config
  final String _openRouterUrl = "https://openrouter.ai/api/v1/chat/completions";
  final String _openRouterModel = "meta-llama/llama-3.1-8b-instruct:free";

  ApiService({AiProvider? initialProvider}) {
    _currentProvider = initialProvider ?? AiProvider.mistral;
    _initGemini();
  }

  void _initGemini() {
    _geminiModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AppSecrets.geminiApiKey,
      systemInstruction: Content.system(
        "You are a helpful, professional AI. Be natural, conversational, and warm."
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
      case AiProvider.openRouter:
        return _sendOpenRouterMessage(message, history: history, systemInstruction: systemInstruction);
    }
  }

  Future<String> _sendGeminiMessage(String message, {List<Message> history = const [], String? systemInstruction}) async {
    try {
      final chatHistory = history.map((m) => m.sender == 'user' ? Content.text(m.text) : Content.model([TextPart(m.text)])).toList();
      final chat = _geminiModel.startChat(history: chatHistory);
      final response = await chat.sendMessage(Content.text(message));
      return response.text ?? "No response from Gemini.";
    } catch (e) {
      return "Gemini Error: Quota reached. Switch to Mistral, Groq, or OpenRouter in Settings.";
    }
  }

  Future<String> _sendMistralMessage(String message, {List<Message> history = const [], String? systemInstruction}) async {
    return _sendOpenAiCompatible(_mistralUrl, _mistralModel, AppSecrets.mistralApiKey, message, history, systemInstruction, "Mistral");
  }

  Future<String> _sendGroqMessage(String message, {List<Message> history = const [], String? systemInstruction}) async {
    return _sendOpenAiCompatible(_groqUrl, _groqModel, AppSecrets.groqApiKey, message, history, systemInstruction, "Groq");
  }

  Future<String> _sendOpenRouterMessage(String message, {List<Message> history = const [], String? systemInstruction}) async {
    return _sendOpenAiCompatible(_openRouterUrl, _openRouterModel, AppSecrets.openRouterApiKey, message, history, systemInstruction, "OpenRouter");
  }

  Future<String> _sendOpenAiCompatible(String url, String model, String apiKey, String message, List<Message> history, String? systemInstruction, String provider) async {
    if (apiKey.isEmpty) return "Please set your $provider API key in secrets.dart.";
    try {
      final messages = [{"role": "system", "content": systemInstruction ?? "You are a natural AI."}];
      for (var msg in history.take(10)) {
        messages.add({"role": msg.sender == 'user' ? "user" : "assistant", "content": msg.text});
      }
      messages.add({"role": "user", "content": message});
      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $apiKey"},
        body: jsonEncode({"model": model, "messages": messages}),
      );
      if (res.statusCode == 200) return jsonDecode(res.body)['choices'][0]['message']['content'];
      return "$provider Error: ${res.statusCode}. Check your key.";
    } catch (e) { return "$provider Request Error: $e"; }
  }

  Future<String> generateConversationTitle(List<Message> context) async {
    try {
      final chatContext = context.take(3).map((m) => "${m.sender}: ${m.text}").join("\n");
      final res = await _geminiModel.generateContent([Content.text("Short creative title for this chat:\n\n$chatContext")]);
      return res.text?.trim() ?? "New Conversation";
    } catch (_) { return "New Conversation"; }
  }

  Future<SuggestionResponse> getSuggestions({int page = 1, int limit = 10}) async {
    final slice = List.generate(limit, (index) => Suggestion(id: index+1, title: "Suggestion ${index+1}", description: "Quick start."));
    return SuggestionResponse(status: "success", data: slice, pagination: Pagination(currentPage: page, totalPages: 5, totalItems: 50, limit: limit, hasNext: true, hasPrevious: false));
  }
}
