import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import '../../services/document_download_service.dart';

class DocumentViewerScreen extends StatelessWidget {
  final String url;
  final String title;
  final String? documentType;

  const DocumentViewerScreen({
    Key? key,
    required this.url,
    required this.title,
    this.documentType,
  }) : super(key: key);

  bool get _isPdf {
    if (documentType != null &&
        (documentType!.toLowerCase().contains('pdf') ||
            documentType!.toLowerCase() == 'ordonnance')) {}
    return url.toLowerCase().contains('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: const Color(0xFF567991),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Extract filename or use title
              final fileName = url.split('/').last.split('?').first;
              DocumentDownloadService().downloadFile(
                context,
                url,
                fileName.contains('.') ? fileName : '$fileName.pdf',
              );
            },
          ),
        ],
      ),
      body: _isPdf
          ? const PDF().cachedFromUrl(
              url,
              placeholder: (progress) => Center(child: Text('$progress %')),
              errorWidget: (error) =>
                  Center(child: Text("Erreur de chargement: $error")),
            )
          : Center(
              child: Image.network(
                url,
                loadingBuilder: (ctx, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (ctx, error, stackTrace) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      "Impossible d'afficher ce fichier.\nURL: $url",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
