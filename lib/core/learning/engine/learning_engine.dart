import '../models/certificate.dart';
import '../models/course.dart';
import '../models/learning_progress.dart';
import '../models/lesson.dart';
import '../repository/learning_progress_repository.dart';
import '../repository/lesson_repository.dart';

enum LearningLessonStatus { completed, current, locked }

class LearningEngine {
  LearningEngine._();

  static Course? _currentCourse;
  static Lesson? _currentLesson;
  static LearningProgress? _currentProgress;
  static Certificate? _currentCertificate;

  static Course? get currentCourse => _currentCourse;
  static Lesson? get currentLesson => _currentLesson;
  static LearningProgress? get currentProgress => _currentProgress;
  static Certificate? get currentCertificate => _currentCertificate;

  static double get progress => _currentProgress?.progress ?? 0;
  static bool get isCompleted => _currentProgress?.completed ?? false;

  static LearningLessonStatus lessonStatus({
    required List<Lesson> lessons,
    required Lesson lesson,
  }) {
    final progress = _currentProgress;

    if (progress == null) {
      return lesson.order == 1
          ? LearningLessonStatus.current
          : LearningLessonStatus.locked;
    }

    final currentIndex = lessons.indexWhere(
      (item) => item.id == progress.currentLessonId,
    );

    final lessonIndex = lessons.indexWhere((item) => item.id == lesson.id);

    if (currentIndex == -1) {
      return lesson.order == 1
          ? LearningLessonStatus.current
          : LearningLessonStatus.locked;
    }

    if (lessonIndex < currentIndex) {
      return LearningLessonStatus.completed;
    }

    if (lesson.id == progress.currentLessonId) {
      return LearningLessonStatus.current;
    }

    return LearningLessonStatus.locked;
  }

  static void startCourse({required String userId, required Course course}) {
    final lessons = LessonRepository.lessonsForCourse(course.id);

    if (lessons.isEmpty) {
      _currentCourse = course;
      _currentLesson = null;
      _currentProgress = null;
      return;
    }

    final firstLesson = lessons.first;

    final progress = LearningProgress(
      id: 'progress_${userId}_${course.id}',
      userId: userId,
      courseId: course.id,
      currentLessonId: firstLesson.id,
      progress: 0,
      studyTime: Duration.zero,
      startedAt: DateTime.now(),
      lastAccessAt: DateTime.now(),
    );

    LearningProgressRepository.saveProgress(progress);

    _currentCourse = course;
    _currentLesson = firstLesson;
    _currentProgress = progress;
  }

  static void continueCourse({required String userId, required Course course}) {
    final progress = LearningProgressRepository.findByCourse(userId, course.id);

    final lessons = LessonRepository.lessonsForCourse(course.id);

    if (progress == null) {
      startCourse(userId: userId, course: course);
      return;
    }

    _currentCourse = course;
    _currentProgress = progress;
    _currentLesson =
        LessonRepository.findById(progress.currentLessonId) ??
        (lessons.isNotEmpty ? lessons.first : null);
  }

  static void openLesson({required Course course, required Lesson lesson}) {
    _currentCourse = course;
    _currentLesson = lesson;
  }

  static void completeCurrentLesson({required String userId}) {
    if (_currentCourse == null || _currentLesson == null) {
      return;
    }

    final lessons = LessonRepository.lessonsForCourse(_currentCourse!.id);

    if (lessons.isEmpty) {
      return;
    }

    final currentIndex = lessons.indexWhere(
      (lesson) => lesson.id == _currentLesson!.id,
    );

    final completedLessons = currentIndex + 1;
    final newProgress = completedLessons / lessons.length;

    final nextLesson = currentIndex + 1 < lessons.length
        ? lessons[currentIndex + 1]
        : _currentLesson!;

    final progress = LearningProgress(
      id: 'progress_${userId}_${_currentCourse!.id}',
      userId: userId,
      courseId: _currentCourse!.id,
      currentLessonId: nextLesson.id,
      progress: newProgress,
      studyTime:
          (_currentProgress?.studyTime ?? Duration.zero) +
          (_currentLesson?.duration ?? Duration.zero),
      completed: newProgress >= 1,
      startedAt: _currentProgress?.startedAt ?? DateTime.now(),
      completedAt: newProgress >= 1 ? DateTime.now() : null,
      lastAccessAt: DateTime.now(),
    );

    LearningProgressRepository.saveProgress(progress);

    _currentProgress = progress;
    _currentLesson = nextLesson;
  }

  static void setCertificate(Certificate certificate) {
    _currentCertificate = certificate;
  }

  static void clear() {
    _currentCourse = null;
    _currentLesson = null;
    _currentProgress = null;
    _currentCertificate = null;
  }
}
