import 'package:flutter/material.dart';

import '../app/app_container.dart';
import '../theme/bci_theme.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.app});

  final AppContainer app;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Text(
          'BCI Management',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Manage students, courses and enrolments in one place',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final int columns = constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 600
                    ? 2
                    : 1;

            final double width =
                (constraints.maxWidth - ((columns - 1) * 12)) / columns;

            final List<Widget> cards = <Widget>[
              SummaryCard(
                title: 'Students',
                value: app.studentService.students.length.toString(),
                subtitle: '${app.studentService.activeCount} active',
                icon: Icons.school_outlined,
                accent: BciColors.navy,
                accentSoft: BciColors.sky,
              ),
              SummaryCard(
                title: 'Courses',
                value: app.courseService.courses.length.toString(),
                subtitle: '${app.courseService.activeCount} active',
                icon: Icons.menu_book_outlined,
                accent: BciColors.gold,
                accentSoft: BciColors.goldSoft,
              ),
              SummaryCard(
                title: 'Enrolments',
                value: app.enrollmentService.enrollments.length.toString(),
                subtitle: 'Student–course links',
                icon: Icons.how_to_reg_outlined,
                accent: BciColors.teal,
                accentSoft: BciColors.tealSoft,
              ),
            ];

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: cards
                  .map((Widget card) => SizedBox(width: width, child: card))
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'What you can do',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                const _GuideRow(
                  icon: Icons.people_alt_outlined,
                  title: 'Students',
                  description:
                      'Add, view, edit and delete student records. Tap a student to see assigned courses.',
                ),
                const Divider(),
                const _GuideRow(
                  icon: Icons.menu_book_outlined,
                  title: 'Courses',
                  description:
                      'Add, view, edit and delete courses. See who is enrolled in each course.',
                ),
                const Divider(),
                const _GuideRow(
                  icon: Icons.how_to_reg_outlined,
                  title: 'Enrolment',
                  description:
                      'Enrol a student into a selected course and manage assignments.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GuideRow extends StatelessWidget {
  const _GuideRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: BciColors.sky,
        child: Icon(icon, color: BciColors.navy),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: BciColors.navy,
        ),
      ),
      subtitle: Text(description),
    );
  }
}
