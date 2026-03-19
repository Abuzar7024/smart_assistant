import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/suggestion.dart';
import '../models/message.dart';
import '../core/secrets.dart';
import '../core/constants.dart';

enum AiProvider { gemini, mistral, groq, openRouter }

class ApiService {
  late GenerativeModel _geminiModel;
  AiProvider _currentProvider = AiProvider.mistral;
  
  // Provider Configs
  final String _mistralUrl = "https://api.mistral.ai/v1/chat/completions";
  final String _mistralModel = "open-mistral-7b";
  final String _groqUrl = "https://api.groq.com/openai/v1/chat/completions";
  final String _groqModel = "llama3-8b-8192";
  final String _openRouterUrl = "https://openrouter.ai/api/v1/chat/completions";
  final String _openRouterModel = "meta-llama/llama-3.1-8b-instruct:free";

  ApiService({AiProvider? initialProvider}) {
    _currentProvider = initialProvider ?? AiProvider.mistral;
    _initGemini();
  }

  void _initGemini() {
    _geminiModel = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: AppSecrets.geminiApiKey,
      systemInstruction: Content.system("You are a helpful, professional AI. Be natural and warm."),
    );
  }

  void setProvider(AiProvider provider) => _currentProvider = provider;
  AiProvider get currentProvider => _currentProvider;

  Future<String> sendChatMessage(String message, {List<Message> history = const [], String? systemInstruction, bool isFailover = false}) async {
    try {
      String response;
      switch (_currentProvider) {
        case AiProvider.gemini: 
          response = await _sendGeminiMessage(message, history: history);
          break;
        case AiProvider.mistral: 
          response = await _sendMistralMessage(message, history: history, systemInstruction: systemInstruction);
          break;
        case AiProvider.groq:
          response = await _sendGroqMessage(message, history: history, systemInstruction: systemInstruction);
          break;
        case AiProvider.openRouter:
          response = await _sendOpenRouterMessage(message, history: history, systemInstruction: systemInstruction);
          break;
      }

      // If the response contains a Quota/Error message, try failover
      if (response.contains("Quota reached") || response.contains("Error: 429")) {
        return await _handleFailover(message, history, systemInstruction);
      }
      return response;
    } catch (e) {
      if (!isFailover) return await _handleFailover(message, history, systemInstruction);
      return "Critical AI Error: All providers are currently unavailable.";
    }
  }

  Future<String> _handleFailover(String message, List<Message> history, String? systemInstruction) async {
    // Failover order: Groq -> Mistral -> OpenRouter
    final originalProvider = _currentProvider;
    try {
      if (originalProvider != AiProvider.groq) {
        _currentProvider = AiProvider.groq;
        return await sendChatMessage(message, history: history, systemInstruction: systemInstruction, isFailover: true);
      } else if (originalProvider != AiProvider.mistral) {
        _currentProvider = AiProvider.mistral;
        return await sendChatMessage(message, history: history, systemInstruction: systemInstruction, isFailover: true);
      } else {
        _currentProvider = AiProvider.openRouter;
        return await sendChatMessage(message, history: history, systemInstruction: systemInstruction, isFailover: true);
      }
    } catch (_) {
      return "Failover failed. Please check your API keys or internet connection.";
    } finally {
      // We don't restore _currentProvider here to keep the "working" one for the next message
    }
  }

  Future<String> _sendGeminiMessage(String message, {List<Message> history = const []}) async {
    try {
      final chatHistory = history.map((m) => m.sender == 'user' ? Content.text(m.text) : Content.model([TextPart(m.text)])).toList();
      final chat = _geminiModel.startChat(history: chatHistory);
      final res = await chat.sendMessage(Content.text(message));
      return res.text ?? "No response from Gemini.";
    } catch (e) { return "Gemini Error: Quota reached."; }
  }

  Future<String> _sendGroqMessage(String message, {List<Message> history = const [], String? systemInstruction}) async {
    // Try Key 1
    String res = await _sendOpenAiCompatible(_groqUrl, _groqModel, AppSecrets.groqApiKey1, message, history, systemInstruction, "Groq");
    if (res.contains("Error: 429") || res.contains("Quota reached")) {
      // Try Key 2
      return await _sendOpenAiCompatible(_groqUrl, _groqModel, AppSecrets.groqApiKey2, message, history, systemInstruction, "Groq (Key 2)");
    }
    return res;
  }

  Future<String> _sendMistralMessage(String message, {List<Message> history = const [], String? systemInstruction}) async {
    return _sendOpenAiCompatible(_mistralUrl, _mistralModel, AppSecrets.mistralApiKey, message, history, systemInstruction, "Mistral");
  }

  Future<String> _sendOpenRouterMessage(String message, {List<Message> history = const [], String? systemInstruction}) async {
    return _sendOpenAiCompatible(_openRouterUrl, _openRouterModel, AppSecrets.openRouterApiKey, message, history, systemInstruction, "OpenRouter");
  }

  Future<String> _sendOpenAiCompatible(String url, String model, String apiKey, String message, List<Message> history, String? systemInstruction, String provider) async {
    if (apiKey.isEmpty) return "$provider Error: API key missing.";
    try {
      final messages = [{"role": "system", "content": systemInstruction ?? "You are a natural AI."}];
      for (var msg in history.take(10)) {
        messages.add({"role": msg.sender == 'user' ? "user" : "assistant", "content": msg.text});
      }
      messages.add({"role": "user", "content": message});
      final res = await http.post(Uri.parse(url), headers: {"Content-Type": "application/json", "Authorization": "Bearer $apiKey"}, body: jsonEncode({"model": model, "messages": messages}));
      if (res.statusCode == 200) return jsonDecode(res.body)['choices'][0]['message']['content'];
      return "$provider Error: ${res.statusCode}. Quota reached.";
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
