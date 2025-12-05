import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
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
  Map<String, dynamic>? documentData;
  Map<String, dynamic>? qrData;
  String? localPdfPath;
  bool loadingDocument = true;
  bool loadingQr = true;
  bool downloadingPdf = false;

  @override
  void initState() {
    super.initState();
    loadDocumentAndQr();
  }

  Future<void> loadDocumentAndQr() async {
    try {
      final docRes = await ApiService.getDocumentFromQr(
        widget.token,
        widget.documentId,
      );
      final qrRes = await ApiService.getQrCode(widget.token, widget.documentId);

      setState(() {
        documentData = docRes;
        qrData = qrRes;
        loadingDocument = false;
        loadingQr = false;
      });

      // Download PDF in background
      if (docRes['s3_link'] != null) {
        await downloadPdf(docRes['s3_link']);
      }
    } catch (e) {
      setState(() {
        loadingDocument = false;
        loadingQr = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading document: $e')));
      }
    }
  }

  Future<void> downloadPdf(String url) async {
    try {
      setState(() => downloadingPdf = true);

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/document_${widget.documentId}.pdf');
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          localPdfPath = file.path;
          downloadingPdf = false;
        });
      }
    } catch (e) {
      setState(() => downloadingPdf = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error downloading PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loadingDocument || loadingQr) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (documentData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Document')),
        body: const Center(child: Text('Failed to load document')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(documentData!['title'] ?? 'Document')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document Title and Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        documentData!['title'] ?? 'Untitled',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Created: ${documentData!['created_at'] ?? 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // QR Code Section
              Text('QR Code', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              if (qrData != null && qrData!['qr_code_base64'] != null)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Image.memory(
                      base64Decode(
                        qrData!['qr_code_base64'].replaceFirst(
                          'data:image/png;base64,',
                          '',
                        ),
                      ),
                      width: 250,
                      height: 250,
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Center(child: Text('QR Code not available')),
                ),
              const SizedBox(height: 20),

              // PDF Section
              Text(
                'Document PDF',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              if (downloadingPdf)
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Downloading PDF...'),
                      ],
                    ),
                  ),
                )
              else if (localPdfPath != null && File(localPdfPath!).existsSync())
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: PDFView(
                    filePath: localPdfPath,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: false,
                    pageFling: false,
                    onRender: (_) {},
                    onError: (error) {
                      print('PDF Error: $error');
                    },
                  ),
                )
              else
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (documentData!['s3_link'] != null) {
                          downloadPdf(documentData!['s3_link']);
                        }
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download PDF'),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
