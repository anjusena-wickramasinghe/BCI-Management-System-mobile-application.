import '../../models/course.dart';
import '../../models/enrollment.dart';
import '../../models/student.dart';

/// Application service for enrolment use-cases (SRP).
abstract class IEnrollmentService {
  List<Enrollment> get enrollments;

  List<Course> coursesForStudent(String studentId);

  List<Student> studentsForCourse(String courseId);

  int enrollmentCountForStudent(String studentId);

  String? canEnroll({
    required String studentId,
    required String courseId,
  });

  String? enroll({
    required String studentId,
    required String courseId,
  });

  void remove(String enrollmentId);

  String? removeByPair({
    required String studentId,
    required String courseId,
  });
}
