import 'package:flutter/material.dart';

import '../core/text_utils.dart';
import 'form_fields.dart';

class EntityAvatar extends StatelessWidget {
  const EntityAvatar({
    super.key,
    required this.backgroundColor,
    required this.foregroundColor,
    this.text,
    this.icon,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final String? text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      child: icon != null
          ? Icon(icon)
          : Text(TextUtils.initial(text ?? '')),
    );
  }
}

class RecordActionsMenu extends StatelessWidget {
  const RecordActionsMenu({
    super.key,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        switch (value) {
          case 'view':
            onView();
          case 'edit':
            onEdit();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (_) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(value: 'view', child: Text('View')),
        PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
        PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
      ],
    );
  }
}

class EntityListCard extends StatelessWidget {
  const EntityListCard({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        leading: leading,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        isThreeLine: true,
        trailing: RecordActionsMenu(
          onView: onView,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }
}

class DetailSectionCard extends StatelessWidget {
  const DetailSectionCard({
    super.key,
    required this.heading,
    required this.details,
  });

  final String heading;
  final List<Widget> details;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              heading,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 14),
            ...details,
          ],
        ),
      ),
    );
  }
}

class InfoListCard extends StatelessWidget {
  const InfoListCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class MissingEntityScaffold extends StatelessWidget {
  const MissingEntityScaffold({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(message)),
    );
  }
}

class EntityDetailScaffold extends StatelessWidget {
  const EntityDetailScaffold({
    super.key,
    required this.appBarTitle,
    required this.onEdit,
    required this.heading,
    required this.details,
    required this.relatedTitle,
    required this.relatedEmptyTitle,
    required this.relatedEmptySubtitle,
    required this.relatedChildren,
  });

  final String appBarTitle;
  final VoidCallback onEdit;
  final String heading;
  final List<DetailRow> details;
  final String relatedTitle;
  final String relatedEmptyTitle;
  final String relatedEmptySubtitle;
  final List<Widget> relatedChildren;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: <Widget>[
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          DetailSectionCard(heading: heading, details: details),
          const SizedBox(height: 18),
          Text(
            relatedTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (relatedChildren.isEmpty)
            InfoListCard(
              title: relatedEmptyTitle,
              subtitle: relatedEmptySubtitle,
            )
          else
            ...relatedChildren,
        ],
      ),
    );
  }
}
