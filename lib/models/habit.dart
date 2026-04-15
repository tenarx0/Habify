import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Habit {
  final String id;
  String name;
  String emoji;
  Color color;
  List<String> completedDates;
  int? reminderHour;
  int? reminderMinute;
  final DateTime createdAt;

  Habit({
    String? id,
    required this.name,
    required this.emoji,
    required this.color,
    List<String>? completedDates,
    this.reminderHour,
    this.reminderMinute,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now();

  bool isCompletedOn(DateTime date) => completedDates.contains(_fmt(date));

  bool get isCompletedToday => isCompletedOn(DateTime.now());

  int get currentStreak {
    int streak = 0;
    DateTime cursor = DateTime.now();
    while (completedDates.contains(_fmt(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  bool get hasReminder => reminderHour != null && reminderMinute != null;

  int get notificationId => id.hashCode.abs() % 100000;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'color': color.value,
        'completedDates': completedDates,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Habit.fromMap(Map<dynamic, dynamic> map) => Habit(
        id: map['id'] as String,
        name: map['name'] as String,
        emoji: map['emoji'] as String,
        color: Color(map['color'] as int),
        completedDates: List<String>.from(map['completedDates'] ?? []),
        reminderHour: map['reminderHour'] as int?,
        reminderMinute: map['reminderMinute'] as int?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
