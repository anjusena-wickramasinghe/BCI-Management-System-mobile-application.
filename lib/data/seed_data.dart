import '../core/app_constants.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../models/student.dart';

/// Demo seed data kept separate from repository logic (SRP).
class SeedData {
  SeedData._();

  static List<Student> students() => <Student>[
        const Student(
          id: 'BCI-2026-001',
          name: 'Ayesha Perera',
          email: 'ayesha@students.bci.lk',
          program: 'BSc Software Engineering',
          intake: 'February 2026',
          status: AppStatus.active,
        ),
        const Student(
          id: 'BCI-2026-002',
          name: 'Nimal Fernando',
          email: 'nimal@students.bci.lk',
          program: 'BSc Information Technology',
          intake: 'February 2026',
          status: AppStatus.active,
        ),
        const Student(
          id: 'BCI-2025-118',
          name: 'Tharushi Silva',
          email: 'tharushi@students.bci.lk',
          program: 'BSc Computer Science',
          intake: 'September 2025',
          status: AppStatus.active,
        ),
      ];

  static List<Course> courses() => <Course>[
        const Course(
          id: 'SE301',
          title: 'Software Engineering Principles',
          program: 'BSc Software Engineering',
          credits: 15,
          lecturer: 'Dr. Amal Jayasinghe',
          status: AppStatus.active,
        ),
        const Course(
          id: 'IT210',
          title: 'Database Systems',
          program: 'BSc Information Technology',
          credits: 15,
          lecturer: 'Dr. Amal Jayasinghe',
          status: AppStatus.active,
        ),
        const Course(
          id: 'CS120',
          title: 'Introduction to Programming',
          program: 'BSc Computer Science',
          credits: 20,
          lecturer: 'Rashmi Perera',
          status: AppStatus.active,
        ),
      ];

  static List<Enrollment> enrollments() => <Enrollment>[
        const Enrollment(
          id: 'ENR-001',
          studentId: 'BCI-2026-001',
          courseId: 'SE301',
          enrolledOn: '26 July 2026',
          status: AppStatus.enrolled,
        ),
        const Enrollment(
          id: 'ENR-002',
          studentId: 'BCI-2026-002',
          courseId: 'IT210',
          enrolledOn: '26 July 2026',
          status: AppStatus.enrolled,
        ),
        const Enrollment(
          id: 'ENR-003',
          studentId: 'BCI-2025-118',
          courseId: 'CS120',
          enrolledOn: '26 July 2026',
          status: AppStatus.enrolled,
        ),
      ];
}
