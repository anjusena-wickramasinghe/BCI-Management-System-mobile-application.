import '../core/interfaces/enrollment_repository.dart';
import '../models/enrollment.dart';
import 'seed_data.dart';

/// LSP: fully substitutable for [IEnrollmentRepository].
class InMemoryEnrollmentRepository implements IEnrollmentRepository {
  InMemoryEnrollmentRepository({
    List<Enrollment>? initial,
    int startingCounter = 3,
  })  : _enrollments = List<Enrollment>.from(initial ?? SeedData.enrollments()),
        _counter = startingCounter;

  final List<Enrollment> _enrollments;
  int _counter;

  @override
  List<Enrollment> getAll() => List<Enrollment>.unmodifiable(_enrollments);

  @override
  Enrollment? findById(String id) {
    for (final Enrollment enrollment in _enrollments) {
      if (enrollment.id == id) {
        return enrollment;
      }
    }
    return null;
  }

  @override
  void add(Enrollment enrollment) => _enrollments.add(enrollment);

  @override
  bool remove(String id) {
    final int before = _enrollments.length;
    _enrollments.removeWhere((Enrollment e) => e.id == id);
    return _enrollments.length < before;
  }

  @override
  bool removeByStudentAndCourse({
    required String studentId,
    required String courseId,
  }) {
    final int index = _enrollments.indexWhere(
      (Enrollment enrollment) =>
          enrollment.studentId == studentId &&
          enrollment.courseId == courseId,
    );
    if (index < 0) {
      return false;
    }
    _enrollments.removeAt(index);
    return true;
  }

  @override
  void removeByStudentId(String studentId) {
    _enrollments.removeWhere(
      (Enrollment enrollment) => enrollment.studentId == studentId,
    );
  }

  @override
  void removeByCourseId(String courseId) {
    _enrollments.removeWhere(
      (Enrollment enrollment) => enrollment.courseId == courseId,
    );
  }

  @override
  String nextId() {
    _counter += 1;
    return 'ENR-${_counter.toString().padLeft(3, '0')}';
  }
}
