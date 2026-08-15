import '../core/app_constants.dart';
import '../core/interfaces/course_repository.dart';
import '../core/interfaces/enrollment_repository.dart';
import '../core/interfaces/enrollment_service.dart';
import '../core/interfaces/student_repository.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../models/student.dart';

/// SRP: enrolment rules and student–course linking only.
/// DIP: depends on repository abstractions (can swap in-memory for API later).
class EnrollmentService implements IEnrollmentService {
  EnrollmentService({
    required IStudentRepository studentRepository,
    required ICourseRepository courseRepository,
    required IEnrollmentRepository enrollmentRepository,
  })  : _students = studentRepository,
        _courses = courseRepository,
        _enrollments = enrollmentRepository;

  final IStudentRepository _students;
  final ICourseRepository _courses;
  final IEnrollmentRepository _enrollments;

  @override
  List<Enrollment> get enrollments => _enrollments.getAll();

  @override
  List<Course> coursesForStudent(String studentId) {
    return _linkedEntities<Course>(
      matches: (Enrollment enrollment) => enrollment.studentId == studentId,
      resolve: (Enrollment enrollment) =>
          _courses.findById(enrollment.courseId),
    );
  }

  @override
  List<Student> studentsForCourse(String courseId) {
    return _linkedEntities<Student>(
      matches: (Enrollment enrollment) => enrollment.courseId == courseId,
      resolve: (Enrollment enrollment) =>
          _students.findById(enrollment.studentId),
    );
  }

  List<T> _linkedEntities<T>({
    required bool Function(Enrollment enrollment) matches,
    required T? Function(Enrollment enrollment) resolve,
  }) {
    final List<T> result = <T>[];
    for (final Enrollment enrollment in _enrollments.getAll()) {
      if (!matches(enrollment) ||
          enrollment.status != AppStatus.enrolled) {
        continue;
      }
      final T? item = resolve(enrollment);
      if (item != null) {
        result.add(item);
      }
    }
    return result;
  }

  @override
  int enrollmentCountForStudent(String studentId) =>
      coursesForStudent(studentId).length;

  @override
  String? canEnroll({
    required String studentId,
    required String courseId,
  }) {
    if (_students.findById(studentId) == null) {
      return 'Student not found.';
    }
    if (_courses.findById(courseId) == null) {
      return 'Course not found.';
    }

    final bool alreadyEnrolled = _enrollments.getAll().any(
          (Enrollment enrollment) =>
              enrollment.studentId == studentId &&
              enrollment.courseId == courseId &&
              enrollment.status == AppStatus.enrolled,
        );
    if (alreadyEnrolled) {
      return 'This student is already enrolled in that course.';
    }
    return null;
  }

  @override
  String? enroll({
    required String studentId,
    required String courseId,
  }) {
    final String? error = canEnroll(studentId: studentId, courseId: courseId);
    if (error != null) {
      return error;
    }

    _enrollments.add(
      Enrollment(
        id: _enrollments.nextId(),
        studentId: studentId,
        courseId: courseId,
        enrolledOn: _todayLabel(),
        status: AppStatus.enrolled,
      ),
    );
    return null;
  }

  @override
  void remove(String enrollmentId) {
    _enrollments.remove(enrollmentId);
  }

  @override
  String? removeByPair({
    required String studentId,
    required String courseId,
  }) {
    final bool removed = _enrollments.removeByStudentAndCourse(
      studentId: studentId,
      courseId: courseId,
    );
    if (!removed) {
      return 'Enrollment not found.';
    }
    return null;
  }

  static String _todayLabel() {
    final DateTime now = DateTime.now();
    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
