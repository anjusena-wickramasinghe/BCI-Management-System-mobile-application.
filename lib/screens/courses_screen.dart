import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/student.dart';
import '../app/app_container.dart';
import '../theme/bci_theme.dart';
import '../widgets/app_dialog.dart';
import '../widgets/form_fields.dart';

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
    final String search = _query.toLowerCase();
    return widget.app.courseService.courses.where((Course course) {
      return course.id.toLowerCase().contains(search) ||
          course.title.toLowerCase().contains(search) ||
          course.program.toLowerCase().contains(search) ||
          course.lecturer.toLowerCase().contains(search);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Course> courses = _filteredCourses;

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
                    'Courses',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add, view, edit and delete course records',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search courses',
                      hintText: 'Code, title, programme or lecturer',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String value) => setState(() => _query = value),
                  ),
                ],
              ),
            ),
            Expanded(
              child: courses.isEmpty
                  ? const Center(child: Text('No courses found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: courses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) {
                        final Course course = courses[index];
                        final int studentCount =
                            widget.app.enrollmentService.studentsForCourse(course.id).length;
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            onTap: () => _openCourseDetails(course),
                            leading: CircleAvatar(
                              backgroundColor: BciColors.goldSoft,
                              foregroundColor: BciColors.gold,
                              child: Text(
                                course.id.isEmpty
                                    ? '?'
                                    : course.id[0].toUpperCase(),
                              ),
                            ),
                            title: Text(
                              course.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${course.id} · ${course.credits} credits\n'
                              '${course.program}\n'
                              '$studentCount enrolled student${studentCount == 1 ? '' : 's'}',
                            ),
                            isThreeLine: true,
                            trailing: PopupMenuButton<String>(
                              onSelected: (String value) {
                                switch (value) {
                                  case 'view':
                                    _openCourseDetails(course);
                                  case 'edit':
                                    _showCourseForm(existing: course);
                                  case 'delete':
                                    _confirmDelete(course);
                                }
                              },
                              itemBuilder: (_) =>
                                  const <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'view',
                                  child: Text('View'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
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
            onPressed: () => _showCourseForm(),
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('Add Course'),
          ),
        ),
      ],
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
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete course'),
        content: Text(
          'Delete ${course.title}? Related enrollments will also be removed.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }
    widget.app.courseService.remove(course.id);
    widget.onChanged();
  }

  Future<void> _showCourseForm({Course? existing}) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final bool isEdit = existing != null;
    final TextEditingController idController =
        TextEditingController(text: existing?.id ?? '');
    final TextEditingController titleController =
        TextEditingController(text: existing?.title ?? '');
    final TextEditingController programmeController =
        TextEditingController(text: existing?.program ?? '');
    final TextEditingController creditsController = TextEditingController(
      text: existing == null ? '' : existing.credits.toString(),
    );
    final TextEditingController lecturerController =
        TextEditingController(text: existing?.lecturer ?? '');
    String status = existing?.status ?? 'Active';

    final Course? result = await showDialog<Course>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              scrollable: true,
              title: Text(isEdit ? 'Edit Course' : 'Add Course'),
              content: AppDialog.content(
                context: context,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppTextField(
                        controller: idController,
                        label: 'Course Code',
                        enabled: !isEdit,
                      ),
                      AppTextField(
                        controller: titleController,
                        label: 'Title',
                      ),
                      AppTextField(
                        controller: programmeController,
                        label: 'Programme',
                      ),
                      AppTextField(
                        controller: creditsController,
                        label: 'Credits',
                        keyboardType: TextInputType.number,
                        isNumber: true,
                      ),
                      AppTextField(
                        controller: lecturerController,
                        label: 'Lecturer',
                      ),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(
                            value: 'Active',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Inactive',
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            setDialogState(() => status = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: AppDialog.actions(
                context: context,
                onCancel: () => Navigator.pop(dialogContext),
                confirmLabel: isEdit ? 'Update' : 'Save',
                onConfirm: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  Navigator.pop(
                    dialogContext,
                    Course(
                      id: idController.text.trim(),
                      title: titleController.text.trim(),
                      program: programmeController.text.trim(),
                      credits: int.parse(creditsController.text.trim()),
                      lecturer: lecturerController.text.trim(),
                      status: status,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      idController.dispose();
      titleController.dispose();
      programmeController.dispose();
      creditsController.dispose();
      lecturerController.dispose();
    });

    if (!mounted || result == null) {
      return;
    }

    if (isEdit) {
      widget.app.courseService.update(result);
    } else {
      if (widget.app.courseService.findById(result.id) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A course with this code already exists.')),
        );
        return;
      }
      widget.app.courseService.add(result);
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
      return Scaffold(
        appBar: AppBar(title: const Text('Course')),
        body: const Center(child: Text('Course not found.')),
      );
    }

    final List<Student> students =
        widget.app.enrollmentService.studentsForCourse(course.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course details'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Edit',
            onPressed: () async {
              await _editCourse(course);
              if (mounted) {
                setState(() {});
                widget.onChanged();
              }
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 14),
                  DetailRow(label: 'Code', value: course.id),
                  DetailRow(label: 'Programme', value: course.program),
                  DetailRow(label: 'Credits', value: '${course.credits}'),
                  DetailRow(label: 'Lecturer', value: course.lecturer),
                  DetailRow(label: 'Status', value: course.status),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Enrolled students',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (students.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('No students enrolled yet'),
                subtitle: Text('Enrol students from the Enroll tab.'),
              ),
            )
          else
            ...students.map(
              (Student student) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: BciColors.sky,
                    foregroundColor: BciColors.navy,
                    child: Text(
                      student.name.isEmpty
                          ? '?'
                          : student.name[0].toUpperCase(),
                    ),
                  ),
                  title: Text(student.name),
                  subtitle: Text('${student.id}\n${student.program}'),
                  isThreeLine: true,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _editCourse(Course existing) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController titleController =
        TextEditingController(text: existing.title);
    final TextEditingController programmeController =
        TextEditingController(text: existing.program);
    final TextEditingController creditsController =
        TextEditingController(text: existing.credits.toString());
    final TextEditingController lecturerController =
        TextEditingController(text: existing.lecturer);
    String status = existing.status;

    final Course? result = await showDialog<Course>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              scrollable: true,
              title: const Text('Edit Course'),
              content: AppDialog.content(
                context: context,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppTextField(
                        controller: titleController,
                        label: 'Title',
                      ),
                      AppTextField(
                        controller: programmeController,
                        label: 'Programme',
                      ),
                      AppTextField(
                        controller: creditsController,
                        label: 'Credits',
                        keyboardType: TextInputType.number,
                        isNumber: true,
                      ),
                      AppTextField(
                        controller: lecturerController,
                        label: 'Lecturer',
                      ),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(
                            value: 'Active',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Inactive',
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            setDialogState(() => status = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: AppDialog.actions(
                context: context,
                onCancel: () => Navigator.pop(dialogContext),
                confirmLabel: 'Update',
                onConfirm: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  Navigator.pop(
                    dialogContext,
                    existing.copyWith(
                      title: titleController.text.trim(),
                      program: programmeController.text.trim(),
                      credits: int.parse(creditsController.text.trim()),
                      lecturer: lecturerController.text.trim(),
                      status: status,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      titleController.dispose();
      programmeController.dispose();
      creditsController.dispose();
      lecturerController.dispose();
    });

    if (result != null) {
      widget.app.courseService.update(result);
    }
  }
}
