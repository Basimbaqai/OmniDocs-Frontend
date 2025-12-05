import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../api_service.dart';
import '../widgets/document_list_tile.dart';
import '../widgets/image_preview_grid.dart';
import 'document_details_screen.dart';

class DocumentsAndQrScreen extends StatefulWidget {
  final String token;

  const DocumentsAndQrScreen({super.key, required this.token});

  @override
  State<DocumentsAndQrScreen> createState() => _DocumentsAndQrScreenState();
}

class _DocumentsAndQrScreenState extends State<DocumentsAndQrScreen> {
  bool loadingDocuments = true;
  List<dynamic> documents = [];

  // Create document state
  final TextEditingController _titleController = TextEditingController();
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool creatingDocument = false;
  bool showCreateForm = false;

  @override
  void initState() {
    super.initState();
    loadDocuments();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> loadDocuments() async {
    try {
      final data = await ApiService.getMyDocuments(widget.token);
      setState(() {
        documents = data;
        loadingDocuments = false;
      });
    } catch (e) {
      setState(() => loadingDocuments = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading documents: $e')));
    }
  }

  Future<void> pickImage() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.camera);

    if (img != null) {
      setState(() {
        _images.add(File(img.path));
      });
    }
  }

  Future<void> uploadDocument() async {
    if (_titleController.text.isEmpty || _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and images required")),
      );
      return;
    }

    setState(() => creatingDocument = true);

    List<http.MultipartFile> files = [];
    for (var img in _images) {
      files.add(
        await http.MultipartFile.fromPath(
          'images',
          img.path,
          filename: img.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    try {
      final response = await ApiService.uploadDocument(
        token: widget.token,
        title: _titleController.text,
        images: files,
      );

      // Reset form
      _titleController.clear();
      _images.clear();
      setState(() {
        creatingDocument = false;
        showCreateForm = false;
      });

      // Reload documents
      loadDocuments();

      // Show QR code dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Document Created"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(
                Uri.parse(response['qr_code_base64']).data!.contentAsBytes(),
                height: 200,
              ),
              const SizedBox(height: 16),
              Text("Document ID: ${response['document_id']}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error uploading: $e")));
      setState(() => creatingDocument = false);
    }
  }

  void _clearImages() {
    setState(() {
      _images.clear();
      _titleController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showCreateForm) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Create Document"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                showCreateForm = false;
                _clearImages();
              });
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: creatingDocument ? null : pickImage,
          child: const Icon(Icons.camera_alt),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Document Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            if (_images.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: ImagePreviewGrid(images: _images)),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: creatingDocument ? null : _clearImages,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                              ),
                              child: const Text("Clear"),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: creatingDocument
                                  ? null
                                  : uploadDocument,
                              child: creatingDocument
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text("Upload"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: Center(
                  child: Text(
                    _titleController.text.isEmpty
                        ? "Enter a title and take photos"
                        : "Take photos with the camera button",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            showCreateForm = true;
            _clearImages();
          });
        },
        child: const Icon(Icons.add),
      ),
      body: loadingDocuments
          ? const Center(child: CircularProgressIndicator())
          : documents.isEmpty
          ? const Center(
              child: Text("No documents yet. Create one using the + button"),
            )
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
            ),
    );
  }
}
