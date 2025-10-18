import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String? title;

  const PdfViewerScreen({super.key, required this.pdfUrl, this.title});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late Future<File> _pdfFileFuture;

  @override
  void initState() {
    super.initState();
    _pdfFileFuture = _downloadPdf();
  }

  Future<File> _downloadPdf() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${widget.pdfUrl.split('/').last}';
    final file = File(filePath);

    // If already downloaded, reuse it
    if (await file.exists()) return file;

    final dio = Dio();
    await dio.download(widget.pdfUrl, filePath);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'View PDF'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: FutureBuilder<File>(
        future: _pdfFileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final file = snapshot.data!;
          return PdfView(
            controller: PdfController(
              document: PdfDocument.openFile(file.path),
            ),
          );
        },
      ),
    );
  }
}
