// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'KanjiPro';

  @override
  String get levelN5 => 'JLPT N5';

  @override
  String get study => 'Estudar';

  @override
  String get quiz => 'Quiz';

  @override
  String get modeOnReading => 'On\'yomi';

  @override
  String get modeKunReading => 'Kun\'yomi';

  @override
  String get modeMeaning => 'Significado';

  @override
  String get ttsUnavailable =>
      'Voz em japonês não instalada. Instale nas configurações de leitura de voz do dispositivo.';

  @override
  String get correct => 'Certo';

  @override
  String get wrong => 'Errado';

  @override
  String get results => 'Resultados';
}
