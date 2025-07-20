# 💰 Expense Tracker (Flutter)

A feature-rich personal expense tracking app built with **Flutter**, supporting:

- Persistent storage via **Hive**
- Daily budget tracking & history
- Local **push notifications**
- Coin sound effects on spending
- Clean dark/light themes
- Robust startup error handling

---

## 🧠 Tech Stack

| Feature                | Technology                    |
|------------------------|-------------------------------|
| UI                     | Flutter + Material Design     |
| State Management       | Provider                      |
| Local Storage          | Hive                          |
| Notifications          | flutter_local_notifications   |
| Sound Effects          | audioplayers                  |

---

## 🚀 Getting Started

### 📦 Prerequisites

- Flutter SDK (>= 3.x)
- Android Studio or VS Code
- Dart >= 3.x

---

### ⚙️ Setup Instructions

1. **Clone the repo**
```bash
git clone https://github.com/your-username/expense-tracker-flutter.git
cd expense-tracker-flutter
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Enable Hive Codegen (optional)**
If you're using custom adapters, generate them via:
```bash
flutter packages pub run build_runner build
```

4. **Run the app**
```bash
flutter run
```

---

## 🔔 Features Overview

### ✅ Core Features
- Track daily & monthly expenses
- Add, delete, and view expenses
- Set monthly budget limits
- Store budget change history
- Local notifications for budget reminders

### 🔔 Notifications
- Scheduled daily reminders
- Instant alerts
- Rich progress notifications

### 🔊 Sounds
- Coin sound plays when you add a new expense

---

## 📁 Project Structure

```text
lib/
├── models/                 # Hive data models
├── screens/                # UI screens (Home, Add Expense)
├── services/               # Local storage, notifications, sound, currency
├── main.dart               # App initialization & bootstrapping
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
  provider:
  hive_flutter:
  flutter_local_notifications:
  audioplayers:
```

---

## 📸 Screenshots (Optional)

> You can add screenshots here like:
> - 📊 Monthly budget summary
> - 📝 Expense input form
> - 🔔 Notification prompt

---

## 🛠 Notes

- All data is stored locally using Hive boxes.
- Handles app boot failures gracefully with retry UI.
- Make sure `assets/sounds/coin.wav` exists and is declared in `pubspec.yaml`.

---

## 📄 License

MIT License. Free to use and modify for personal or commercial projects.

---

## ✨ Credits

- Hive for fast local DB
- flutter_local_notifications for cross-platform alerts
- audioplayers for simple sound playback
