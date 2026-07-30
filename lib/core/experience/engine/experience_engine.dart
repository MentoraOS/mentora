import '../models/experience_type.dart';

class ExperienceEngine {
  ExperienceEngine._();

  static ExperienceType _current = ExperienceType.employee;

  static ExperienceType get current => _current;

  static void resolveFromRole(String? role) {
    switch (role) {
      case 'director':
      case 'executive':
      case 'ceo':
        _current = ExperienceType.executive;
        break;

      case 'hr_admin':
      case 'hr_manager':
        _current = ExperienceType.hr;
        break;

      case 'finance_manager':
        _current = ExperienceType.finance;
        break;

      default:
        _current = ExperienceType.employee;
    }
  }

  static bool get isExecutive => _current == ExperienceType.executive;

  static bool get isHR => _current == ExperienceType.hr;

  static bool get isFinance => _current == ExperienceType.finance;

  static bool get isEmployee => _current == ExperienceType.employee;
}
