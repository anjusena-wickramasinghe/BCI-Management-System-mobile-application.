import '../core/interfaces/student_repository.dart';
import '../models/student.dart';
import 'seed_data.dart';

/// LSP: fully substitutable for [IStudentRepository].
/// OCP: can be replaced by an API/database repository without changing services.
class InMemoryStudentRepository implements IStudentRepository {
  InMemoryStudentRepository({List<Student>? initial})
      : _students = List<Student>.from(initial ?? SeedData.students());

  final List<Student> _students;

  @override
  List<Student> getAll() => List<Student>.unmodifiable(_students);

  @override
  Student? findById(String id) {
    for (final Student student in _students) {
      if (student.id == id) {
        return student;
      }
    }
    return null;
  }

  @override
  void add(Student student) => _students.add(student);

  @override
  bool update(Student student) {
    final int index =
        _students.indexWhere((Student item) => item.id == student.id);
    if (index < 0) {
      return false;
    }
    _students[index] = student;
    return true;
  }

  @override
  bool remove(String id) {
    final int before = _students.length;
    _students.removeWhere((Student student) => student.id == id);
    return _students.length < before;
  }
}
