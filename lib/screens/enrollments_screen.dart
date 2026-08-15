import 'package:flutter/material.dart';

import '../app/app_container.dart';
import '../core/text_utils.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../models/student.dart';
import '../theme/bci_theme.dart';
import '../widgets/app_dialog.dart';
import '../widgets/entity_widgets.dart';
import '../widgets/form_fields.dart';
import '../widgets/page_layout.dart';

class EnrollmentsScreen extends StatefulWidget {
  const EnrollmentsScreen({
    super.key,
    required this.app,
    required this.onChanged,
  });

  final AppContainer app;
  final VoidCallback onChanged;

  @override
  State<EnrollmentsScreen> createState() => _EnrollmentsScreenState();
}

class _EnrollmentsScreenState extends State<EnrollmentsScreen> {
  String _query = '';

  List<Enrollment> get _filteredEnrollments {
    return widget.app.enrollmentService.enrollments
        .where((Enrollment enrollment) {
      final Student? student =
          widget.app.studentService.findById(enrollment.studentId);
      final Course? course =
          widget.app.courseService.findById(enrollment.courseId);
      return TextUtils.matchesQuery(_query, <String>[
        <String>[
          enrollment.id,
          enrollment.studentId,
          enrollment.courseId,
          student?.name ?? '',
          course?.title ?? '',
          course?.program ?? '',
        ].join(' '),
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Enrollment> enrollments = _filteredEnrollments;

    return CrudListPage(
      title: 'Enrolment',
      subtitle: 'Enrol students in courses and manage assignments',
      searchLabel: 'Search enrolments',
      searchHint: 'Student, course or ID',
      onSearchChanged: (String value) => setState(() => _query = value),
      itemCount: enrollments.length,
      emptyMessage: 'No enrolments found.',
      fabIcon: Icons.person_add_alt_1,
      fabLabel: 'Enrol Student',
      onFabPressed: _showEnrollDialog,
      itemBuilder: (BuildContext context, int index) {
        final Enrollment enrollment = enrollments[index];
        final Student? student =
            widget.app.studentService.findById(enrollment.studentId);
        final Course? course =
            widget.app.courseService.findById(enrollment.courseId);

        return Card(
          child: ListTile(
            leading: const EntityAvatar(
              backgroundColor: BciColors.tealSoft,
              foregroundColor: BciColors.teal,
              icon: Icons.how_to_reg_outlined,
            ),
            title: Text(
              student?.name ?? enrollment.studentId,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${course?.id ?? enrollment.courseId} · '
              '${course?.title ?? 'Unknown course'}\n'
              'Enrolled ${enrollment.enrolledOn}',
            ),
            isThreeLine: true,
            trailing: IconButton(
              tooltip: 'Unenrol',
              onPressed: () => _confirmUnenroll(enrollment, student, course),
              icon: const Icon(Icons.remove_circle_outline),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmUnenroll(
    Enrollment enrollment,
    Student? student,
    Course? course,
  ) async {
    final bool confirmed = await AppDialog.confirm(
      context: context,
      title: 'Unenrol student',
      message: 'Remove ${student?.name ?? enrollment.studentId} from '
          '${course?.title ?? enrollment.courseId}?',
      confirmLabel: 'Unenrol',
    );
    if (!mounted || !confirmed) {
      return;
    }
    widget.app.enrollmentService.remove(enrollment.id);
    widget.onChanged();
  }

  Future<void> _showEnrollDialog() async {
    if (widget.app.studentService.students.isEmpty ||
        widget.app.courseService.courses.isEmpty) {
      AppDialog.snack(
        context,
        'Add at least one student and one course first.',
      );
      return;
    }

    String? selectedStudentId = widget.app.studentService.students.first.id;
    String? selectedCourseId = widget.app.courseService.courses.first.id;
    String? errorText;

    final bool? enrolled = await AppDialog.form<bool>(
      context: context,
      title: 'Enrol Student',
      confirmLabel: 'Enrol',
      fields: (BuildContext context, StateSetter setDialogState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDropdownField<String>(
              value: selectedStudentId,
              label: 'Student',
              items: widget.app.studentService.students
                  .map(
                    (Student student) => DropdownMenuItem<String>(
                      value: student.id,
                      child: AppDialog.dropdownLabel(
                        '${student.name} (${student.id})',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (String? value) {
                setDialogState(() {
                  selectedStudentId = value;
                  errorText = null;
                });
              },
              validator: (String? value) =>
                  value == null ? 'Select a student.' : null,
            ),
            const SizedBox(height: 12),
            AppDropdownField<String>(
              value: selectedCourseId,
              label: 'Course',
              items: widget.app.courseService.courses
                  .map(
                    (Course course) => DropdownMenuItem<String>(
                      value: course.id,
                      child: AppDialog.dropdownLabel(
                        '${course.id} · ${course.title}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (String? value) {
                setDialogState(() {
                  selectedCourseId = value;
                  errorText = null;
                });
              },
              validator: (String? value) =>
                  value == null ? 'Select a course.' : null,
            ),
            if (errorText != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                errorText!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ],
        );
      },
      onConfirm: (GlobalKey<FormState> formKey, StateSetter setDialogState) {
        if (!formKey.currentState!.validate()) {
          return null;
        }

        final String? message = widget.app.enrollmentService.canEnroll(
          studentId: selectedStudentId!,
          courseId: selectedCourseId!,
        );
        if (message != null) {
          setDialogState(() => errorText = message);
          return null;
        }
        return true;
      },
    );

    if (!mounted || enrolled != true) {
      return;
    }

    widget.app.enrollmentService.enroll(
      studentId: selectedStudentId!,
      courseId: selectedCourseId!,
    );
    widget.onChanged();

    AppDialog.snack(context, 'Student enrolled successfully.');
  }
}
