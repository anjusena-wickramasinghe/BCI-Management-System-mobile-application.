import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/enrollment.dart';
import '../models/student.dart';
import '../state/bci_store.dart';
import '../theme/bci_theme.dart';
import '../widgets/app_dialog.dart';

class EnrollmentsScreen extends StatefulWidget {
  const EnrollmentsScreen({
    super.key,
    required this.store,
    required this.onChanged,
  });

  final BciStore store;
  final VoidCallback onChanged;

  @override
  State<EnrollmentsScreen> createState() => _EnrollmentsScreenState();
}

class _EnrollmentsScreenState extends State<EnrollmentsScreen> {
  String _query = '';

  List<Enrollment> get _filteredEnrollments {
    final String search = _query.toLowerCase();
    return widget.store.enrollments.where((Enrollment enrollment) {
      final Student? student = widget.store.findStudent(enrollment.studentId);
      final Course? course = widget.store.findCourse(enrollment.courseId);
      final String haystack = <String>[
        enrollment.id,
        enrollment.studentId,
        enrollment.courseId,
        student?.name ?? '',
        course?.title ?? '',
        course?.program ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(search);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Enrollment> enrollments = _filteredEnrollments;

    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Enrolment',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enrol students in courses and manage assignments',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search enrolments',
                      hintText: 'Student, course or ID',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String value) => setState(() => _query = value),
                  ),
                ],
              ),
            ),
            Expanded(
              child: enrollments.isEmpty
                  ? const Center(child: Text('No enrolments found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: enrollments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) {
                        final Enrollment enrollment = enrollments[index];
                        final Student? student =
                            widget.store.findStudent(enrollment.studentId);
                        final Course? course =
                            widget.store.findCourse(enrollment.courseId);

                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: BciColors.tealSoft,
                              foregroundColor: BciColors.teal,
                              child: Icon(Icons.how_to_reg_outlined),
                            ),
                            title: Text(
                              student?.name ?? enrollment.studentId,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${course?.id ?? enrollment.courseId} · '
                              '${course?.title ?? 'Unknown course'}\n'
                              'Enrolled ${enrollment.enrolledOn}',
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              tooltip: 'Unenrol',
                              onPressed: () => _confirmUnenroll(
                                enrollment,
                                student,
                                course,
                              ),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton.extended(
            onPressed: _showEnrollDialog,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Enrol Student'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmUnenroll(
    Enrollment enrollment,
    Student? student,
    Course? course,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Unenrol student'),
        content: Text(
          'Remove ${student?.name ?? enrollment.studentId} from '
          '${course?.title ?? enrollment.courseId}?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unenrol'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }
    widget.store.removeEnrollment(enrollment.id);
    widget.onChanged();
  }

  Future<void> _showEnrollDialog() async {
    if (widget.store.students.isEmpty || widget.store.courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one student and one course first.'),
        ),
      );
      return;
    }

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String? selectedStudentId = widget.store.students.first.id;
    String? selectedCourseId = widget.store.courses.first.id;
    String? errorText;

    final bool? enrolled = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              scrollable: true,
              title: const Text('Enrol Student'),
              content: AppDialog.content(
                context: context,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: selectedStudentId,
                        decoration: const InputDecoration(
                          labelText: 'Student',
                          border: OutlineInputBorder(),
                        ),
                        items: widget.store.students
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
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: selectedCourseId,
                        decoration: const InputDecoration(
                          labelText: 'Course',
                          border: OutlineInputBorder(),
                        ),
                        items: widget.store.courses
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
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: AppDialog.actions(
                context: context,
                onCancel: () => Navigator.pop(dialogContext, false),
                confirmLabel: 'Enrol',
                onConfirm: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  final String? message = widget.store.canEnroll(
                    studentId: selectedStudentId!,
                    courseId: selectedCourseId!,
                  );

                  if (message != null) {
                    setDialogState(() => errorText = message);
                    return;
                  }

                  Navigator.pop(dialogContext, true);
                },
              ),
            );
          },
        );
      },
    );

    if (!mounted || enrolled != true) {
      return;
    }

    widget.store.enrollStudent(
      studentId: selectedStudentId!,
      courseId: selectedCourseId!,
    );
    widget.onChanged();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student enrolled successfully.')),
    );
  }
}
