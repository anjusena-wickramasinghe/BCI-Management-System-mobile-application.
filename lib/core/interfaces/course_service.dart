import '../../models/course.dart';

/// Application service for course use-cases (SRP).
abstract class ICourseService {
  List<Course> get courses;

  int get activeCount;

  Course? findById(String id);

  String? add(Course course);

  String? update(Course course);

  void remove(String id);
}
