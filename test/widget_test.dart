import 'package:flutter_test/flutter_test.dart';

import 'package:bci_management_system/app/app_container.dart';
import 'package:bci_management_system/main.dart';
import 'package:bci_management_system/models/course.dart';
import 'package:bci_management_system/models/student.dart';

void main() {
  testWidgets('App loads home dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(BciManagementApp(app: AppContainer()));
    await tester.pumpAndSettle();

    expect(find.text('BCI Management'), findsWidgets);
    expect(find.text('Students'), findsWidgets);
  });

  group('SOLID services academic rules', () {
    late AppContainer app;

    setUp(() {
      app = AppContainer();
    });

    test('lists courses assigned to a student', () {
      final courses =
          app.enrollmentService.coursesForStudent('BCI-2026-001');
      expect(courses, isNotEmpty);
      expect(courses.first.id, 'SE301');
    });

    test('adds and updates a student via StudentService', () {
      final String? addError = app.studentService.add(
        const Student(
          id: 'BCI-2026-999',
          name: 'Test Student',
          email: 'test@students.bci.lk',
          program: 'BSc IT',
          intake: 'February 2026',
          status: 'Active',
        ),
      );
      expect(addError, isNull);
      expect(app.studentService.findById('BCI-2026-999')?.name, 'Test Student');

      final String? updateError = app.studentService.update(
        const Student(
          id: 'BCI-2026-999',
          name: 'Updated Student',
          email: 'test@students.bci.lk',
          program: 'BSc IT',
          intake: 'February 2026',
          status: 'Inactive',
        ),
      );
      expect(updateError, isNull);
      expect(
        app.studentService.findById('BCI-2026-999')?.name,
        'Updated Student',
      );
      expect(app.studentService.findById('BCI-2026-999')?.status, 'Inactive');
    });

    test('adds and updates a course via CourseService', () {
      final String? addError = app.courseService.add(
        const Course(
          id: 'NET101',
          title: 'Networks',
          program: 'BSc IT',
          credits: 15,
          lecturer: 'Staff',
          status: 'Active',
        ),
      );
      expect(addError, isNull);
      expect(app.courseService.findById('NET101')?.title, 'Networks');

      final String? updateError = app.courseService.update(
        const Course(
          id: 'NET101',
          title: 'Computer Networks',
          program: 'BSc IT',
          credits: 20,
          lecturer: 'Staff',
          status: 'Active',
        ),
      );
      expect(updateError, isNull);
      expect(app.courseService.findById('NET101')?.title, 'Computer Networks');
      expect(app.courseService.findById('NET101')?.credits, 20);
    });

    test('enrols a student and blocks duplicates via EnrollmentService', () {
      final String? first = app.enrollmentService.enroll(
        studentId: 'BCI-2026-001',
        courseId: 'IT210',
      );
      expect(first, isNull);
      expect(
        app.enrollmentService
            .coursesForStudent('BCI-2026-001')
            .any((c) => c.id == 'IT210'),
        isTrue,
      );

      final String? duplicate = app.enrollmentService.enroll(
        studentId: 'BCI-2026-001',
        courseId: 'IT210',
      );
      expect(duplicate, isNotNull);
    });

    test('deleting a student removes their enrolments', () {
      app.studentService.remove('BCI-2026-001');
      expect(app.studentService.findById('BCI-2026-001'), isNull);
      expect(
        app.enrollmentService.enrollments
            .any((e) => e.studentId == 'BCI-2026-001'),
        isFalse,
      );
    });

    test('services depend on abstractions (substitutable repositories)', () {
      // DIP / LSP: AppContainer accepts custom repositories; default wiring works.
      expect(app.studentService, isNotNull);
      expect(app.courseService, isNotNull);
      expect(app.enrollmentService, isNotNull);
      expect(app.studentService.students, isNotEmpty);
      expect(app.courseService.courses, isNotEmpty);
    });
  });
}
