import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../models/student.dart';
import 'app_dialog.dart';
import 'form_fields.dart';

class StudentForm {
  StudentForm._();

  static Future<Student?> show({
    required BuildContext context,
    Student? existing,
  }) async {
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
    String status = existing?.status ?? AppStatus.active;

    final Student? result = await AppDialog.form<Student>(
      context: context,
      title: isEdit ? 'Edit Student' : 'Add Student',
      confirmLabel: isEdit ? 'Update' : 'Save',
      fields: (BuildContext _, StateSetter setDialogState) {
        return Column(
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
            StatusDropdown(
              value: status,
              onChanged: (String value) {
                setDialogState(() => status = value);
              },
            ),
          ],
        );
      },
      onConfirm: (GlobalKey<FormState> formKey, _) {
        if (!formKey.currentState!.validate()) {
          return null;
        }
        return Student(
          id: idController.text.trim(),
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          program: programmeController.text.trim(),
          intake: intakeController.text.trim(),
          status: status,
        );
      },
    );

    AppDialog.disposeControllers(<TextEditingController>[
      idController,
      nameController,
      emailController,
      programmeController,
      intakeController,
    ]);

    return result;
  }
}
