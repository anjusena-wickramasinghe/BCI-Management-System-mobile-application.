import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

/// Shared CRUD list layout: header, search, list or empty state, and FAB.
class CrudListPage extends StatelessWidget {
  const CrudListPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.searchLabel,
    required this.searchHint,
    required this.onSearchChanged,
    required this.itemCount,
    required this.emptyMessage,
    required this.itemBuilder,
    required this.fabIcon,
    required this.fabLabel,
    required this.onFabPressed,
  });

  final String title;
  final String subtitle;
  final String searchLabel;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final int itemCount;
  final String emptyMessage;
  final NullableIndexedWidgetBuilder itemBuilder;
  final IconData fabIcon;
  final String fabLabel;
  final VoidCallback onFabPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  PageHeader(title: title, subtitle: subtitle),
                  const SizedBox(height: 14),
                  TextField(
                    decoration: InputDecoration(
                      labelText: searchLabel,
                      hintText: searchHint,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: onSearchChanged,
                  ),
                ],
              ),
            ),
            Expanded(
              child: itemCount == 0
                  ? Center(child: Text(emptyMessage))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                      itemCount: itemCount,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: itemBuilder,
                    ),
            ),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton.extended(
            onPressed: onFabPressed,
            icon: Icon(fabIcon),
            label: Text(fabLabel),
          ),
        ),
      ],
    );
  }
}
