import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../models/course.dart';
import 'app_dialog.dart';
import 'form_fields.dart';

class CourseForm {
  CourseForm._();

  static Future<Course?> show({
    required BuildContext context,
    Course? existing,
  }) async {
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
    String status = existing?.status ?? AppStatus.active;

    final Course? result = await AppDialog.form<Course>(
      context: context,
      title: isEdit ? 'Edit Course' : 'Add Course',
      confirmLabel: isEdit ? 'Update' : 'Save',
      fields: (BuildContext _, StateSetter setDialogState) {
        return Column(
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
        return Course(
          id: idController.text.trim(),
          title: titleController.text.trim(),
          program: programmeController.text.trim(),
          credits: int.parse(creditsController.text.trim()),
          lecturer: lecturerController.text.trim(),
          status: status,
        );
      },
    );

    AppDialog.disposeControllers(<TextEditingController>[
      idController,
      titleController,
      programmeController,
      creditsController,
      lecturerController,
    ]);

    return result;
  }
}
