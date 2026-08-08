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
    final List<Course> result = <Course>[];
    for (final Enrollment enrollment in _enrollments.getAll()) {
      if (enrollment.studentId != studentId ||
          enrollment.status != 'Enrolled') {
        continue;
      }
      final Course? course = _courses.findById(enrollment.courseId);
      if (course != null) {
        result.add(course);
      }
    }
    return result;
  }

  @override
  List<Student> studentsForCourse(String courseId) {
    final List<Student> result = <Student>[];
    for (final Enrollment enrollment in _enrollments.getAll()) {
      if (enrollment.courseId != courseId ||
          enrollment.status != 'Enrolled') {
        continue;
      }
      final Student? student = _students.findById(enrollment.studentId);
      if (student != null) {
        result.add(student);
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
              enrollment.status == 'Enrolled',
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
        status: 'Enrolled',
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
