# Smart Assistant 🤖

A premium, industry-level AI companion built with **Flutter** and powered by **Google Gemini 1.5 Flash**. This project demonstrates clean architecture, advanced state management, and modern UI/UX principles.

---

## 🌟 Features

- **Gemini 2.5 Flash Integration**: Real-time natural language processing for intelligent assistance.
- **Premium UI/UX**:
  - Glassmorphic design elements.
  - Interactive message bubbles with custom gradients.
  - Context-aware input handling (disables during processing).
  - Smooth micro-animations using `flutter_animate`.
- **Clean Architecture**: Decoupled layers for Services, Providers, and Models.
- **Dynamic Theming**: Seamless switching between high-contrast Dark and Light modes.
- **Local Persistence**: Chat history saved locally for a continuous experience.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- A Google Gemini API Key from [Google AI Studio](https://aistudio.google.com/app/apikey)

### Configuration
To protect sensitive information, the API key is managed via a local configuration file:

1. Locate `lib/config/gemini_config.dart.example`.
2. Duplicate it and rename it to `gemini_config.dart`.
3. Paste your Gemini API key into the `apiKey` field:
   ```dart
   class GeminiConfig {
     static const String apiKey = 'YOUR_API_KEY_HERE';
   }
   ```

---

## 👨‍💻 About the Author

This project was developed by **Abuzar**, a passionate Flutter developer focused on building high-performance, AI-driven mobile experiences.

🔗 **Portfolio**: [abuzarcode.in](http://abuzarcode.in)
🔗 **GitHub**: [@Abuzar7024](https://github.com/Abuzar7024)

---

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **AI Backend**: Google Generative AI (Gemini)
- **State Management**: Provider
- **Animations**: Flutter Animate
- **Storage**: Hive
- **Navigation**: Go Router
