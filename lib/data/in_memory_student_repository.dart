import '../core/interfaces/student_repository.dart';
import '../models/student.dart';
import 'in_memory_store.dart';
import 'seed_data.dart';

/// LSP: fully substitutable for [IStudentRepository].
/// OCP: can be replaced by an API/database repository without changing services.
class InMemoryStudentRepository implements IStudentRepository {
  InMemoryStudentRepository({List<Student>? initial})
      : _store = InMemoryStore<Student>(initial ?? SeedData.students());

  final InMemoryStore<Student> _store;

  @override
  List<Student> getAll() => _store.getAll();

  @override
  Student? findById(String id) => _store.findById(id);

  @override
  void add(Student student) => _store.add(student);

  @override
  bool update(Student student) => _store.update(student);

  @override
  bool remove(String id) => _store.remove(id);
}
