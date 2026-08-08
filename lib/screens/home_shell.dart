import 'package:flutter/material.dart';

import '../app/app_container.dart';
import 'courses_screen.dart';
import 'dashboard_screen.dart';
import 'enrollments_screen.dart';
import 'students_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.app});

  final AppContainer app;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  static const List<NavigationDestination> _destinations =
      <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school),
      label: 'Students',
    ),
    NavigationDestination(
      icon: Icon(Icons.menu_book_outlined),
      selectedIcon: Icon(Icons.menu_book),
      label: 'Courses',
    ),
    NavigationDestination(
      icon: Icon(Icons.how_to_reg_outlined),
      selectedIcon: Icon(Icons.how_to_reg),
      label: 'Enrol',
    ),
  ];

  Widget _pageForIndex(int index) {
    switch (index) {
      case 0:
        return DashboardScreen(app: widget.app);
      case 1:
        return StudentsScreen(app: widget.app, onChanged: _refresh);
      case 2:
        return CoursesScreen(app: widget.app, onChanged: _refresh);
      case 3:
        return EnrollmentsScreen(app: widget.app, onChanged: _refresh);
      default:
        return DashboardScreen(app: widget.app);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.sizeOf(context).width >= 900;
    final Widget page = _pageForIndex(_selectedIndex);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BCI Management System'),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'BCI',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
      body: wide
          ? Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() => _selectedIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: _destinations
                      .map(
                        (NavigationDestination destination) =>
                            NavigationRailDestination(
                          icon: destination.icon,
                          selectedIcon: destination.selectedIcon,
                          label: Text(destination.label),
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: page),
              ],
            )
          : page,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() => _selectedIndex = index);
              },
              destinations: _destinations,
            ),
    );
  }
}
