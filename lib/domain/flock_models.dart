class FlockBatch {
  final String id;
  String name;
  String species;
  DateTime hatchDate;
  int birdCount;
  Map<String, DateTime> doneVaccines;

  FlockBatch({
    required this.id,
    required this.name,
    required this.species,
    required this.hatchDate,
    required this.birdCount,
    Map<String, DateTime>? doneVaccines,
  }) : doneVaccines = doneVaccines ?? {};

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  int ageDays(DateTime now) =>
      _dateOnly(now).difference(_dateOnly(hatchDate)).inDays;

  int ageWeeks(DateTime now) => ageDays(now) ~/ 7;

  bool isDone(String vaccineId) => doneVaccines.containsKey(vaccineId);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'species': species,
        'hatchDate': hatchDate.toIso8601String(),
        'birdCount': birdCount,
        'doneVaccines': doneVaccines
            .map((k, v) => MapEntry(k, v.toIso8601String())),
      };

  static FlockBatch fromJson(Map<String, dynamic> j) {
    final rawDone = (j['doneVaccines'] as Map?) ?? {};
    final done = <String, DateTime>{};
    rawDone.forEach((k, v) {
      final parsed = DateTime.tryParse(v.toString());
      if (parsed != null) done[k.toString()] = parsed;
    });
    return FlockBatch(
      id: j['id'] as String,
      name: j['name'] as String,
      species: j['species'] as String? ?? 'chicken',
      hatchDate: DateTime.parse(j['hatchDate'] as String),
      birdCount: (j['birdCount'] as num?)?.toInt() ?? 1,
      doneVaccines: done,
    );
  }
}

class MedicationCourse {
  final String id;
  String subject;
  String medId;
  DateTime startDate;
  int eggWithdrawalDays;
  int meatWithdrawalDays;

  MedicationCourse({
    required this.id,
    required this.subject,
    required this.medId,
    required this.startDate,
    required this.eggWithdrawalDays,
    required this.meatWithdrawalDays,
  });

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime get eggClearDate =>
      _dateOnly(startDate).add(Duration(days: eggWithdrawalDays));
  DateTime get meatClearDate =>
      _dateOnly(startDate).add(Duration(days: meatWithdrawalDays));

  int eggDaysLeft(DateTime now) {
    final d = eggClearDate.difference(_dateOnly(now)).inDays;
    return d < 0 ? 0 : d;
  }

  int meatDaysLeft(DateTime now) {
    final d = meatClearDate.difference(_dateOnly(now)).inDays;
    return d < 0 ? 0 : d;
  }

  bool eggSafe(DateTime now) => eggDaysLeft(now) == 0;
  bool meatSafe(DateTime now) => meatDaysLeft(now) == 0;
  bool fullyCleared(DateTime now) => eggSafe(now) && meatSafe(now);

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'medId': medId,
        'startDate': startDate.toIso8601String(),
        'eggDays': eggWithdrawalDays,
        'meatDays': meatWithdrawalDays,
      };

  static MedicationCourse fromJson(Map<String, dynamic> j) => MedicationCourse(
        id: j['id'] as String,
        subject: j['subject'] as String,
        medId: j['medId'] as String,
        startDate: DateTime.parse(j['startDate'] as String),
        eggWithdrawalDays: (j['eggDays'] as num).toInt(),
        meatWithdrawalDays: (j['meatDays'] as num).toInt(),
      );
}

class QuarantineWatch {
  final String id;
  String label;
  String routineId;
  DateTime startDate;
  int days;
  Set<String> checkedTasks;

  QuarantineWatch({
    required this.id,
    required this.label,
    required this.routineId,
    required this.startDate,
    required this.days,
    Set<String>? checkedTasks,
  }) : checkedTasks = checkedTasks ?? {};

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime get clearDate => _dateOnly(startDate).add(Duration(days: days));

  int daysLeft(DateTime now) {
    final d = clearDate.difference(_dateOnly(now)).inDays;
    return d < 0 ? 0 : d;
  }

  double progress(DateTime now) {
    if (days <= 0) return 1;
    final elapsed = days - daysLeft(now);
    return (elapsed / days).clamp(0, 1).toDouble();
  }

  bool cleared(DateTime now) => daysLeft(now) == 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'routineId': routineId,
        'startDate': startDate.toIso8601String(),
        'days': days,
        'checked': checkedTasks.toList(),
      };

  static QuarantineWatch fromJson(Map<String, dynamic> j) {
    final rawChecked = (j['checked'] as List?) ?? [];
    return QuarantineWatch(
      id: j['id'] as String,
      label: j['label'] as String,
      routineId: j['routineId'] as String,
      startDate: DateTime.parse(j['startDate'] as String),
      days: (j['days'] as num).toInt(),
      checkedTasks: rawChecked.map((e) => e.toString()).toSet(),
    );
  }
}

class TriageEntry {
  final String id;
  final DateTime at;
  final List<String> symptomIds;
  final String topConditionId;
  final double topScore;

  TriageEntry({
    required this.id,
    required this.at,
    required this.symptomIds,
    required this.topConditionId,
    required this.topScore,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'at': at.toIso8601String(),
        'symptoms': symptomIds,
        'top': topConditionId,
        'score': topScore,
      };

  static TriageEntry fromJson(Map<String, dynamic> j) {
    final rawSymptoms = (j['symptoms'] as List?) ?? [];
    return TriageEntry(
      id: j['id'] as String,
      at: DateTime.parse(j['at'] as String),
      symptomIds: rawSymptoms.map((e) => e.toString()).toList(),
      topConditionId: j['top'] as String,
      topScore: (j['score'] as num?)?.toDouble() ?? 0,
    );
  }
}
