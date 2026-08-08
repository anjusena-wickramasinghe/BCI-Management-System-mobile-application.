import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/student.dart';
import '../app/app_container.dart';
import '../theme/bci_theme.dart';
import '../widgets/app_dialog.dart';
import '../widgets/form_fields.dart';

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
    final String search = _query.toLowerCase();
    return widget.app.studentService.students.where((Student student) {
      return student.id.toLowerCase().contains(search) ||
          student.name.toLowerCase().contains(search) ||
          student.program.toLowerCase().contains(search) ||
          student.email.toLowerCase().contains(search);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Student> students = _filteredStudents;

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
                    'Students',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add, view, edit and delete student records',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search students',
                      hintText: 'ID, name, email or programme',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (String value) => setState(() => _query = value),
                  ),
                ],
              ),
            ),
            Expanded(
              child: students.isEmpty
                  ? const Center(child: Text('No students found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) {
                        final Student student = students[index];
                        final int courseCount = widget.app.enrollmentService
                            .enrollmentCountForStudent(student.id);
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            onTap: () => _openStudentDetails(student),
                            leading: CircleAvatar(
                              backgroundColor: BciColors.sky,
                              foregroundColor: BciColors.navy,
                              child: Text(
                                student.name.isEmpty
                                    ? '?'
                                    : student.name[0].toUpperCase(),
                              ),
                            ),
                            title: Text(
                              student.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${student.id}\n${student.program}\n'
                              '$courseCount enrolled course${courseCount == 1 ? '' : 's'}',
                            ),
                            isThreeLine: true,
                            trailing: PopupMenuButton<String>(
                              onSelected: (String value) {
                                switch (value) {
                                  case 'view':
                                    _openStudentDetails(student);
                                  case 'edit':
                                    _showStudentForm(existing: student);
                                  case 'delete':
                                    _confirmDelete(student);
                                }
                              },
                              itemBuilder: (_) => const <PopupMenuEntry<String>>[
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
            onPressed: () => _showStudentForm(),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add Student'),
          ),
        ),
      ],
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
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete student'),
        content: Text(
          'Delete ${student.name}? Their course enrollments will also be removed.',
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
    widget.app.studentService.remove(student.id);
    widget.onChanged();
  }

  Future<void> _showStudentForm({Student? existing}) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final bool isEdit = existing != null;
    final TextEditingController idController =
        TextEditingController(text: existing?.id ?? '');
    final TextEditingController nameController =
        TextEditingController(text: existing?.name ?? '');
    final TextEditingController emailController =
        TextEditingController(text: existing?.email ?? '');
    final TextEditingController programmeController =
        TextEditingController(text: existing?.program ?? '');
    final TextEditingController intakeController =
        TextEditingController(text: existing?.intake ?? '');
    String status = existing?.status ?? 'Active';

    final Student? result = await showDialog<Student>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              scrollable: true,
              title: Text(isEdit ? 'Edit Student' : 'Add Student'),
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
                        label: 'Student ID',
                        enabled: !isEdit,
                      ),
                      AppTextField(
                        controller: nameController,
                        label: 'Full Name',
                      ),
                      AppTextField(
                        controller: emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        isEmail: true,
                      ),
                      AppTextField(
                        controller: programmeController,
                        label: 'Programme',
                      ),
                      AppTextField(
                        controller: intakeController,
                        label: 'Intake',
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
                    Student(
                      id: idController.text.trim(),
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      program: programmeController.text.trim(),
                      intake: intakeController.text.trim(),
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
      nameController.dispose();
      emailController.dispose();
      programmeController.dispose();
      intakeController.dispose();
    });

    if (!mounted || result == null) {
      return;
    }

    if (isEdit) {
      widget.app.studentService.update(result);
    } else {
      if (widget.app.studentService.findById(result.id) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A student with this ID already exists.')),
        );
        return;
      }
      widget.app.studentService.add(result);
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
    final Student? student = widget.app.studentService.findById(widget.studentId);
    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Student')),
        body: const Center(child: Text('Student not found.')),
      );
    }

    final List<Course> courses =
        widget.app.enrollmentService.coursesForStudent(student.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student details'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Edit',
            onPressed: () async {
              await _editStudent(student);
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
                    student.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 14),
                  DetailRow(label: 'Student ID', value: student.id),
                  DetailRow(label: 'Email', value: student.email),
                  DetailRow(label: 'Programme', value: student.program),
                  DetailRow(label: 'Intake', value: student.intake),
                  DetailRow(label: 'Status', value: student.status),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Assigned courses',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (courses.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('No courses assigned yet'),
                subtitle: Text('Enrol this student from the Enroll tab.'),
              ),
            )
          else
            ...courses.map(
              (Course course) => Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: BciColors.goldSoft,
                    foregroundColor: BciColors.gold,
                    child: Icon(Icons.menu_book_outlined),
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
            ),
        ],
      ),
    );
  }

  Future<void> _editStudent(Student existing) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController nameController =
        TextEditingController(text: existing.name);
    final TextEditingController emailController =
        TextEditingController(text: existing.email);
    final TextEditingController programmeController =
        TextEditingController(text: existing.program);
    final TextEditingController intakeController =
        TextEditingController(text: existing.intake);
    String status = existing.status;

    final Student? result = await showDialog<Student>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              scrollable: true,
              title: const Text('Edit Student'),
              content: AppDialog.content(
                context: context,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      AppTextField(
                        controller: nameController,
                        label: 'Full Name',
                      ),
                      AppTextField(
                        controller: emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        isEmail: true,
                      ),
                      AppTextField(
                        controller: programmeController,
                        label: 'Programme',
                      ),
                      AppTextField(
                        controller: intakeController,
                        label: 'Intake',
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
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      program: programmeController.text.trim(),
                      intake: intakeController.text.trim(),
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
      nameController.dispose();
      emailController.dispose();
      programmeController.dispose();
      intakeController.dispose();
    });

    if (result != null) {
      widget.app.studentService.update(result);
    }
  }
}
