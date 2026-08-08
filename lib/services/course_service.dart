import '../core/interfaces/course_repository.dart';
import '../core/interfaces/course_service.dart';
import '../core/interfaces/enrollment_repository.dart';
import '../models/course.dart';

/// SRP: course business rules only.
/// DIP: depends on repository abstractions.
class CourseService implements ICourseService {
  CourseService({
    required ICourseRepository courseRepository,
    required IEnrollmentRepository enrollmentRepository,
  })  : _courses = courseRepository,
        _enrollments = enrollmentRepository;

  final ICourseRepository _courses;
  final IEnrollmentRepository _enrollments;

  @override
  List<Course> get courses => _courses.getAll();

  @override
  int get activeCount =>
      _courses.getAll().where((Course c) => c.status == 'Active').length;

  @override
  Course? findById(String id) => _courses.findById(id);

  @override
  String? add(Course course) {
    if (_courses.findById(course.id) != null) {
      return 'A course with this code already exists.';
    }
    _courses.add(course);
    return null;
  }

  @override
  String? update(Course course) {
    if (!_courses.update(course)) {
      return 'Course not found.';
    }
    return null;
  }

  @override
  void remove(String id) {
    _courses.remove(id);
    _enrollments.removeByCourseId(id);
  }
}
