import 'dart:math';

import '../constants.dart';
import '../models/kanji_progress.dart';
import '../models/progress_status.dart';

class SelectParams {
  const SelectParams({
    required this.pool,
    required this.lastShown,
    required this.random,
  });

  final List<KanjiProgress> pool;
  final String? lastShown;
  final Random random;
}

class SelectNextKanji {
  String? call(SelectParams params) {
    final learning = params.pool
        .where((e) => e.status == ProgressStatus.learning)
        .toList();
    final mastered = params.pool
        .where((e) => e.status == ProgressStatus.mastered)
        .toList();

    if (learning.isEmpty && mastered.isEmpty) return null;

    // Reminder branch: with kReminderWeight probability, pick a mastered one.
    if (mastered.isNotEmpty &&
        (learning.isEmpty || params.random.nextDouble() < kReminderWeight)) {
      return mastered[params.random.nextInt(mastered.length)].literal;
    }

    // Difficulty-weighted pick among learning: weight = (target - hitCount) + 1.
    final weights = <int>[];
    var total = 0;
    for (final entry in learning) {
      final weight = (kMasteryTarget - entry.hitCount) + 1;
      weights.add(weight);
      total += weight;
    }

    var roll = params.random.nextInt(total);
    for (var i = 0; i < learning.length; i++) {
      roll -= weights[i];
      if (roll < 0) {
        final pick = learning[i].literal;
        // Avoid immediate repeat unless it's the only learning option.
        if (pick == params.lastShown && learning.length > 1) {
          return learning[(i + 1) % learning.length].literal;
        }
        return pick;
      }
    }
    return learning.last.literal;
  }
}
