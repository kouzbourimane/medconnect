import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../view_models/doctor_medical_record_view_model.dart';
import '../../../view_models/doctor_auth_view_model.dart';
import '../../../models/medical_record.dart';

class PatientMedicalFolderScreen extends StatefulWidget {
  final int patientId;

  const PatientMedicalFolderScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  State<PatientMedicalFolderScreen> createState() => _PatientMedicalFolderScreenState();
}

class _PatientMedicalFolderScreenState extends State<PatientMedicalFolderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<DoctorAuthViewModel>(context, listen: false).authResponse?.token;
      if (token != null) {
        Provider.of<DoctorMedicalRecordViewModel>(context, listen: false)
            .fetchRecords(token, widget.patientId);
      }
    });
  }

  void _showAddRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddMedicalRecordDialog(patientId: widget.patientId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Tab content
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecordDialog(context),
        label: const Text("Ajouter Note / Prescription"),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF388E3C),
      ),
      body: Consumer<DoctorMedicalRecordViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text("Erreur: ${viewModel.error}", style: const TextStyle(color: Colors.red)));
          }
          if (viewModel.records.isEmpty) {
            return const Center(child: Text("Aucun dossier médical trouvé."));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: viewModel.records.length,
            itemBuilder: (context, index) {
              final record = viewModel.records[index];
              return _buildRecordCard(record);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(MedicalRecord record) {
    final dateFormat = DateFormat('dd MMM yyyy à HH:mm');
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          record.title, 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF388E3C))
        ),
        subtitle: Text("Dr. ${record.doctorName} - ${dateFormat.format(record.recordDate)}"),
        leading: const Icon(Icons.folder_shared, color: Color(0xFF388E3C)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection("Description", record.description),
                if (record.diagnosis != null && record.diagnosis!.isNotEmpty)
                  _buildSection("Diagnostic", record.diagnosis!),
                if (record.treatment != null && record.treatment!.isNotEmpty)
                  _buildSection("Traitement / Prescription", record.treatment!),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }
}

class AddMedicalRecordDialog extends StatefulWidget {
  final int patientId;
  const AddMedicalRecordDialog({Key? key, required this.patientId}) : super(key: key);

  @override
  State<AddMedicalRecordDialog> createState() => _AddMedicalRecordDialogState();
}

class _AddMedicalRecordDialogState extends State<AddMedicalRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _diagController = TextEditingController();
  final _treatmentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nouveau Dossier"),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Titre (ex: Consultation Grippe)"),
                  validator: (v) => v!.isEmpty ? "Requis" : null,
                ),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: "Description / Notes"),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? "Requis" : null,
                ),
                TextFormField(
                  controller: _diagController,
                  decoration: const InputDecoration(labelText: "Diagnostic"),
                  maxLines: 2,
                ),
                TextFormField(
                  controller: _treatmentController,
                  decoration: const InputDecoration(labelText: "Prescription / Traitement"),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF388E3C),
            foregroundColor: Colors.white,
          ),
          child: const Text("Enregistrer"),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final token = Provider.of<DoctorAuthViewModel>(context, listen: false).authResponse?.token;
      if (token == null) return;

      final record = MedicalRecord(
        id: 0, // Ignored on create
        patientId: widget.patientId,
        doctorId: 0, // Set by backend
        doctorName: '', // Backend
        title: _titleController.text,
        description: _descController.text,
        diagnosis: _diagController.text,
        treatment: _treatmentController.text,
        recordDate: DateTime.now(), // Backend sets it
      );

      final success = await Provider.of<DoctorMedicalRecordViewModel>(context, listen: false)
          .addRecord(token, record);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dossier ajouté !")));
      }
    }
  }
}
