import 'dart:io';
<<<<<<< HEAD
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
=======
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UploadDocumentDialog extends StatefulWidget {
  final Function(File file, String title, String type, String? description)
  onUpload;
>>>>>>> 21b118e356682c0277daf70006db17122b794da3

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
<<<<<<< HEAD
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
=======
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
  bool _isPicking = false;

  final List<String> _types = ['ORDONNANCE', 'ANALYSE', 'AUTRE'];

  Future<void> _pickFile() async {
    setState(() => _isPicking = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
<<<<<<< HEAD
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
=======
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          // Auto-fill title with filename if empty
          if (_title.isEmpty) {
            _title = result.files.single.name.split('.').first;
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    } finally {
      setState(() => _isPicking = false);
    }
  }

<<<<<<< HEAD
  bool get _hasFile => _selectedFile != null || _selectedFileBytes != null;

=======
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
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
<<<<<<< HEAD
                      color: !_hasFile
=======
                      color: _selectedFile == null
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
                          ? Colors.grey[400]!
                          : const Color(0xFF567991),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
<<<<<<< HEAD
                        !_hasFile
                            ? Icons.upload_file
                            : Icons.check_circle,
                        color: !_hasFile
=======
                        _selectedFile == null
                            ? Icons.upload_file
                            : Icons.check_circle,
                        color: _selectedFile == null
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
                            ? Colors.grey
                            : const Color(0xFF567991),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
<<<<<<< HEAD
                        !_hasFile
                            ? 'Sélectionner un fichier (PDF, JPG, PNG)'
                            : (_selectedFileName ?? 'Fichier sélectionné'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: !_hasFile
=======
                        _selectedFile == null
                            ? 'Sélectionner un fichier (PDF, JPG, PNG)'
                            : _selectedFile!.path
                                  .split(Platform.pathSeparator)
                                  .last,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedFile == null
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
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
<<<<<<< HEAD
                key: ValueKey(_title), // Force rebuild if title changed programmatically
=======
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
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
<<<<<<< HEAD
          onPressed: !_hasFile
=======
          onPressed: _selectedFile == null
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    widget.onUpload(
<<<<<<< HEAD
                      file: _selectedFile,
                      fileBytes: _selectedFileBytes,
                      fileName: _selectedFileName,
                      title: _title,
                      type: _documentType,
                      description: _description,
=======
                      _selectedFile!,
                      _title,
                      _documentType,
                      _description,
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
                    );
                    Navigator.pop(context);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF567991),
            foregroundColor: Colors.white,
          ),
          child: const Text('Uploader'),
        ),
      ],
    );
  }
}
