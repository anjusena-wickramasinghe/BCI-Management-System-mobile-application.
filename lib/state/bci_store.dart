import '../models/course.dart';
import '../models/enrollment.dart';
import '../models/student.dart';

class BciStore {
  final List<Student> _students = <Student>[
    const Student(
      id: 'BCI-2026-001',
      name: 'Ayesha Perera',
      email: 'ayesha@students.bci.lk',
      program: 'BSc Software Engineering',
      intake: 'February 2026',
      status: 'Active',
    ),
    const Student(
      id: 'BCI-2026-002',
      name: 'Nimal Fernando',
      email: 'nimal@students.bci.lk',
      program: 'BSc Information Technology',
      intake: 'February 2026',
      status: 'Active',
    ),
    const Student(
      id: 'BCI-2025-118',
      name: 'Tharushi Silva',
      email: 'tharushi@students.bci.lk',
      program: 'BSc Computer Science',
      intake: 'September 2025',
      status: 'Active',
    ),
  ];

  final List<Course> _courses = <Course>[
    const Course(
      id: 'SE301',
      title: 'Software Engineering Principles',
      program: 'BSc Software Engineering',
      credits: 15,
      lecturer: 'Dr. Amal Jayasinghe',
      status: 'Active',
    ),
    const Course(
      id: 'IT210',
      title: 'Database Systems',
      program: 'BSc Information Technology',
      credits: 15,
      lecturer: 'Dr. Amal Jayasinghe',
      status: 'Active',
    ),
    const Course(
      id: 'CS120',
      title: 'Introduction to Programming',
      program: 'BSc Computer Science',
      credits: 20,
      lecturer: 'Rashmi Perera',
      status: 'Active',
    ),
  ];

  final List<Enrollment> _enrollments = <Enrollment>[
    const Enrollment(
      id: 'ENR-001',
      studentId: 'BCI-2026-001',
      courseId: 'SE301',
      enrolledOn: '26 July 2026',
      status: 'Enrolled',
    ),
    const Enrollment(
      id: 'ENR-002',
      studentId: 'BCI-2026-002',
      courseId: 'IT210',
      enrolledOn: '26 July 2026',
      status: 'Enrolled',
    ),
    const Enrollment(
      id: 'ENR-003',
      studentId: 'BCI-2025-118',
      courseId: 'CS120',
      enrolledOn: '26 July 2026',
      status: 'Enrolled',
    ),
  ];

  int _enrollmentCounter = 3;

  List<Student> get students => List<Student>.unmodifiable(_students);
  List<Course> get courses => List<Course>.unmodifiable(_courses);
  List<Enrollment> get enrollments =>
      List<Enrollment>.unmodifiable(_enrollments);

  int get activeStudentCount =>
      _students.where((Student student) => student.status == 'Active').length;

  int get activeCourseCount =>
      _courses.where((Course course) => course.status == 'Active').length;

  Student? findStudent(String studentId) {
    for (final Student student in _students) {
      if (student.id == studentId) {
        return student;
      }
    }
    return null;
  }

  Course? findCourse(String courseId) {
    for (final Course course in _courses) {
      if (course.id == courseId) {
        return course;
      }
    }
    return null;
  }

  List<Course> coursesForStudent(String studentId) {
    final List<Course> result = <Course>[];
    for (final Enrollment enrollment in _enrollments) {
      if (enrollment.studentId != studentId ||
          enrollment.status != 'Enrolled') {
        continue;
      }
      final Course? course = findCourse(enrollment.courseId);
      if (course != null) {
        result.add(course);
      }
    }
    return result;
  }

  List<Student> studentsForCourse(String courseId) {
    final List<Student> result = <Student>[];
    for (final Enrollment enrollment in _enrollments) {
      if (enrollment.courseId != courseId ||
          enrollment.status != 'Enrolled') {
        continue;
      }
      final Student? student = findStudent(enrollment.studentId);
      if (student != null) {
        result.add(student);
      }
    }
    return result;
  }

  int enrollmentCountForStudent(String studentId) =>
      coursesForStudent(studentId).length;

  void addStudent(Student student) => _students.add(student);

  String? updateStudent(Student student) {
    final int index =
        _students.indexWhere((Student item) => item.id == student.id);
    if (index < 0) {
      return 'Student not found.';
    }
    _students[index] = student;
    return null;
  }

  void removeStudent(String studentId) {
    _students.removeWhere((Student student) => student.id == studentId);
    _enrollments.removeWhere(
      (Enrollment enrollment) => enrollment.studentId == studentId,
    );
  }

  void addCourse(Course course) => _courses.add(course);

  String? updateCourse(Course course) {
    final int index =
        _courses.indexWhere((Course item) => item.id == course.id);
    if (index < 0) {
      return 'Course not found.';
    }
    _courses[index] = course;
    return null;
  }

  void removeCourse(String courseId) {
    _courses.removeWhere((Course course) => course.id == courseId);
    _enrollments.removeWhere(
      (Enrollment enrollment) => enrollment.courseId == courseId,
    );
  }

  String? canEnroll({
    required String studentId,
    required String courseId,
  }) {
    if (findStudent(studentId) == null) {
      return 'Student not found.';
    }
    if (findCourse(courseId) == null) {
      return 'Course not found.';
    }

    final bool alreadyEnrolled = _enrollments.any(
      (Enrollment enrollment) =>
          enrollment.studentId == studentId &&
          enrollment.courseId == courseId &&
          enrollment.status == 'Enrolled',
    );
    if (alreadyEnrolled) {
      return 'This student is already enrolled in that course.';
    }
    return null;
  }

  String? enrollStudent({
    required String studentId,
    required String courseId,
  }) {
    final String? error = canEnroll(studentId: studentId, courseId: courseId);
    if (error != null) {
      return error;
    }

    _enrollmentCounter += 1;
    _enrollments.add(
      Enrollment(
        id: 'ENR-${_enrollmentCounter.toString().padLeft(3, '0')}',
        studentId: studentId,
        courseId: courseId,
        enrolledOn: _todayLabel(),
        status: 'Enrolled',
      ),
    );
    return null;
  }

  void removeEnrollment(String enrollmentId) {
    _enrollments.removeWhere(
      (Enrollment enrollment) => enrollment.id == enrollmentId,
    );
  }

  String? removeEnrollmentByPair({
    required String studentId,
    required String courseId,
  }) {
    final int index = _enrollments.indexWhere(
      (Enrollment enrollment) =>
          enrollment.studentId == studentId &&
          enrollment.courseId == courseId,
    );
    if (index < 0) {
      return 'Enrollment not found.';
    }
    _enrollments.removeAt(index);
    return null;
  }

  static String _todayLabel() {
    final DateTime now = DateTime.now();
    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
