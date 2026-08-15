import '../core/interfaces/enrollment_repository.dart';
import '../models/enrollment.dart';
import 'in_memory_store.dart';
import 'seed_data.dart';

/// LSP: fully substitutable for [IEnrollmentRepository].
class InMemoryEnrollmentRepository implements IEnrollmentRepository {
  InMemoryEnrollmentRepository({
    List<Enrollment>? initial,
    int startingCounter = 3,
  })  : _store = InMemoryStore<Enrollment>(initial ?? SeedData.enrollments()),
        _counter = startingCounter;

  final InMemoryStore<Enrollment> _store;
  int _counter;

  @override
  List<Enrollment> getAll() => _store.getAll();

  @override
  Enrollment? findById(String id) => _store.findById(id);

  @override
  void add(Enrollment enrollment) => _store.add(enrollment);

  @override
  bool remove(String id) => _store.remove(id);

  @override
  bool removeByStudentAndCourse({
    required String studentId,
    required String courseId,
  }) {
    final int index = _store.indexWhere(
      (Enrollment enrollment) =>
          enrollment.studentId == studentId &&
          enrollment.courseId == courseId,
    );
    if (index < 0) {
      return false;
    }
    _store.removeAt(index);
    return true;
  }

  @override
  void removeByStudentId(String studentId) {
    _store.removeWhere(
      (Enrollment enrollment) => enrollment.studentId == studentId,
    );
  }

  @override
  void removeByCourseId(String courseId) {
    _store.removeWhere(
      (Enrollment enrollment) => enrollment.courseId == courseId,
    );
  }

  @override
  String nextId() {
    _counter += 1;
    return 'ENR-${_counter.toString().padLeft(3, '0')}';
  }
}
