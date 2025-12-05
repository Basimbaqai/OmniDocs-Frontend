import 'package:flutter/material.dart';

import '../api_service.dart';
import '../widgets/document_list_tile.dart';
import 'document_details_screen.dart';

class MyDocumentsScreen extends StatefulWidget {
  final String token;
  const MyDocumentsScreen({super.key, required this.token});

  @override
  State<MyDocumentsScreen> createState() => _MyDocumentsScreenState();
}

class _MyDocumentsScreenState extends State<MyDocumentsScreen> {
  bool loading = true;
  List<dynamic> documents = [];

  @override
  void initState() {
    super.initState();
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    final data = await ApiService.getMyDocuments(widget.token);
    setState(() {
      documents = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              return DocumentListTile(
                title: doc['title'],
                documentId: doc['document_id'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DocumentDetailsScreen(
                        token: widget.token,
                        documentId: doc['document_id'],
                      ),
                    ),
                  );
                },
              );
            },
          );
  }
}
