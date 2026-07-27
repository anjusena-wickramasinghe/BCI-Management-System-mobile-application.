import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.enabled = true,
    this.isNumber = false,
    this.isEmail = false,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool isNumber;
  final bool isEmail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (String? value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required.';
          }
          if (isEmail && !value.contains('@')) {
            return 'Enter a valid email address.';
          }
          if (isNumber) {
            final int? parsed = int.tryParse(value.trim());
            if (parsed == null || parsed <= 0) {
              return 'Enter a valid positive number.';
            }
          }
          return null;
        },
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
