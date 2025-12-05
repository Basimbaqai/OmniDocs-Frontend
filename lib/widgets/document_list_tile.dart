import 'package:flutter/material.dart';

class DocumentListTile extends StatelessWidget {
  final String title;
  final int documentId;
  final VoidCallback onTap;

  const DocumentListTile({
    super.key,
    required this.title,
    required this.documentId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text("ID: $documentId"),
      onTap: onTap,
    );
  }
}
