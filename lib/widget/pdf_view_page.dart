import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';

class PdfViewPage extends StatefulWidget {
  final String pdfPath;
  final bool hasPassword;

  const PdfViewPage(
      {super.key, required this.pdfPath, this.hasPassword = false});

  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  String? _password;
  bool _isPasswordRequired = false;
  bool _isLoading = true;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    _checkPassword();
  }

  void _checkPassword() async {
    if (widget.hasPassword) {
      setState(() {
        _isPasswordRequired = true;
        _isLoading = false;
      });
    } else {
      _loadPdf();
    }
  }

  void _loadPdf([String? password]) async {
    setState(() {
      _isLoading = true;
    });

    final file = File(widget.pdfPath);
    if (file.existsSync()) {
      setState(() {
        _isLoading = false;
        _isPasswordRequired = false;
      });
    } else {
      // Handle error jika file tidak ditemukan
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isPasswordRequired
              ? _buildPasswordInput()
              : _buildPdfView(),
    );
  }

  Widget _buildPasswordInput() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter Password',
              ),
              onChanged: (value) {
                _password = value;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_password != null && _password!.isNotEmpty) {
                  _loadPdf(_password);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfView() {
    return PDFView(
      filePath: widget.pdfPath,
      password: _password,
      onRender: (pages) {
        setState(() {
          _isLoading = false;
        });
      },
      onViewCreated: (PDFViewController pdfViewController) {
        _pdfViewController = pdfViewController;
      },
      onPageChanged: (int? page, int? total) {},
    );
  }
}
