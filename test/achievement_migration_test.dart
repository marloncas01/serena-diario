import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:serena_diario/services/achievement_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    Hive.init(
      Directory.systemTemp.createTempSync('achievements_migration_test').path,
    );
  });

  test('migra logros antiguos de SharedPreferences a Hive', () async {
    SharedPreferences.setMockInitialValues({
      'achievements_v1':
          'first_entry=2024-01-01T10:00:00.000&streak_3=2024-01-02T10:00:00.000',
    });

    final service = AchievementService();
    final all = await service.getAll();
    expect(all, hasLength(2));
    expect(all['first_entry']!.unlockedAt.year, 2024);
    expect(all['streak_3'], isNotNull);
  });
}
