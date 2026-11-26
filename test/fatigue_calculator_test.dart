import 'package:flutter_test/flutter_test.dart';
import 'package:performance_tracker/src/features/Workout/models/fatigue.model.dart';
import 'package:performance_tracker/src/features/Workout/models/routine.model.dart';
import 'package:performance_tracker/src/features/Workout/services/fatigue.service.dart';

String dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

Workout workout(String name, Map<String, double> volumes, List<TrackEntry> entries) {
  return Workout(
    name: name,
    sets: [WorkSet(value: 20, history: entries, pr: 0, enabled: true)],
    enabled: true,
    desc: '',
    volumes: [
      for (final v in volumes.entries)
        WorkoutVolume(muscleName: v.key, volume: v.value),
    ],
  );
}

void main() {
  final day = DateTime(2026, 11, 26);
  final bench1 = TrackEntry(entryDate: day.add(const Duration(hours: 9)), value: 10);
  final fly = TrackEntry(entryDate: day.add(const Duration(hours: 10)), value: 12);
  final bench2 = TrackEntry(entryDate: day.add(const Duration(hours: 11)), value: 8);
  final yesterday = TrackEntry(entryDate: day.subtract(const Duration(hours: 5)), value: 9);

  final bench = workout('Bench', {'chest': 1, 'triceps': 0.5}, [bench1, bench2]);
  final flyW = workout('Fly', {'chest': 0.8}, [fly]);
  final rows = workout('Rows', {'back': 1}, [yesterday]);

  // Fly's volumes changed after it was tracked: the record keeps the old ones.
  final records = {
    fly.id: FatigueEntry(trackEntryId: fly.id, muscleFatigue: {'chest': 0.5}),
  };

  FatigueCalculator calc() =>
      FatigueCalculator([bench, flyW, rows], records, dateKey);

  test('track entries get unique ids', () {
    expect({bench1.id, fly.id, bench2.id, yesterday.id}.length, 4);
    expect(TrackEntry(entryDate: day, value: 1, id: '').id, isNotEmpty);
    expect(TrackEntry(entryDate: day, value: 1, id: 'keep').id, 'keep');
  });

  test('first set of the day has no fatigue before it', () {
    expect(calc().fatigueBefore(bench1), isEmpty);
    expect(calc().contextFor(bench1, bench), 0);
  });

  test('fatigue before a set sums only earlier sets of that day', () {
    // bench1 (no record -> current volumes) + fly (record).
    expect(calc().fatigueBefore(bench2), {'chest': 1.5, 'triceps': 0.5});
    // chest 1.5 + triceps 0.5
    expect(calc().contextFor(bench2, bench), 2.0);
  });

  test('one identical earlier set is one equivalent set', () {
    final s1 = TrackEntry(entryDate: day.add(const Duration(hours: 9)), value: 10);
    final s2 = TrackEntry(entryDate: day.add(const Duration(hours: 10)), value: 9);
    final press = workout('Press', {'chest': 1, 'shoulders': 0.5}, [s1, s2]);
    final c = FatigueCalculator([press], {}, dateKey);
    // chest 1 + shoulders 0.5, equal to the workout's total volume.
    expect(c.contextFor(s2, press), 1.5);
  });

  test('context ignores muscles the set does not work', () {
    final s1 = TrackEntry(entryDate: day.add(const Duration(hours: 9)), value: 10);
    final s2 = TrackEntry(entryDate: day.add(const Duration(hours: 10)), value: 9);
    final curl = workout('Curl', {'biceps': 1}, [s1]);
    final press = workout('Press', {'chest': 1, 'shoulders': 0.5}, [s2]);
    final c = FatigueCalculator([curl, press], {}, dateKey);
    expect(c.contextFor(s2, press), 0);
  });

  test('daily fatigue sums every set of the day', () {
    expect(calc().dailyFatigue(day), {'chest': 2.5, 'triceps': 1.0});
    expect(calc().dailyFatigue(yesterday.entryDate), {'back': 1.0});
  });

  test('removed entries stop counting even if their record remains', () {
    bench.sets.first.history.remove(bench1);
    addTearDown(() => bench.sets.first.history.insert(0, bench1));
    records[bench1.id] =
        FatigueEntry(trackEntryId: bench1.id, muscleFatigue: {'chest': 9});
    expect(calc().fatigueBefore(bench2), {'chest': 0.5});
  });

  test('past days exclude today, most recent first', () {
    final past = calc().pastDays(before: day.add(const Duration(hours: 12)));
    expect(past.map((d) => d.date), [DateTime(2026, 11, 25)]);
  });
}
