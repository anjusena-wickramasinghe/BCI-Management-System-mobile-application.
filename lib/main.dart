import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'state/bci_store.dart';
import 'theme/bci_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(BciManagementApp(store: BciStore()));
}

class BciManagementApp extends StatelessWidget {
  const BciManagementApp({super.key, required this.store});

  final BciStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BCI Management System',
      theme: BciTheme.light(),
      home: HomeShell(store: store),
    );
  }
}
