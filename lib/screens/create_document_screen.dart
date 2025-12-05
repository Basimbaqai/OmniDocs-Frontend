import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../api_service.dart';
import '../widgets/image_preview_grid.dart';

class CreateDocumentScreen extends StatefulWidget {
  final String token;
  const CreateDocumentScreen({super.key, required this.token});

  @override
  State<CreateDocumentScreen> createState() => _CreateDocumentScreenState();
}

class _CreateDocumentScreenState extends State<CreateDocumentScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  bool loading = false;

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

    setState(() => loading = true);

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

      Navigator.pop(context, true);

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
              Text("Document ID: ${response['document_id']}"),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Document")),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: const Icon(Icons.camera_alt),
      ),
      body: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: "Document Title",
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          Expanded(child: ImagePreviewGrid(images: _images)),
          ElevatedButton(
            onPressed: loading ? null : uploadDocument,
            child: loading
                ? const CircularProgressIndicator()
                : const Text("Upload Document"),
          ),
        ],
      ),
    );
  }
}
