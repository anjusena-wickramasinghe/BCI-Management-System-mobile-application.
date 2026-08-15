import '../core/interfaces/course_repository.dart';
import '../models/course.dart';
import 'in_memory_store.dart';
import 'seed_data.dart';

/// LSP: fully substitutable for [ICourseRepository].
class InMemoryCourseRepository implements ICourseRepository {
  InMemoryCourseRepository({List<Course>? initial})
      : _store = InMemoryStore<Course>(initial ?? SeedData.courses());

  final InMemoryStore<Course> _store;

  @override
  List<Course> getAll() => _store.getAll();

  @override
  Course? findById(String id) => _store.findById(id);

  @override
  void add(Course course) => _store.add(course);

  @override
  bool update(Course course) => _store.update(course);

  @override
  bool remove(String id) => _store.remove(id);
}
