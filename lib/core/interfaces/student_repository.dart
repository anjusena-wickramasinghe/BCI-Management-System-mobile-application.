import '../../models/student.dart';

/// ISP + DIP: student persistence contract only.
/// UI and services depend on this abstraction, not a concrete store.
abstract class IStudentRepository {
  List<Student> getAll();

  Student? findById(String id);

  void add(Student student);

  bool update(Student student);

  bool remove(String id);
}
