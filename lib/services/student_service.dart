import '../core/interfaces/enrollment_repository.dart';
import '../core/interfaces/student_repository.dart';
import '../core/interfaces/student_service.dart';
import '../models/student.dart';

/// SRP: student business rules only.
/// DIP: depends on repository abstractions, not concrete storage.
class StudentService implements IStudentService {
  StudentService({
    required IStudentRepository studentRepository,
    required IEnrollmentRepository enrollmentRepository,
  })  : _students = studentRepository,
        _enrollments = enrollmentRepository;

  final IStudentRepository _students;
  final IEnrollmentRepository _enrollments;

  @override
  List<Student> get students => _students.getAll();

  @override
  int get activeCount =>
      _students.getAll().where((Student s) => s.status == 'Active').length;

  @override
  Student? findById(String id) => _students.findById(id);

  @override
  String? add(Student student) {
    if (_students.findById(student.id) != null) {
      return 'A student with this ID already exists.';
    }
    _students.add(student);
    return null;
  }

  @override
  String? update(Student student) {
    if (!_students.update(student)) {
      return 'Student not found.';
    }
    return null;
  }

  @override
  void remove(String id) {
    _students.remove(id);
    _enrollments.removeByStudentId(id);
  }
}
