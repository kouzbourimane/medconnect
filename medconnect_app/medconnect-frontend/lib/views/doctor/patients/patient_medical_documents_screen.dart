import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../view_models/doctor_medical_document_view_model.dart';
import '../../../view_models/doctor_auth_view_model.dart';
import '../../../models/medical_document_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientMedicalDocumentsScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const PatientMedicalDocumentsScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
  }) : super(key: key);

  @override
  State<PatientMedicalDocumentsScreen> createState() => _PatientMedicalDocumentsScreenState();
}

class _PatientMedicalDocumentsScreenState extends State<PatientMedicalDocumentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<DoctorAuthViewModel>(context, listen: false).authResponse?.token;
      if (token != null) {
        Provider.of<DoctorMedicalDocumentViewModel>(context, listen: false)
            .fetchDocuments(token, widget.patientId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOptions(context),
        label: const Text("Ajouter Document"),
        icon: const Icon(Icons.note_add),
        backgroundColor: const Color(0xFF388E3C),
      ),
      body: Consumer<DoctorMedicalDocumentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text("Erreur: ${viewModel.error}", style: const TextStyle(color: Colors.red)));
          }
          if (viewModel.documents.isEmpty) {
            return const Center(child: Text("Aucun document médical trouvé."));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: viewModel.documents.length,
            itemBuilder: (context, index) {
              final doc = viewModel.documents[index];
              return _buildDocumentCard(doc);
            },
          );
        },
      ),
    );
  }

  Widget _buildDocumentCard(MedicalDocument doc) {
    final dateFormat = DateFormat('dd MMM yyyy à HH:mm');
    IconData icon;
    Color color;

    switch (doc.documentType) {
      case 'ORDONNANCE':
        icon = Icons.medication;
        color = Colors.green;
        break;
      case 'ANALYSE':
        icon = Icons.science;
        color = Colors.purple;
        break;
      case 'AUTRE':
      default:
        icon = Icons.folder;
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        title: Text(doc.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ajouté par: ${doc.uploadedBy} le ${dateFormat.format(doc.createdAt)}"),
            if (doc.description != null) Text(doc.description!, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _openFile(doc.fileUrl),
        ),
      ),
    );
  }

  Future<void> _openFile(String? url) async {
    if (url != null) {
       // Should implement download or launch url.
       // Assuming URL is accessible or handle via launchUrl
       // For emulator/chrome, ensure URL is absolute (http://127.0.0.1...)
       // Backend returns relative or absolute?
       // Usually returns relative in local dev unless configured.
       // We'll try standard launch.
       if (await canLaunchUrl(Uri.parse(url))) {
         await launchUrl(Uri.parse(url));
       } else {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Impossible d'ouvrir le fichier")));
       }
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text("Uploader un fichier (PDF, IMG)"),
            onTap: () {
              Navigator.pop(context);
              _showUploadDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text("Générer une ordonnance"),
            onTap: () {
              Navigator.pop(context);
              _showPrescriptionDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => UploadDocumentDialog(patientId: widget.patientId),
    );
  }

  void _showPrescriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => GeneratePrescriptionDialog(
        patientId: widget.patientId, 
        patientName: widget.patientName
      ),
    );
  }
}

class UploadDocumentDialog extends StatefulWidget {
  final int patientId;
  const UploadDocumentDialog({Key? key, required this.patientId}) : super(key: key);

  @override
  State<UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<UploadDocumentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedType = 'ANALYSE';
  File? _selectedFile;
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;

  @override
  Widget build(BuildContext context) {
    bool hasFile = _selectedFile != null || _selectedFileBytes != null;
    String fileName = _selectedFileName ?? '';

    return AlertDialog(
      title: const Text("Upload Document"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Titre"),
                validator: (v) => v!.isEmpty ? "Requis" : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'ORDONNANCE', child: Text("Ordonnance")),
                  DropdownMenuItem(value: 'ANALYSE', child: Text("Résultats Analyse")),
                  DropdownMenuItem(value: 'AUTRE', child: Text("Autre / Certificat")),
                ],
                onChanged: (v) => setState(() => _selectedType = v!),
                decoration: const InputDecoration(labelText: "Type"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: Text(hasFile ? "Fichier sélectionné" : "Choisir Fichier"),
                onPressed: _pickFile,
              ),
              if (hasFile) Text(fileName),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
        ElevatedButton(onPressed: _submit, child: const Text("Envoyer")),
      ],
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
      withData: true, // Important for web and small files
    );
    if (result != null) {
      final file = result.files.single;
      setState(() {
        if (file.bytes != null) {
          _selectedFileBytes = file.bytes;
          _selectedFileName = file.name;
          _selectedFile = null; // Clear file path if bytes available
        } else if (file.path != null) {
          _selectedFile = File(file.path!);
          _selectedFileName = file.name;
          _selectedFileBytes = null;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && (_selectedFile != null || _selectedFileBytes != null)) {
      final token = Provider.of<DoctorAuthViewModel>(context, listen: false).authResponse?.token;
      if (token == null) return;

      final success = await Provider.of<DoctorMedicalDocumentViewModel>(context, listen: false)
          .uploadDocument(
            token: token,
            file: _selectedFile,
            fileBytes: _selectedFileBytes,
            fileName: _selectedFileName,
            title: _titleController.text,
            type: _selectedType,
            patientId: widget.patientId,
            description: _descController.text,
          );

      if (success && mounted) Navigator.pop(context);
    }
  }
}

class GeneratePrescriptionDialog extends StatefulWidget {
  final int patientId;
  final String patientName;
  const GeneratePrescriptionDialog({Key? key, required this.patientId, required this.patientName}) : super(key: key);

  @override
  State<GeneratePrescriptionDialog> createState() => _GeneratePrescriptionDialogState();
}

class _GeneratePrescriptionDialogState extends State<GeneratePrescriptionDialog> {
  final _medicinesController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Générer Ordonnance"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text("Patient: ${widget.patientName}"),
            const SizedBox(height: 10),
            TextField(
              controller: _medicinesController,
              decoration: const InputDecoration(
                labelText: "Médicaments (un par ligne)",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: "Instructions / Posologie Globale",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
        ElevatedButton(onPressed: _generate, child: const Text("Générer & Envoyer")),
      ],
    );
  }

  Future<void> _generate() async {
    final token = Provider.of<DoctorAuthViewModel>(context, listen: false).authResponse?.token;
    final doctor = Provider.of<DoctorAuthViewModel>(context, listen: false).user;
    if (token == null || doctor == null) return;
    
    final doctorName = "${doctor.firstName} ${doctor.lastName}";
    final medicines = _medicinesController.text.split('\n').where((s) => s.trim().isNotEmpty).toList();

    showDialog(barrierDismissible: false, context: context, builder: (_) => const Center(child: CircularProgressIndicator()));

    final success = await Provider.of<DoctorMedicalDocumentViewModel>(context, listen: false)
        .generateAndUploadPrescription(
          token: token,
          patientId: widget.patientId,
          patientName: widget.patientName,
          doctorName: doctorName,
          medicines: medicines,
          instructions: _instructionsController.text,
        );

    Navigator.pop(context); // Pop loading
    if (success && mounted) {
      Navigator.pop(context); // Pop dialog
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ordonnance envoyée !")));
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de la génération")));
    }
  }
}
