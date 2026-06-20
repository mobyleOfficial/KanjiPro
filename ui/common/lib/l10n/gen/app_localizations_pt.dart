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
  String get levelN4 => 'JLPT N4';

  @override
  String get levelN3 => 'JLPT N3';

  @override
  String get levelN2 => 'JLPT N2';

  @override
  String get levelN1 => 'JLPT N1';

  @override
  String levelProgress(int percent) {
    return '$percent% dominado';
  }

  @override
  String get chooseLevel => 'Escolha um nível';

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
  String get next => 'Próximo';

  @override
  String get chooseMode => 'Escolha um modo';

  @override
  String get speakAloud => 'Falar em voz alta';

  @override
  String get examples => 'Exemplos';

  @override
  String get mastered => 'Dominado!';

  @override
  String get mastery => 'Domínio';

  @override
  String get masteryMastered => 'Dominado';

  @override
  String get masteryInProgress => 'Em progresso';

  @override
  String get resetMastery => 'Redefinir';

  @override
  String get resetMasteryTitle => 'Redefinir progresso?';

  @override
  String get resetMasteryBody => 'O domínio deste kanji voltará a 0.';

  @override
  String get cancel => 'Cancelar';
}
