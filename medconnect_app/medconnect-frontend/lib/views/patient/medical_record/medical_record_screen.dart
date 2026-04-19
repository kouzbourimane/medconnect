import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../view_models/patient/medical_record_view_model.dart';
import '../../../view_models/patient_auth_view_model.dart';
<<<<<<< HEAD
=======
import '../../common/document_viewer_screen.dart';
import '../../../models/medical_document_model.dart';
import '../../../services/document_download_service.dart';
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
import '../documents/widgets/document_widgets.dart';

class MedicalRecordScreen extends StatefulWidget {
  const MedicalRecordScreen({Key? key}) : super(key: key);

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authViewModel = Provider.of<PatientAuthViewModel>(
      context,
      listen: false,
    );
    final token = authViewModel.authResponse?.token;
    if (token != null) {
      await Provider.of<MedicalRecordViewModel>(
        context,
        listen: false,
      ).fetchMedicalRecord(token);
    }
  }

<<<<<<< HEAD
=======
  void _viewDocument(MedicalDocument doc) {
    if (doc.fileUrl == null || doc.fileUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL du document non disponible')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(
          url: doc.fileUrl!,
          title: doc.title,
          documentType: doc.documentType,
        ),
      ),
    );
  }

  Future<void> _downloadDocument(MedicalDocument doc) async {
    if (doc.fileUrl == null || doc.fileUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL du document non disponible')),
      );
      return;
    }

    final String fileName = doc.fileUrl!.split('/').last.split('?').first;
    await DocumentDownloadService().downloadFile(
      context,
      doc.fileUrl!,
      fileName.contains('.') ? fileName : '$fileName.pdf',
    );
  }

>>>>>>> 21b118e356682c0277daf70006db17122b794da3
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        title: const Text(
          'Mon Dossier Médical',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF567991),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: () => Provider.of<MedicalRecordViewModel>(
              context,
              listen: false,
            ).exportToPdf(),
            tooltip: 'Exporter en PDF',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Santé'),
            Tab(text: 'Consultations'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: Consumer<MedicalRecordViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${viewModel.error}'),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.record == null) {
            return const Center(child: Text('Aucune donnée disponible'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildHealthInfoTab(viewModel),
              _buildConsultationsTab(viewModel),
              _buildDocumentsTab(viewModel),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () => Provider.of<MedicalRecordViewModel>(
            context,
            listen: false,
          ).exportToPdf(),
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('EXPORTER LE DOSSIER COMPLET (PDF)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF567991),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthInfoTab(MedicalRecordViewModel viewModel) {
    final info = viewModel.record!.patientInfo;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard('Données de base', [
          _buildInfoRow(Icons.person, 'Nom Complet', info.fullName),
          _buildInfoRow(
            Icons.bloodtype,
            'Groupe Sanguin',
            info.bloodType ?? '--',
          ),
          _buildInfoRow(
            Icons.height,
            'Taille',
            info.height != null ? '${info.height} cm' : '--',
          ),
          _buildInfoRow(
            Icons.monitor_weight,
            'Poids',
            info.weight != null ? '${info.weight} kg' : '--',
          ),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('Alertes & Allergies', [
          _buildInfoRow(
            Icons.warning_amber,
            'Allergies',
            info.allergies ?? 'Aucune allergie connue',
            isAlert: (info.allergies != null),
          ),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('Urgence', [
          _buildInfoRow(
            Icons.contact_phone,
            'Contact',
            info.emergencyContact ?? '--',
          ),
          _buildInfoRow(Icons.phone, 'Téléphone', info.emergencyPhone ?? '--'),
        ]),
      ],
    );
  }

  Widget _buildConsultationsTab(MedicalRecordViewModel viewModel) {
    final appts = viewModel.record!.consultations;
    if (appts.isEmpty) {
      return const Center(child: Text('Aucun historique de consultation.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appts.length,
      itemBuilder: (context, index) {
        final appt = appts[index];
        final date = DateFormat(
          'dd MMMM yyyy',
        ).format(DateTime.parse(appt.date));
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF86B7D7),
              child: Icon(Icons.calendar_today, color: Colors.white, size: 20),
            ),
            title: Text(
              'Dr. ${appt.doctorName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('$date - ${appt.specialty}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Motif:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(appt.reason ?? 'Non renseigné'),
                    if (appt.notes != null) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Notes du médecin:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(appt.notes!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentsTab(MedicalRecordViewModel viewModel) {
    final docs = viewModel.record!.documents;
    if (docs.isEmpty) {
      return const Center(child: Text('Aucun document médical disponible.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        return DocumentCard(
          document: doc,
<<<<<<< HEAD
          onView:
              () {}, // Handled by DocumentsScreen usually, but could be added here
          onDownload: () {},
=======
          onView: () => _viewDocument(doc),
          onDownload: () => _downloadDocument(doc),
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
        );
      },
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF567991),
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isAlert = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isAlert ? Colors.red : Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isAlert ? FontWeight.bold : FontWeight.normal,
                    color: isAlert ? Colors.red : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
