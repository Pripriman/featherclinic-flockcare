import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'condition_library.dart';
import 'flock_models.dart';

class TriageHit {
  final ConditionProfile condition;
  final double score;
  const TriageHit(this.condition, this.score);
}

class FlockRepository extends ChangeNotifier {
  static const _batchKey = 'triage.batches';
  static const _courseKey = 'triage.courses';
  static const _watchKey = 'triage.quarantine';
  static const _historyKey = 'triage.history';
  static const _uuid = Uuid();

  final List<FlockBatch> _batches = [];
  final List<MedicationCourse> _courses = [];
  final List<QuarantineWatch> _watches = [];
  final List<TriageEntry> _history = [];
  bool _loaded = false;

  List<FlockBatch> get batches => List.unmodifiable(_batches);
  List<MedicationCourse> get courses => List.unmodifiable(_courses);
  List<QuarantineWatch> get watches => List.unmodifiable(_watches);
  List<TriageEntry> get history => List.unmodifiable(_history);
  bool get isLoaded => _loaded;

  List<MedicationCourse> activeCourses(DateTime now) =>
      _courses.where((c) => !c.fullyCleared(now)).toList(growable: false);
  List<QuarantineWatch> activeWatches(DateTime now) =>
      _watches.where((w) => !w.cleared(now)).toList(growable: false);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _decodeInto(prefs.getString(_batchKey), _batches, FlockBatch.fromJson);
    _decodeInto(prefs.getString(_courseKey), _courses, MedicationCourse.fromJson);
    _decodeInto(prefs.getString(_watchKey), _watches, QuarantineWatch.fromJson);
    _decodeInto(prefs.getString(_historyKey), _history, TriageEntry.fromJson);
    _batches.sort((a, b) => b.hatchDate.compareTo(a.hatchDate));
    _history.sort((a, b) => b.at.compareTo(a.at));
    _loaded = true;
    notifyListeners();
  }

  void _decodeInto<T>(
    String? raw,
    List<T> target,
    T Function(Map<String, dynamic>) build,
  ) {
    target.clear();
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List;
      for (final e in list) {
        target.add(build(e as Map<String, dynamic>));
      }
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _batchKey, jsonEncode(_batches.map((e) => e.toJson()).toList()));
    await prefs.setString(
        _courseKey, jsonEncode(_courses.map((e) => e.toJson()).toList()));
    await prefs.setString(
        _watchKey, jsonEncode(_watches.map((e) => e.toJson()).toList()));
    await prefs.setString(
        _historyKey, jsonEncode(_history.map((e) => e.toJson()).toList()));
  }

  Future<void> save() async {
    await _persist();
    notifyListeners();
  }

  Future<FlockBatch> addBatch({
    required String name,
    required String species,
    required DateTime hatchDate,
    required int birdCount,
  }) async {
    final batch = FlockBatch(
      id: _uuid.v4(),
      name: name,
      species: species,
      hatchDate: hatchDate,
      birdCount: birdCount,
    );
    _batches.insert(0, batch);
    _batches.sort((a, b) => b.hatchDate.compareTo(a.hatchDate));
    await save();
    return batch;
  }

  Future<void> removeBatch(String id) async {
    _batches.removeWhere((b) => b.id == id);
    await save();
  }

  Future<void> markVaccine(String batchId, String vaccineId, bool done) async {
    final b = _batchById(batchId);
    if (b == null) return;
    if (done) {
      b.doneVaccines[vaccineId] = DateTime.now();
    } else {
      b.doneVaccines.remove(vaccineId);
    }
    await save();
  }

  FlockBatch? _batchById(String id) {
    for (final b in _batches) {
      if (b.id == id) return b;
    }
    return null;
  }

  Future<MedicationCourse> startCourse({
    required String subject,
    required String medId,
    required DateTime startDate,
    required int eggDays,
    required int meatDays,
  }) async {
    final course = MedicationCourse(
      id: _uuid.v4(),
      subject: subject,
      medId: medId,
      startDate: startDate,
      eggWithdrawalDays: eggDays,
      meatWithdrawalDays: meatDays,
    );
    _courses.insert(0, course);
    await save();
    return course;
  }

  Future<void> removeCourse(String id) async {
    _courses.removeWhere((c) => c.id == id);
    await save();
  }

  Future<QuarantineWatch> startWatch({
    required String label,
    required String routineId,
    required DateTime startDate,
    required int days,
  }) async {
    final watch = QuarantineWatch(
      id: _uuid.v4(),
      label: label,
      routineId: routineId,
      startDate: startDate,
      days: days,
    );
    _watches.insert(0, watch);
    await save();
    return watch;
  }

  Future<void> removeWatch(String id) async {
    _watches.removeWhere((w) => w.id == id);
    await save();
  }

  Future<void> toggleTask(String watchId, String taskId) async {
    final w = _watchById(watchId);
    if (w == null) return;
    if (w.checkedTasks.contains(taskId)) {
      w.checkedTasks.remove(taskId);
    } else {
      w.checkedTasks.add(taskId);
    }
    await save();
  }

  QuarantineWatch? _watchById(String id) {
    for (final w in _watches) {
      if (w.id == id) return w;
    }
    return null;
  }

  Future<void> saveTriage(List<String> symptomIds, List<TriageHit> hits) async {
    if (hits.isEmpty) return;
    final entry = TriageEntry(
      id: _uuid.v4(),
      at: DateTime.now(),
      symptomIds: symptomIds,
      topConditionId: hits.first.condition.id,
      topScore: hits.first.score,
    );
    _history.insert(0, entry);
    if (_history.length > 30) _history.removeRange(30, _history.length);
    await save();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await save();
  }

  static List<TriageHit> rankConditions(Set<String> selected) {
    if (selected.isEmpty) return const [];
    final hits = <TriageHit>[];
    for (final c in ConditionLibrary.conditions) {
      var matched = 0.0;
      for (final entry in c.symptomWeights.entries) {
        if (selected.contains(entry.key)) {
          matched += entry.value;
        }
      }
      if (matched <= 0) continue;
      var score = matched / c.profileWeight;
      if (c.lifeThreatening) score = (score + 0.12).clamp(0, 1).toDouble();
      hits.add(TriageHit(c, score.clamp(0, 1).toDouble()));
    }
    hits.sort((a, b) => b.score.compareTo(a.score));
    return hits;
  }
}
