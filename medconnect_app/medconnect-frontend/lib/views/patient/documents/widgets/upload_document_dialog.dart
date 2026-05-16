import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class UploadDocumentDialog extends StatefulWidget {
  final Function({
    File? file,
    Uint8List? fileBytes,
    String? fileName,
    required String title,
    required String type,
    String? description,
  }) onUpload;

  const UploadDocumentDialog({Key? key, required this.onUpload})
    : super(key: key);

  @override
  State<UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<UploadDocumentDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _documentType = 'AUTRE';
  String? _description;
  File? _selectedFile;
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  bool _isPicking = false;

  final List<String> _types = ['ORDONNANCE', 'ANALYSE', 'AUTRE'];

  Future<void> _pickFile() async {
    setState(() => _isPicking = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true, // Crucial for Web
      );

      if (result != null) {
        final platformFile = result.files.single;
        setState(() {
          if (platformFile.bytes != null) {
            _selectedFileBytes = platformFile.bytes;
            _selectedFileName = platformFile.name;
          } else if (platformFile.path != null) {
            _selectedFile = File(platformFile.path!);
            _selectedFileName = platformFile.name;
          }

          if (_title.isEmpty && _selectedFileName != null) {
            _title = _selectedFileName!.split('.').first;
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    } finally {
      setState(() => _isPicking = false);
    }
  }

  bool get _hasFile => _selectedFile != null || _selectedFileBytes != null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un document'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _isPicking ? null : _pickFile,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: !_hasFile
                          ? Colors.grey[400]!
                          : const Color(0xFF388E3C),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        !_hasFile
                            ? Icons.upload_file
                            : Icons.check_circle,
                        color: !_hasFile
                            ? Colors.grey
                            : const Color(0xFF388E3C),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        !_hasFile
                            ? 'Sélectionner un fichier (PDF, JPG, PNG)'
                            : (_selectedFileName ?? 'Fichier sélectionné'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: !_hasFile
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: ValueKey(_title), // Force rebuild if title changed programmatically
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Titre du document',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _title = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _documentType,
                decoration: const InputDecoration(
                  labelText: 'Type de document',
                  border: OutlineInputBorder(),
                ),
                items: _types.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _documentType = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) => _description = value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: !_hasFile
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    widget.onUpload(
                      file: _selectedFile,
                      fileBytes: _selectedFileBytes,
                      fileName: _selectedFileName,
                      title: _title,
                      type: _documentType,
                      description: _description,
                    );
                    Navigator.pop(context);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF388E3C),
            foregroundColor: Colors.white,
          ),
          child: const Text('Uploader'),
        ),
      ],
    );
  }
}
