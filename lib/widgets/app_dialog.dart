import 'package:flutter/material.dart';

/// Shared helpers so dialogs fit phone screens without overflow.
class AppDialog {
  static double contentWidth(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return (screenWidth - 48).clamp(280.0, 480.0);
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
