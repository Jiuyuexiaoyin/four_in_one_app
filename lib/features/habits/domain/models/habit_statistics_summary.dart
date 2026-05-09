import 'package:four_in_one_app/features/habits/domain/models/habit_item.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record.dart';
import 'package:four_in_one_app/features/habits/domain/models/habit_record_attachment.dart';

class HabitStatisticsSummary {
  const HabitStatisticsSummary({
    required this.checkInCount,
    required this.makeupCount,
    required this.skipCount,
    required this.effectiveCheckInCount,
    required this.proofCount,
    required this.proofRecordCount,
    required this.activeDays,
    required this.completedDays,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.pauseProtectedDays,
    required this.trackedDays,
    required this.skipDays,
    required this.proofDays,
    required this.currentMonthEffectiveCheckInCount,
    required this.currentMonthActiveDays,
  });

  factory HabitStatisticsSummary.fromRecords({
    required HabitItem habit,
    required Iterable<HabitRecord> records,
    required Iterable<HabitRecordAttachment> attachments,
    required DateTime now,
  }) {
    final validRecords = records
        .where(
          (record) =>
              record.habitId == habit.id && _isValidLocalDate(record.localDate),
        )
        .toList(growable: false);
    final validRecordIds = validRecords.map((record) => record.id).toSet();
    final recordsById = {for (final record in validRecords) record.id: record};
    final effectiveCountsByDate = <String, int>{};
    final trackedDates = <String>{};
    final skipDates = <String>{};
    final currentMonthEffectiveDates = <String>{};
    var checkInCount = 0;
    var makeupCount = 0;
    var skipCount = 0;
    var currentMonthEffectiveCheckInCount = 0;

    final localNow = now.toLocal();
    final currentMonthPrefix =
        '${localNow.year.toString().padLeft(4, '0')}-'
        '${localNow.month.toString().padLeft(2, '0')}-';

    for (final record in validRecords) {
      trackedDates.add(record.localDate);

      switch (record.type) {
        case HabitRecordType.checkIn:
          checkInCount += 1;
          effectiveCountsByDate.update(
            record.localDate,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
          if (record.localDate.startsWith(currentMonthPrefix)) {
            currentMonthEffectiveCheckInCount += 1;
            currentMonthEffectiveDates.add(record.localDate);
          }
          break;
        case HabitRecordType.makeup:
          makeupCount += 1;
          effectiveCountsByDate.update(
            record.localDate,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
          if (record.localDate.startsWith(currentMonthPrefix)) {
            currentMonthEffectiveCheckInCount += 1;
            currentMonthEffectiveDates.add(record.localDate);
          }
          break;
        case HabitRecordType.skip:
          skipCount += 1;
          skipDates.add(record.localDate);
          break;
      }
    }

    final targetCount = habit.targetCountPerDay < 1
        ? HabitItem.defaultTargetCountPerDay
        : habit.targetCountPerDay;
    final completedDays = effectiveCountsByDate.values
        .where((count) => count >= targetCount)
        .length;
    final completedDateKeys = effectiveCountsByDate.entries
        .where((entry) => entry.value >= targetCount)
        .map((entry) => entry.key)
        .toSet();
    final pauseProtectedDateKeys = _pauseProtectedDateKeys(
      intervals: habit.pauseIntervals,
      now: localNow,
      habitCreatedAt: habit.createdAt.toLocal(),
    );
    final currentStreakDays = _currentStreakDays(
      completedDateKeys: completedDateKeys,
      protectedDateKeys: pauseProtectedDateKeys,
      now: localNow,
      habitCreatedAt: habit.createdAt.toLocal(),
    );
    final longestStreakDays = _longestStreakDays(
      completedDateKeys: completedDateKeys,
      protectedDateKeys: pauseProtectedDateKeys,
      habitCreatedAt: habit.createdAt.toLocal(),
    );
    final proofRecordIds = <String>{};
    final proofDates = <String>{};
    var proofImageCount = 0;
    for (final attachment in attachments) {
      if (attachment.habitId == habit.id &&
          validRecordIds.contains(attachment.recordId)) {
        proofImageCount += 1;
        proofRecordIds.add(attachment.recordId);
        final record = recordsById[attachment.recordId];
        if (record != null) {
          proofDates.add(record.localDate);
        }
      }
    }
    final skipOnlyDays = skipDates
        .where((localDate) => !effectiveCountsByDate.containsKey(localDate))
        .length;

    return HabitStatisticsSummary(
      checkInCount: checkInCount,
      makeupCount: makeupCount,
      skipCount: skipCount,
      effectiveCheckInCount: checkInCount + makeupCount,
      proofCount: proofImageCount,
      proofRecordCount: proofRecordIds.length,
      activeDays: effectiveCountsByDate.keys.length,
      completedDays: completedDays,
      currentStreakDays: currentStreakDays,
      longestStreakDays: longestStreakDays,
      pauseProtectedDays: pauseProtectedDateKeys.length,
      trackedDays: trackedDates.length,
      skipDays: skipOnlyDays,
      proofDays: proofDates.length,
      currentMonthEffectiveCheckInCount: currentMonthEffectiveCheckInCount,
      currentMonthActiveDays: currentMonthEffectiveDates.length,
    );
  }

  final int checkInCount;
  final int makeupCount;
  final int skipCount;
  final int effectiveCheckInCount;
  final int proofCount;
  final int proofRecordCount;
  final int activeDays;
  final int completedDays;
  final int currentStreakDays;
  final int longestStreakDays;
  final int pauseProtectedDays;
  final int trackedDays;
  final int skipDays;
  final int proofDays;
  final int currentMonthEffectiveCheckInCount;
  final int currentMonthActiveDays;

  double? get completionRate {
    if (trackedDays == 0) {
      return null;
    }

    return completedDays / trackedDays;
  }

  static bool _isValidLocalDate(String value) {
    return _parseLocalDate(value) != null;
  }

  static int _currentStreakDays({
    required Set<String> completedDateKeys,
    required Set<String> protectedDateKeys,
    required DateTime now,
    required DateTime habitCreatedAt,
  }) {
    if (completedDateKeys.isEmpty) {
      return 0;
    }

    final today = DateTime(now.year, now.month, now.day);
    final todayKey = _localDateKey(today);
    final anchorDate =
        completedDateKeys.contains(todayKey) ||
            protectedDateKeys.contains(todayKey)
        ? today
        : today.subtract(const Duration(days: 1));
    final createdDate = DateTime(
      habitCreatedAt.year,
      habitCreatedAt.month,
      habitCreatedAt.day,
    );

    var streak = 0;
    var cursor = anchorDate;
    while (!cursor.isBefore(createdDate)) {
      final cursorKey = _localDateKey(cursor);
      if (protectedDateKeys.contains(cursorKey)) {
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      if (!completedDateKeys.contains(cursorKey)) {
        break;
      }

      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static int _longestStreakDays({
    required Set<String> completedDateKeys,
    required Set<String> protectedDateKeys,
    required DateTime habitCreatedAt,
  }) {
    final completedDates =
        completedDateKeys
            .map(_parseLocalDate)
            .whereType<DateTime>()
            .toList(growable: false)
          ..sort();
    if (completedDates.isEmpty) {
      return 0;
    }

    final createdDate = DateTime(
      habitCreatedAt.year,
      habitCreatedAt.month,
      habitCreatedAt.day,
    );
    final firstCompletedDate = completedDates.first.isBefore(createdDate)
        ? createdDate
        : completedDates.first;
    final lastCompletedDate = completedDates.last;
    var longest = 0;
    var current = 0;
    var cursor = firstCompletedDate;
    while (!cursor.isAfter(lastCompletedDate)) {
      final cursorKey = _localDateKey(cursor);
      if (protectedDateKeys.contains(cursorKey)) {
        cursor = cursor.add(const Duration(days: 1));
        continue;
      }
      if (completedDateKeys.contains(cursorKey)) {
        current += 1;
        if (current > longest) {
          longest = current;
        }
      } else {
        current = 0;
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    return longest;
  }

  static Set<String> _pauseProtectedDateKeys({
    required Iterable<HabitPauseInterval> intervals,
    required DateTime now,
    required DateTime habitCreatedAt,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final createdDate = DateTime(
      habitCreatedAt.year,
      habitCreatedAt.month,
      habitCreatedAt.day,
    );
    final protectedDateKeys = <String>{};

    for (final interval in intervals) {
      final startDate = _parseLocalDate(interval.startLocalDate);
      final savedEndDate = interval.endLocalDate == null
          ? null
          : _parseLocalDate(interval.endLocalDate!);
      final endDate = savedEndDate ?? today;
      if (startDate == null ||
          startDate.isAfter(today) ||
          endDate.isBefore(startDate)) {
        continue;
      }

      var cursor = startDate.isBefore(createdDate) ? createdDate : startDate;
      final cappedEndDate = endDate.isAfter(today) ? today : endDate;
      while (!cursor.isAfter(cappedEndDate)) {
        protectedDateKeys.add(_localDateKey(cursor));
        cursor = cursor.add(const Duration(days: 1));
      }
    }

    return protectedDateKeys;
  }

  static DateTime? _parseLocalDate(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) {
      return null;
    }

    final year = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final day = int.tryParse(match.group(3)!);
    if (year == null || month == null || day == null) {
      return null;
    }

    final parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }

    return parsed;
  }

  static String _localDateKey(DateTime dateTime) {
    final year = dateTime.year.toString().padLeft(4, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}
