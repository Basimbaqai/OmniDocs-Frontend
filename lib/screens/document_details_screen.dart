import 'package:flutter/material.dart';
import '../api_service.dart';

class DocumentDetailsScreen extends StatefulWidget {
  final String token;
  final int documentId;

  const DocumentDetailsScreen({
    super.key,
    required this.token,
    required this.documentId,
  });

  @override
  State<DocumentDetailsScreen> createState() => _DocumentDetailsScreenState();
}

class _DocumentDetailsScreenState extends State<DocumentDetailsScreen> {
  Map<String, dynamic>? data;

  @override
  void initState() {
    loadDocument();
    super.initState();
  }

  Future<void> loadDocument() async {
    final res = await ApiService.getDocumentFromQr(
      widget.token,
      widget.documentId,
    );

    setState(() => data = res);
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(data!['title'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("PDF Link: ${data!['s3_link']}"),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("Open PDF")),
          ],
        ),
      ),
    );
  }
}
