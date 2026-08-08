import '../core/interfaces/course_repository.dart';
import '../core/interfaces/course_service.dart';
import '../core/interfaces/enrollment_repository.dart';
import '../core/interfaces/enrollment_service.dart';
import '../core/interfaces/student_repository.dart';
import '../core/interfaces/student_service.dart';
import '../data/in_memory_course_repository.dart';
import '../data/in_memory_enrollment_repository.dart';
import '../data/in_memory_student_repository.dart';
import '../services/course_service.dart';
import '../services/enrollment_service.dart';
import '../services/student_service.dart';

/// Composition root / simple DI container (DIP).
/// Wires concrete repositories into services; UI depends on service interfaces.
class AppContainer {
  AppContainer({
    IStudentRepository? studentRepository,
    ICourseRepository? courseRepository,
    IEnrollmentRepository? enrollmentRepository,
  }) {
    final IStudentRepository students =
        studentRepository ?? InMemoryStudentRepository();
    final ICourseRepository courses =
        courseRepository ?? InMemoryCourseRepository();
    final IEnrollmentRepository enrollments =
        enrollmentRepository ?? InMemoryEnrollmentRepository();

    studentService = StudentService(
      studentRepository: students,
      enrollmentRepository: enrollments,
    );
    courseService = CourseService(
      courseRepository: courses,
      enrollmentRepository: enrollments,
    );
    enrollmentService = EnrollmentService(
      studentRepository: students,
      courseRepository: courses,
      enrollmentRepository: enrollments,
    );
  }

  late final IStudentService studentService;
  late final ICourseService courseService;
  late final IEnrollmentService enrollmentService;
}
