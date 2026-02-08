import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
  ];

  static AppLocalizations of(BuildContext context) {
    final AppLocalizations? result =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(result != null, 'No AppLocalizations found');
    return result!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'languageEnglish': 'English',
      'languageHindi': 'Hindi',
      'languageSelectTitle': 'Select Language',
      'searchHint': 'Search courses...',
      'topVideos': 'Top Videos',
      'noResults': 'No Results',
      'viewAll': 'View all',
      'englishSpeakingTitle': 'English Speaking',
      'searchResultsFor': 'Search Results for',
    },
    'hi': {
      'languageEnglish': 'English',
      'languageHindi': 'Hindi',
      'languageSelectTitle': 'Bhasha chune',
      'searchHint': 'Course khoje...',
      'topVideos': 'Top Video',
      'noResults': 'Koi nateeje nahi',
      'viewAll': 'Sab dekhe',
      'englishSpeakingTitle': 'Angrezi Bolna',
      'searchResultsFor': 'Khoj parinaam',
    }
  };

  String _t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  String get languageEnglish => _t('languageEnglish');
  String get languageHindi => _t('languageHindi');
  String get languageSelectTitle => _t('languageSelectTitle');
  String get searchHint => _t('searchHint');
  String get topVideos => _t('topVideos');
  String get noResults => _t('noResults');
  String get viewAll => _t('viewAll');
  String get englishSpeakingTitle => _t('englishSpeakingTitle');

  String searchResultsFor(String query) {
    return '${_t('searchResultsFor')} "$query"';
  }

  String get languageChipLabel {
    if (locale.languageCode == 'hi') {
      return languageHindi;
    }
    return languageEnglish;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
