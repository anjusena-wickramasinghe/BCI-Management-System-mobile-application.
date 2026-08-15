import 'package:flutter/material.dart';

import '../app/app_container.dart';
import '../core/text_utils.dart';
import '../models/course.dart';
import '../models/student.dart';
import '../theme/bci_theme.dart';
import '../widgets/app_dialog.dart';
import '../widgets/course_form.dart';
import '../widgets/entity_widgets.dart';
import '../widgets/form_fields.dart';
import '../widgets/page_layout.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({
    super.key,
    required this.app,
    required this.onChanged,
  });

  final AppContainer app;
  final VoidCallback onChanged;

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _query = '';

  List<Course> get _filteredCourses {
    return widget.app.courseService.courses.where((Course course) {
      return TextUtils.matchesQuery(_query, <String>[
        course.id,
        course.title,
        course.program,
        course.lecturer,
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Course> courses = _filteredCourses;

    return CrudListPage(
      title: 'Courses',
      subtitle: 'Add, view, edit and delete course records',
      searchLabel: 'Search courses',
      searchHint: 'Code, title, programme or lecturer',
      onSearchChanged: (String value) => setState(() => _query = value),
      itemCount: courses.length,
      emptyMessage: 'No courses found.',
      fabIcon: Icons.menu_book_outlined,
      fabLabel: 'Add Course',
      onFabPressed: () => _showCourseForm(),
      itemBuilder: (BuildContext context, int index) {
        final Course course = courses[index];
        final int studentCount = widget.app.enrollmentService
            .studentsForCourse(course.id)
            .length;
        return EntityListCard(
          leading: EntityAvatar(
            backgroundColor: BciColors.goldSoft,
            foregroundColor: BciColors.gold,
            text: course.id,
          ),
          title: course.title,
          subtitle: '${course.id} · ${course.credits} credits\n'
              '${course.program}\n'
              '${TextUtils.counted(studentCount, 'enrolled student')}',
          onTap: () => _openCourseDetails(course),
          onView: () => _openCourseDetails(course),
          onEdit: () => _showCourseForm(existing: course),
          onDelete: () => _confirmDelete(course),
        );
      },
    );
  }

  Future<void> _openCourseDetails(Course course) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => _CourseDetailPage(
          app: widget.app,
          courseId: course.id,
          onChanged: widget.onChanged,
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmDelete(Course course) async {
    final bool confirmed = await AppDialog.confirm(
      context: context,
      title: 'Delete course',
      message:
          'Delete ${course.title}? Related enrollments will also be removed.',
    );
    if (!mounted || !confirmed) {
      return;
    }
    widget.app.courseService.remove(course.id);
    widget.onChanged();
  }

  Future<void> _showCourseForm({Course? existing}) async {
    final Course? result = await CourseForm.show(
      context: context,
      existing: existing,
    );
    if (!mounted || result == null) {
      return;
    }

    final String? error = existing == null
        ? widget.app.courseService.add(result)
        : widget.app.courseService.update(result);
    if (error != null) {
      AppDialog.snack(context, error);
      return;
    }
    widget.onChanged();
  }
}

class _CourseDetailPage extends StatefulWidget {
  const _CourseDetailPage({
    required this.app,
    required this.courseId,
    required this.onChanged,
  });

  final AppContainer app;
  final String courseId;
  final VoidCallback onChanged;

  @override
  State<_CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<_CourseDetailPage> {
  @override
  Widget build(BuildContext context) {
    final Course? course = widget.app.courseService.findById(widget.courseId);
    if (course == null) {
      return const MissingEntityScaffold(
        title: 'Course',
        message: 'Course not found.',
      );
    }

    final List<Student> students =
        widget.app.enrollmentService.studentsForCourse(course.id);

    return EntityDetailScaffold(
      appBarTitle: 'Course details',
      heading: course.title,
      details: <DetailRow>[
        DetailRow(label: 'Code', value: course.id),
        DetailRow(label: 'Programme', value: course.program),
        DetailRow(label: 'Credits', value: '${course.credits}'),
        DetailRow(label: 'Lecturer', value: course.lecturer),
        DetailRow(label: 'Status', value: course.status),
      ],
      relatedTitle: 'Enrolled students',
      relatedEmptyTitle: 'No students enrolled yet',
      relatedEmptySubtitle: 'Enrol students from the Enroll tab.',
      relatedChildren: students
          .map(
            (Student student) => Card(
              child: ListTile(
                leading: EntityAvatar(
                  backgroundColor: BciColors.sky,
                  foregroundColor: BciColors.navy,
                  text: student.name,
                ),
                title: Text(student.name),
                subtitle: Text('${student.id}\n${student.program}'),
                isThreeLine: true,
              ),
            ),
          )
          .toList(),
      onEdit: () async {
        final Course? result = await CourseForm.show(
          context: context,
          existing: course,
        );
        if (result != null) {
          widget.app.courseService.update(result);
        }
        if (mounted) {
          setState(() {});
          widget.onChanged();
        }
      },
    );
  }
}
