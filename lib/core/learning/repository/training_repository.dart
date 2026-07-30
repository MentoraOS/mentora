import '../models/course.dart';

class TrainingRepository {
  TrainingRepository._();

  static const List<Course> courses = [
    Course(
      id: 'leadership',
      title: 'Leadership professionnel',
      category: 'Management',
      description:
          'Développez votre capacité à diriger, communiquer et prendre des décisions dans un environnement professionnel.',
      duration: '5h 30min',
      level: 'Intermédiaire',
      progress: 0.65,
    ),
    Course(
      id: 'finance_strategique',
      title: 'Finance stratégique',
      category: 'Finance',
      description:
          'Comprenez les bases de la stratégie financière, du budget et de la prise de décision économique en entreprise.',
      duration: '4h 15min',
      level: 'Avancé',
      progress: 0.35,
    ),
    Course(
      id: 'communication_entreprise',
      title: 'Communication en entreprise',
      category: 'Soft Skills',
      description:
          'Apprenez à communiquer efficacement avec vos collègues, managers et clients.',
      duration: '3h 45min',
      level: 'Débutant',
      progress: 0.80,
    ),
  ];
}
