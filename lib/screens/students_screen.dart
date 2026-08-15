import 'package:flutter/material.dart';

import '../app/app_container.dart';
import '../core/text_utils.dart';
import '../models/course.dart';
import '../models/student.dart';
import '../theme/bci_theme.dart';
import '../widgets/app_dialog.dart';
import '../widgets/entity_widgets.dart';
import '../widgets/form_fields.dart';
import '../widgets/page_layout.dart';
import '../widgets/student_form.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({
    super.key,
    required this.app,
    required this.onChanged,
  });

  final AppContainer app;
  final VoidCallback onChanged;

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _query = '';

  List<Student> get _filteredStudents {
    return widget.app.studentService.students.where((Student student) {
      return TextUtils.matchesQuery(_query, <String>[
        student.id,
        student.name,
        student.program,
        student.email,
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Student> students = _filteredStudents;

    return CrudListPage(
      title: 'Students',
      subtitle: 'Add, view, edit and delete student records',
      searchLabel: 'Search students',
      searchHint: 'ID, name, email or programme',
      onSearchChanged: (String value) => setState(() => _query = value),
      itemCount: students.length,
      emptyMessage: 'No students found.',
      fabIcon: Icons.person_add_alt_1,
      fabLabel: 'Add Student',
      onFabPressed: () => _showStudentForm(),
      itemBuilder: (BuildContext context, int index) {
        final Student student = students[index];
        final int courseCount =
            widget.app.enrollmentService.enrollmentCountForStudent(student.id);
        return EntityListCard(
          leading: EntityAvatar(
            backgroundColor: BciColors.sky,
            foregroundColor: BciColors.navy,
            text: student.name,
          ),
          title: student.name,
          subtitle: '${student.id}\n${student.program}\n'
              '${TextUtils.counted(courseCount, 'enrolled course')}',
          onTap: () => _openStudentDetails(student),
          onView: () => _openStudentDetails(student),
          onEdit: () => _showStudentForm(existing: student),
          onDelete: () => _confirmDelete(student),
        );
      },
    );
  }

  Future<void> _openStudentDetails(Student student) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => _StudentDetailPage(
          app: widget.app,
          studentId: student.id,
          onChanged: widget.onChanged,
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmDelete(Student student) async {
    final bool confirmed = await AppDialog.confirm(
      context: context,
      title: 'Delete student',
      message:
          'Delete ${student.name}? Their course enrollments will also be removed.',
    );
    if (!mounted || !confirmed) {
      return;
    }
    widget.app.studentService.remove(student.id);
    widget.onChanged();
  }

  Future<void> _showStudentForm({Student? existing}) async {
    final Student? result = await StudentForm.show(
      context: context,
      existing: existing,
    );
    if (!mounted || result == null) {
      return;
    }

    final String? error = existing == null
        ? widget.app.studentService.add(result)
        : widget.app.studentService.update(result);
    if (error != null) {
      AppDialog.snack(context, error);
      return;
    }
    widget.onChanged();
  }
}

class _StudentDetailPage extends StatefulWidget {
  const _StudentDetailPage({
    required this.app,
    required this.studentId,
    required this.onChanged,
  });

  final AppContainer app;
  final String studentId;
  final VoidCallback onChanged;

  @override
  State<_StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<_StudentDetailPage> {
  @override
  Widget build(BuildContext context) {
    final Student? student =
        widget.app.studentService.findById(widget.studentId);
    if (student == null) {
      return const MissingEntityScaffold(
        title: 'Student',
        message: 'Student not found.',
      );
    }

    final List<Course> courses =
        widget.app.enrollmentService.coursesForStudent(student.id);

    return EntityDetailScaffold(
      appBarTitle: 'Student details',
      heading: student.name,
      details: <DetailRow>[
        DetailRow(label: 'Student ID', value: student.id),
        DetailRow(label: 'Email', value: student.email),
        DetailRow(label: 'Programme', value: student.program),
        DetailRow(label: 'Intake', value: student.intake),
        DetailRow(label: 'Status', value: student.status),
      ],
      relatedTitle: 'Assigned courses',
      relatedEmptyTitle: 'No courses assigned yet',
      relatedEmptySubtitle: 'Enrol this student from the Enroll tab.',
      relatedChildren: courses
          .map(
            (Course course) => Card(
              child: ListTile(
                leading: const EntityAvatar(
                  backgroundColor: BciColors.goldSoft,
                  foregroundColor: BciColors.gold,
                  icon: Icons.menu_book_outlined,
                ),
                title: Text(course.title),
                subtitle: Text(
                  '${course.id} · ${course.credits} credits\n${course.lecturer}',
                ),
                isThreeLine: true,
                trailing: IconButton(
                  tooltip: 'Unenrol',
                  onPressed: () {
                    widget.app.enrollmentService.removeByPair(
                      studentId: student.id,
                      courseId: course.id,
                    );
                    setState(() {});
                    widget.onChanged();
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
              ),
            ),
          )
          .toList(),
      onEdit: () async {
        final Student? result = await StudentForm.show(
          context: context,
          existing: student,
        );
        if (result != null) {
          widget.app.studentService.update(result);
        }
        if (mounted) {
          setState(() {});
          widget.onChanged();
        }
      },
    );
  }
}
