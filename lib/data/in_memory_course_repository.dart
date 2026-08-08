import '../core/interfaces/course_repository.dart';
import '../models/course.dart';
import 'seed_data.dart';

/// LSP: fully substitutable for [ICourseRepository].
class InMemoryCourseRepository implements ICourseRepository {
  InMemoryCourseRepository({List<Course>? initial})
      : _courses = List<Course>.from(initial ?? SeedData.courses());

  final List<Course> _courses;

  @override
  List<Course> getAll() => List<Course>.unmodifiable(_courses);

  @override
  Course? findById(String id) {
    for (final Course course in _courses) {
      if (course.id == id) {
        return course;
      }
    }
    return null;
  }

  @override
  void add(Course course) => _courses.add(course);

  @override
  bool update(Course course) {
    final int index =
        _courses.indexWhere((Course item) => item.id == course.id);
    if (index < 0) {
      return false;
    }
    _courses[index] = course;
    return true;
  }

  @override
  bool remove(String id) {
    final int before = _courses.length;
    _courses.removeWhere((Course course) => course.id == id);
    return _courses.length < before;
  }
}
