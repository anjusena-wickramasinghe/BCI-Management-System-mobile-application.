import 'package:flutter_test/flutter_test.dart';

import 'package:bci_management_system/main.dart';
import 'package:bci_management_system/models/course.dart';
import 'package:bci_management_system/models/student.dart';
import 'package:bci_management_system/state/bci_store.dart';

void main() {
  testWidgets('App loads home dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(BciManagementApp(store: BciStore()));
    await tester.pumpAndSettle();

    expect(find.text('BCI Management'), findsWidgets);
    expect(find.text('Students'), findsWidgets);
  });

  group('BciStore academic rules', () {
    late BciStore store;

    setUp(() {
      store = BciStore();
    });

    test('lists courses assigned to a student', () {
      final courses = store.coursesForStudent('BCI-2026-001');
      expect(courses, isNotEmpty);
      expect(courses.first.id, 'SE301');
    });

    test('adds and updates a student', () {
      store.addStudent(
        const Student(
          id: 'BCI-2026-999',
          name: 'Test Student',
          email: 'test@students.bci.lk',
          program: 'BSc IT',
          intake: 'February 2026',
          status: 'Active',
        ),
      );
      expect(store.findStudent('BCI-2026-999')?.name, 'Test Student');

      final String? updateError = store.updateStudent(
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
      expect(store.findStudent('BCI-2026-999')?.name, 'Updated Student');
      expect(store.findStudent('BCI-2026-999')?.status, 'Inactive');
    });

    test('adds and updates a course', () {
      store.addCourse(
        const Course(
          id: 'NET101',
          title: 'Networks',
          program: 'BSc IT',
          credits: 15,
          lecturer: 'Staff',
          status: 'Active',
        ),
      );
      expect(store.findCourse('NET101')?.title, 'Networks');

      final String? updateError = store.updateCourse(
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
      expect(store.findCourse('NET101')?.title, 'Computer Networks');
      expect(store.findCourse('NET101')?.credits, 20);
    });

    test('enrols a student and blocks duplicates', () {
      final String? first = store.enrollStudent(
        studentId: 'BCI-2026-001',
        courseId: 'IT210',
      );
      expect(first, isNull);
      expect(
        store.coursesForStudent('BCI-2026-001').any((c) => c.id == 'IT210'),
        isTrue,
      );

      final String? duplicate = store.enrollStudent(
        studentId: 'BCI-2026-001',
        courseId: 'IT210',
      );
      expect(duplicate, isNotNull);
    });

    test('deleting a student removes their enrolments', () {
      store.removeStudent('BCI-2026-001');
      expect(store.findStudent('BCI-2026-001'), isNull);
      expect(
        store.enrollments.any((e) => e.studentId == 'BCI-2026-001'),
        isFalse,
      );
    });
  });
}
