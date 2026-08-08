import 'package:flutter/material.dart';

import 'app/app_container.dart';
import 'screens/home_shell.dart';
import 'theme/bci_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // DIP: composition root creates concrete implementations once.
  runApp(BciManagementApp(app: AppContainer()));
}

class BciManagementApp extends StatelessWidget {
  const BciManagementApp({super.key, required this.app});

  /// UI depends on the container of service abstractions, not storage details.
  final AppContainer app;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BCI Management System',
      theme: BciTheme.light(),
      home: HomeShell(app: app),
    );
  }
}
