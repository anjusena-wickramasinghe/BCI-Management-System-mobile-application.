import '../../models/student.dart';

/// Application service for student use-cases (SRP).
abstract class IStudentService {
  List<Student> get students;

  int get activeCount;

  Student? findById(String id);

  String? add(Student student);

  String? update(Student student);

  void remove(String id);
}
