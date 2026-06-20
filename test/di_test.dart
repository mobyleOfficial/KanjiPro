// DI smoke test — verifies that non-Store dependencies register correctly.
// The ObjectBox Store cannot be opened in the macOS unit-test sandbox (native
// path_provider / objectbox lib restrictions). Store-open validation must be
// done via T13 device/integration run.

import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_domain/kanji_domain.dart';

import 'package:kanji_pro/di/injection.dart';

void main() {
  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());

  setUp(() async {
    // Reset GetIt between tests so registrations don't leak.
    await getIt.reset();
  });

  test('configureDependencies registers KanjiRepository', () async {
    // configureDependencies awaits the Store open, which will throw in the
    // macOS test sandbox (path_provider / native lib unavailable). Catch the
    // whole call and verify what registered before the failure.
    try {
      await configureDependencies();
    } catch (_) {
      // Store-open failure expected in unit-test sandbox — continue.
    }

    // KanjiRepository must always be registered (registered before Store open).
    expect(
      getIt.isRegistered<KanjiRepository>(),
      isTrue,
      reason: 'KanjiRepository must be registered after configureDependencies',
    );
  });
}
