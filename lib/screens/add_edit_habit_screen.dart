import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

const _emojis = [
  '💧', '🏃', '📚', '🧘', '💊', '🥗',
  '🏋️', '😴', '✍️', '🎸', '🧹', '🚭',
  '☕', '🧠', '🎯', '🌿', '🦷', '🧴',
];

const _colors = [
  Color(0xFF7C6FF7),
  Color(0xFF0EA5E9),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFFEF4444),
  Color(0xFFEC4899),
  Color(0xFF8B5CF6),
  Color(0xFF14B8A6),
];

class AddEditHabitScreen extends StatefulWidget {
  final Habit? habit;
  const AddEditHabitScreen({super.key, this.habit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  late final TextEditingController _nameController;
  late String _emoji;
  late Color _color;
  TimeOfDay? _reminderTime;
  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _nameController = TextEditingController(text: h?.name ?? '');
    _emoji = h?.emoji ?? _emojis.first;
    _color = h?.color ?? _colors.first;
    if (h != null && h.hasReminder) {
      _reminderTime = TimeOfDay(hour: h.reminderHour!, minute: h.reminderMinute!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final existing = widget.habit;
    final habit = Habit(
      id: existing?.id,
      name: _nameController.text.trim(),
      emoji: _emoji,
      color: _color,
      completedDates: existing?.completedDates ?? [],
      reminderHour: _reminderTime?.hour,
      reminderMinute: _reminderTime?.minute,
      createdAt: existing?.createdAt,
    );

    await Hive.box('habits').put(habit.id, habit.toMap());
    await NotificationService.instance.cancelReminder(habit.notificationId);
    if (habit.hasReminder) {
      await NotificationService.instance.scheduleHabitReminder(
        id: habit.notificationId,
        habitName: habit.name,
        emoji: habit.emoji,
        hour: habit.reminderHour!,
        minute: habit.reminderMinute!,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Delete habit',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        ),
        content: Text(
          'Delete "${widget.habit!.name}"? All history will be lost.',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await NotificationService.instance
        .cancelReminder(widget.habit!.notificationId);
    await Hive.box('habits').delete(widget.habit!.id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: AppTheme.surface,
            dialHandColor: AppTheme.accent,
            hourMinuteColor: AppTheme.bg,
            hourMinuteTextColor: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit habit' : 'New habit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _SectionLabel(text: 'Habit name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              autofocus: !_isEditing,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'e.g. Drink 8 glasses of water',
                hintStyle: const TextStyle(color: AppTheme.textTertiary),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppTheme.border, width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: AppTheme.border, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: AppTheme.accent.withOpacity(0.7), width: 1),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Colors.redAccent, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Colors.redAccent, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Please enter a habit name' : null,
            ),
            const SizedBox(height: 28),
            const _SectionLabel(text: 'Icon'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _emojis.map((e) {
                final selected = e == _emoji;
                return GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: selected
                          ? _color.withOpacity(0.18)
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? _color : AppTheme.border,
                        width: selected ? 1.5 : 0.5,
                      ),
                    ),
                    child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            const _SectionLabel(text: 'Color'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: _colors.map((c) {
                final selected = c.value == _color.value;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                  color: c.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1)
                            ]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            const _SectionLabel(text: 'Daily reminder'),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.alarm_outlined,
                      size: 18,
                      color: _reminderTime != null
                          ? AppTheme.accent
                          : AppTheme.textTertiary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _reminderTime != null
                          ? _reminderTime!.format(context)
                          : 'No reminder set',
                      style: TextStyle(
                        color: _reminderTime != null
                            ? AppTheme.textPrimary
                            : AppTheme.textTertiary,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (_reminderTime != null)
                      GestureDetector(
                        onTap: () => setState(() => _reminderTime = null),
                        child: const Icon(Icons.close,
                            size: 16, color: AppTheme.textSecondary),
                      )
                    else
                      const Icon(Icons.chevron_right,
                          size: 18, color: AppTheme.textTertiary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 38),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  _isEditing ? 'Save changes' : 'Add habit',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}
