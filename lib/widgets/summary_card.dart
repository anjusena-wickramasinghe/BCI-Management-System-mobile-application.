import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.accent,
    this.accentSoft,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final Color? accent;
  final Color? accentSoft;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Color iconBg = accentSoft ?? colors.primaryContainer;
    final Color iconFg = accent ?? colors.onPrimaryContainer;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 25,
              backgroundColor: iconBg,
              child: Icon(icon, color: iconFg),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accent ?? colors.primary,
                        ),
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
