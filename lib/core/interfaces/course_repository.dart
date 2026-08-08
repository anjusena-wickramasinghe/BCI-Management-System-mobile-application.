import '../../models/course.dart';

/// ISP + DIP: course persistence contract only.
abstract class ICourseRepository {
  List<Course> getAll();

  Course? findById(String id);

  void add(Course course);

  bool update(Course course);

  bool remove(String id);
}
