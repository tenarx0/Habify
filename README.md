# Habify

A daily habit tracker for Android. Build consistent routines by tracking your habits, monitoring streaks, setting daily reminders, and reviewing your weekly completion rate through a built-in chart.

Built for **Wellpath Health & Wellness** — a health coaching company that needed a simple, distraction-free mobile app for their clients to track daily wellness habits like hydration, exercise, reading, and sleep.

---

## Features

- Create habits with a custom name, emoji icon, and color
- Mark habits as complete with a single tap — progress is reflected instantly
- Automatic streak calculation — consecutive days of completion
- Daily reminder notifications per habit, scheduled at your chosen time
- Today's progress card with a linear progress bar
- Weekly bar chart showing day-by-day completion rate (via fl_chart)
- Swipe a habit left to delete it, with a confirmation dialog
- Long-press a habit card to open the edit screen
- All data stored locally on device using Hive — no account or internet required

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter |
| Local storage | Hive + hive_flutter |
| Charts | fl_chart |
| Notifications | flutter_local_notifications |
| Date formatting | intl |
| ID generation | uuid |
| Timezone support | timezone |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.22 or higher
- Android device or emulator (Android 8.0+)
- A connected Android device with USB debugging enabled, or an emulator running

### Setup

```bash
# 1. Create a new Flutter project with the same name
flutter create habify

# 2. Replace the following generated files with those from this zip:
#    - pubspec.yaml
#    - lib/  (replace the entire folder)
#    - android/app/src/main/AndroidManifest.xml

# 3. Install dependencies
flutter pub get

# 4. Run on a connected device or emulator
flutter run
```

> The AndroidManifest.xml included in this project adds the necessary permissions
> for scheduling exact alarms and posting notifications on Android 12 and above.

### Build a release APK

```bash
flutter build apk --release
```

The output APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

---

## Project Structure

```
habify/
├── pubspec.yaml
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml       # Notification + alarm permissions
└── lib/
    ├── main.dart                     # Entry point — Hive init, timezone, notifications
    ├── theme/
    │   └── app_theme.dart            # Dark theme tokens and ThemeData
    ├── models/
    │   └── habit.dart                # Habit model with toMap / fromMap
    ├── services/
    │   └── notification_service.dart # Schedule and cancel daily reminders
    ├── screens/
    │   ├── home_screen.dart          # Main screen — habit list, progress, chart
    │   └── add_edit_habit_screen.dart # Form to create or update a habit
    └── widgets/
        ├── habit_tile.dart           # Individual habit card with swipe-to-delete
        └── weekly_chart.dart         # 7-day bar chart using fl_chart
```

---

## Permissions Used

| Permission | Purpose |
|------------|---------|
| `POST_NOTIFICATIONS` | Show daily reminder notifications |
| `SCHEDULE_EXACT_ALARM` | Schedule reminders at precise times |
| `USE_EXACT_ALARM` | Backup exact alarm permission for API 33+ |
| `RECEIVE_BOOT_COMPLETED` | Reschedule reminders after device reboot |
| `VIBRATE` | Vibrate on notification delivery |

---

## Notes

- The app is portrait-only by design
- Habit data is persisted in a Hive box named `habits` using key-value maps
- Streaks are calculated at runtime from the `completedDates` list — no separate counter is stored
- Notification IDs are derived from the habit UUID using a stable hash — safe to reschedule on edit

---

*Developed by [@TENARX0](https://github.com/TENARX0)*
