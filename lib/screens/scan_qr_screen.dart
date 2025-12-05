import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../api_service.dart';
import 'document_details_screen.dart';

class ScanQrScreen extends StatefulWidget {
  final String token;

  const ScanQrScreen({super.key, required this.token});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: MobileScanner(
        onDetect: (capture) async {
          if (scanned) return;
          scanned = true;

          final barcode = capture.barcodes.first;
          final rawValue = barcode.rawValue;

          if (rawValue == null) return;

          try {
            final data = jsonDecode(rawValue);
            int documentId = data["document_id"];

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DocumentDetailsScreen(
                  token: widget.token,
                  documentId: documentId,
                ),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Invalid QR: $e")));
          }
        },
      ),
    );
  }
}
