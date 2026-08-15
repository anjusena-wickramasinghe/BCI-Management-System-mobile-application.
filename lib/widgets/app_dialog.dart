import 'package:flutter/material.dart';

/// Shared helpers so dialogs fit phone screens without overflow.
class AppDialog {
  static void snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static double contentWidth(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return (screenWidth - 48).clamp(280.0, 480.0);
  }

  static void disposeControllers(
    Iterable<TextEditingController> controllers,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final TextEditingController controller in controllers) {
        controller.dispose();
      }
    });
  }

  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Delete',
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: actions(
            context: context,
            onCancel: () => Navigator.pop(context, false),
            confirmLabel: confirmLabel,
            onConfirm: () => Navigator.pop(context, true),
          ),
        );
      },
    );
    return confirmed == true;
  }

  static Future<T?> form<T>({
    required BuildContext context,
    required String title,
    required String confirmLabel,
    required Widget Function(BuildContext context, StateSetter setDialogState)
        fields,
    required T? Function(
      GlobalKey<FormState> formKey,
      StateSetter setDialogState,
    ) onConfirm,
  }) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return showDialog<T>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              scrollable: true,
              title: Text(title),
              content: content(
                context: context,
                child: Form(
                  key: formKey,
                  child: fields(context, setDialogState),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: actions(
                context: context,
                onCancel: () => Navigator.pop(dialogContext),
                confirmLabel: confirmLabel,
                onConfirm: () {
                  final T? result = onConfirm(formKey, setDialogState);
                  if (result != null) {
                    Navigator.pop(dialogContext, result);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  static Widget content({
    required BuildContext context,
    required Widget child,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: contentWidth(context),
        maxHeight: MediaQuery.sizeOf(context).height * 0.55,
      ),
      child: SingleChildScrollView(
        child: child,
      ),
    );
  }

  static Widget dropdownLabel(String text) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );
  }

  static List<Widget> actions({
    required BuildContext context,
    required VoidCallback onCancel,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) {
    final bool narrow = MediaQuery.sizeOf(context).width < 380;

    if (narrow) {
      return <Widget>[
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onConfirm,
            child: Text(confirmLabel),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
        ),
      ];
    }

    return <Widget>[
      TextButton(onPressed: onCancel, child: const Text('Cancel')),
      FilledButton(onPressed: onConfirm, child: Text(confirmLabel)),
    ];
  }
}
