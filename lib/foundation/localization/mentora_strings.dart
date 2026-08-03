import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/widgets.dart';

/// The strings layer — the only place where interface words live.
/// No widget ever codes a string directly: it reads a key from here
/// (the localization equivalent of the Tokens layer).
final class MentoraStrings {
  final Locale locale;
  final Map<String, String> _values;

  const MentoraStrings(this.locale, this._values);

  static MentoraStrings of(BuildContext context) {
    final strings = Localizations.of<MentoraStrings>(context, MentoraStrings);
    if (strings == null) {
      throw StateError(
        'MentoraStrings is not installed above this context — the '
        'localization delegate is part of the official bootstrap.',
      );
    }
    return strings;
  }

  String _get(String key) {
    final value = _values[key];
    if (value == null) {
      // Fail closed: a missing key is a defect, never a silent blank.
      throw StateError('Missing localization key "$key" for $locale.');
    }
    return value;
  }

  String get appTitle => _get('appTitle');
  String get tabHome => _get('tabHome');
  String get tabConsultation => _get('tabConsultation');
  String get tabBusiness => _get('tabBusiness');
  String get tabNotifications => _get('tabNotifications');
  String get tabAccount => _get('tabAccount');
  String get foundationReadyTitle => _get('foundationReadyTitle');
  String get foundationReadyBody => _get('foundationReadyBody');
  String get nothingNeedsAttention => _get('nothingNeedsAttention');
}

/// The per-locale tables. Every key exists in every locale — verified
/// by the foundation tests (a missing key never ships).
const Map<String, Map<String, String>> mentoraStringTables = {
  'fr': {
    'appTitle': 'Mentora',
    'tabHome': 'Accueil',
    'tabConsultation': 'Consultation',
    'tabBusiness': 'Activité',
    'tabNotifications': 'Notifications',
    'tabAccount': 'Compte',
    'foundationReadyTitle': 'Fondation prête',
    'foundationReadyBody':
        'Cette surface accueillera sa plateforme lors des prochaines vagues.',
    'nothingNeedsAttention': 'Rien ne demande votre attention.',
  },
  'en': {
    'appTitle': 'Mentora',
    'tabHome': 'Home',
    'tabConsultation': 'Consultation',
    'tabBusiness': 'Business',
    'tabNotifications': 'Notifications',
    'tabAccount': 'Account',
    'foundationReadyTitle': 'Foundation ready',
    'foundationReadyBody':
        'This surface will host its platform in the coming waves.',
    'nothingNeedsAttention': 'Nothing needs your attention.',
  },
  'ar': {
    'appTitle': 'مينتورا',
    'tabHome': 'الرئيسية',
    'tabConsultation': 'الاستشارة',
    'tabBusiness': 'النشاط',
    'tabNotifications': 'الإشعارات',
    'tabAccount': 'الحساب',
    'foundationReadyTitle': 'الأساس جاهز',
    'foundationReadyBody': 'ستستضيف هذه الواجهة منصتها في الموجات القادمة.',
    'nothingNeedsAttention': 'لا شيء يتطلب انتباهك.',
  },
  'es': {
    'appTitle': 'Mentora',
    'tabHome': 'Inicio',
    'tabConsultation': 'Consulta',
    'tabBusiness': 'Actividad',
    'tabNotifications': 'Notificaciones',
    'tabAccount': 'Cuenta',
    'foundationReadyTitle': 'Base lista',
    'foundationReadyBody':
        'Esta superficie recibirá su plataforma en las próximas olas.',
    'nothingNeedsAttention': 'Nada requiere su atención.',
  },
  'pt': {
    'appTitle': 'Mentora',
    'tabHome': 'Início',
    'tabConsultation': 'Consulta',
    'tabBusiness': 'Atividade',
    'tabNotifications': 'Notificações',
    'tabAccount': 'Conta',
    'foundationReadyTitle': 'Fundação pronta',
    'foundationReadyBody':
        'Esta superfície receberá a sua plataforma nas próximas ondas.',
    'nothingNeedsAttention': 'Nada requer a sua atenção.',
  },
  'de': {
    'appTitle': 'Mentora',
    'tabHome': 'Start',
    'tabConsultation': 'Beratung',
    'tabBusiness': 'Geschäft',
    'tabNotifications': 'Mitteilungen',
    'tabAccount': 'Konto',
    'foundationReadyTitle': 'Fundament bereit',
    'foundationReadyBody':
        'Diese Fläche empfängt ihre Plattform in den kommenden Wellen.',
    'nothingNeedsAttention': 'Nichts erfordert Ihre Aufmerksamkeit.',
  },
};

final class MentoraStringsDelegate
    extends LocalizationsDelegate<MentoraStrings> {
  const MentoraStringsDelegate();

  @override
  bool isSupported(Locale locale) {
    return mentoraStringTables.containsKey(locale.languageCode);
  }

  @override
  Future<MentoraStrings> load(Locale locale) {
    final table = mentoraStringTables[locale.languageCode];
    if (table == null) {
      // Fail closed: an unsupported locale never loads silently.
      throw StateError('Unsupported locale "${locale.languageCode}".');
    }
    return SynchronousFuture(MentoraStrings(locale, table));
  }

  @override
  bool shouldReload(MentoraStringsDelegate old) => false;
}
