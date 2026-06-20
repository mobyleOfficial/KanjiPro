// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KanjiPro';

  @override
  String get levelN5 => 'JLPT N5';

  @override
  String get levelN4 => 'JLPT N4';

  @override
  String get levelN3 => 'JLPT N3';

  @override
  String get levelN2 => 'JLPT N2';

  @override
  String get levelN1 => 'JLPT N1';

  @override
  String levelProgress(int percent) {
    return '$percent% mastered';
  }

  @override
  String get chooseLevel => 'Choose a level';

  @override
  String get study => 'Study';

  @override
  String get quiz => 'Quiz';

  @override
  String get modeOnReading => 'On\'yomi';

  @override
  String get modeKunReading => 'Kun\'yomi';

  @override
  String get modeMeaning => 'Meaning';

  @override
  String get ttsUnavailable =>
      'Japanese voice not installed. Install it in your device\'s text-to-speech settings.';

  @override
  String get correct => 'Correct';

  @override
  String get wrong => 'Wrong';

  @override
  String get results => 'Results';

  @override
  String quizScore(int correct, int total) {
    return '$correct / $total';
  }

  @override
  String get retry => 'Retry';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get next => 'Next';

  @override
  String get chooseMode => 'Choose a mode';

  @override
  String get speakAloud => 'Speak aloud';

  @override
  String get examples => 'Examples';
}
