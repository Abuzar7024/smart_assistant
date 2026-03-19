# Smart Assistant 🤖

A premium, industry-level AI companion built with **Flutter** and powered by **Google Gemini**.

---

## 🌟 Features

- **Zero-Configuration**: Works out of the box—no API key setup required!
- **Dynamic Onboarding**: Simple name-based setup for a personal touch.
- **Premium UI/UX**: Glassmorphic design, custom animations, and clean aesthetics.
- **Over-the-Air Updates**: Powered by Shorebird for instant improvements.

---

## 🚀 Quick Start

### 1. Installation
Clone the repository and install dependencies:
```bash
git clone https://github.com/Abuzar7024/smart_assistant.git
cd smart_assistant
flutter pub get
```

### 2. Configuration
To keep API keys secure, this project uses a gitignored configuration file:

1. Locate `lib/core/secrets.dart.example`.
2. Duplicate it and rename the copy to `secrets.dart` (in the same folder).
3. Open `secrets.dart` and paste your Gemini API key:
   ```dart
   class AppSecrets {
     static const String geminiApiKey = 'YOUR_API_KEY_HERE';
   }
   ```

### 3. Run the App
```bash
flutter run
```
On the first run, simply enter your name, and you're ready to chat!

---

## 🛠️ Advanced: Over-the-Air Updates (Shorebird)

To enable instant hotfixes on Android/iOS, install the Shorebird CLI:

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy ByPass -Command "irm https://raw.githubusercontent.com/shorebirdtech/install/main/install.ps1 | iex"
```

Then initialize it in the project:
```bash
shorebird init
```

---

## 👨‍💻 About the Author

**Abuzar** - Flutter Expert & AI Integrator
🔗 [Portfolio](http://abuzarcode.in) | 🔗 [GitHub](https://github.com/Abuzar7024)
