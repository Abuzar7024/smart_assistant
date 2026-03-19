# 🤖 Smart Assistant: Personalized AI Companion

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Gemini](https://img.shields.io/badge/Gemini%20AI-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://aistudio.google.com/)

A professional-grade, highly customizable smart assistant built with Flutter and powered by Google's Gemini AI. This project demonstrates industry-level state management, persistent storage, and a deep commitment to user-centric personalization.

---

### 🌐 Developer Portfolio
Built and maintained by **Abuzar** - [Explore my work @ abuzarcode.in](https://abuzarcode.in)

---

## 🚀 Key Features

### 🔐 Secure Architecture (GitHub Ready)
- **Gitignored Secrets Layer**: Professional API key management using a secure, excluded `secrets.dart` system.
- **Developer Templates**: Modular configuration ensures the project is safe for public collaboration without exposing sensitive credentials.

### 🎨 Ultra-Personalization
- **Name-Based Interaction**: The AI remembers who you are and treats you like a friend.
- **Dynamic AI Persona**: Choose between **Friendly, Professional, Humorous, or Sarcastic** tones throughout the app.
- **Reaction Styles**: Customize how the AI responds—from **Minimalist** text to **Emoji-heavy** expressions.

### 📱 Premium UI/UX
- **Modern Aesthetic**: Glassmorphism-inspired components, smooth gradients, and a curated dark/light mode.
- **Fluid Animations**: Strategic use of `flutter_animate` for a "living" interface that feels responsive and premium.
- **Recent Chat Dashboard**: Real-time activity feed on the home screen for a seamless "return-to-app" experience.

---

## 🗺️ App Flow: The Journey

1. **Secure Onboarding**: A beautiful 3-step form that captures your identity and preferred AI persona from the very first run.
2. **Personalized Home**: A dashboard showing your unique greeting and a history of your most recent interactions.
3. **Advanced AI Chat**: A high-performance chat interface featuring:
   - **Thinking Indicators**: Visual feedback while the AI processes requests.
   - **Context-Aware Prompts**: Every message is automatically enriched with your persona preferences.
   - **Persistent Memory**: Full conversation history saved locally via Hive.

---

## ⚙️ Setup & Installation

### 1. Project Initialization
```bash
git clone https://github.com/Abuzar7024/smart_assistant.git
cd smart_assistant
flutter pub get
```

### 2. Secure Configuration
For security, your Gemini API key is kept in a private file:
1. Locate `lib/core/secrets.dart.example`.
2. Duplicate it and rename the copy to `secrets.dart`.
3. Open `secrets.dart` and paste your Gemini API key:
   ```dart
   class AppSecrets {
     static const String geminiApiKey = 'your_api_key_here';
   }
   ```

### 3. Run the App
```bash
flutter run
```
```

---

## 👨‍💻 About the Author

**Abuzar** - Flutter Expert & AI Integrator
🔗 [Portfolio](http://abuzarcode.in) | 🔗 [GitHub](https://github.com/Abuzar7024)
