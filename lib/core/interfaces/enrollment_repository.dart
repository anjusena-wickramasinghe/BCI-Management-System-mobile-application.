import '../../models/enrollment.dart';

/// ISP + DIP: enrolment persistence contract only.
abstract class IEnrollmentRepository {
  List<Enrollment> getAll();

  Enrollment? findById(String id);

  void add(Enrollment enrollment);

  bool remove(String id);

  bool removeByStudentAndCourse({
    required String studentId,
    required String courseId,
  });

  void removeByStudentId(String studentId);

  void removeByCourseId(String courseId);

  String nextId();
}
