class ValentinesStatus {
  const ValentinesStatus({
    required this.isUnlocked,
    required this.daysUntil,
    required this.dayIndex,
  });

  final bool isUnlocked;
  final int daysUntil;
  final int? dayIndex;
}

const bool debugForceValentinesUnlocked = false;

ValentinesStatus evaluateValentinesStatus(DateTime now) {
  if (debugForceValentinesUnlocked) {
    return const ValentinesStatus(isUnlocked: true, daysUntil: 0, dayIndex: null);
  }
  final today = DateTime(now.year, now.month, now.day);
  final feb14 = DateTime(today.year, 2, 14);

  if (!today.isBefore(feb14)) {
    return const ValentinesStatus(isUnlocked: true, daysUntil: 0, dayIndex: null);
  }

  final daysUntil = feb14.difference(today).inDays;
  int? dayIndex;
  if (today.month == 2 && today.day >= 1 && today.day <= 13) {
    dayIndex = today.day;
  }

  return ValentinesStatus(isUnlocked: false, daysUntil: daysUntil, dayIndex: dayIndex);
}
