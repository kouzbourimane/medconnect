import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../view_models/doctor_patients_view_model.dart';
import '../../../view_models/doctor_auth_view_model.dart';
import '../../../models/patient.dart';
import '../../../models/appointment.dart';
import 'patient_medical_folder_screen.dart';
import 'patient_medical_documents_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load history on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<DoctorAuthViewModel>(context, listen: false).authResponse?.token;
      if (token != null) {
        Provider.of<DoctorPatientsViewModel>(context, listen: false).fetchPatientHistory(token, widget.patient.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.patient.user;
    final fullName = "${user.firstName ?? ''} ${user.lastName ?? ''}";

    return Scaffold(
      appBar: AppBar(
        title: Text(fullName),
        backgroundColor: const Color(0xFF567991),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
             Tab(text: "Infos"),
             Tab(text: "RDV"),
             Tab(text: "Dossier"),
             Tab(text: "Documents"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildHistoryTab(),
          PatientMedicalFolderScreen(patientId: widget.patient.id),
          PatientMedicalDocumentsScreen(patientId: widget.patient.id, patientName: fullName),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    final p = widget.patient;
    final u = widget.patient.user;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard("Contact", [
          _buildInfoRow(Icons.email, "Email", u.email),
          _buildInfoRow(Icons.phone, "Téléphone", u.phone ?? "Non renseigné"),
          _buildInfoRow(Icons.location_on, "Adresse", u.address ?? "Non renseignée"),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard("Médical", [
          _buildInfoRow(Icons.bloodtype, "Groupe Sanguin", p.bloodType ?? "Non renseigné"),
          _buildInfoRow(Icons.warning, "Allergies", p.allergies ?? "Aucune connue"),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard("Urgence", [
          _buildInfoRow(Icons.notification_important, "Contact", p.emergencyContact ?? "Non renseigné"),
          _buildInfoRow(Icons.phone_android, "Tél. Urgence", p.emergencyPhone ?? "Non renseigné"),
        ]),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF567991))),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(value, style: const TextStyle(color: Colors.black87)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<DoctorPatientsViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoadingHistory) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (viewModel.selectedPatientHistory.isEmpty) {
          return const Center(child: Text("Aucun historique de rendez-vous."));
        }

        return ListView.builder(
          itemCount: viewModel.selectedPatientHistory.length,
          itemBuilder: (context, index) {
            final appt = viewModel.selectedPatientHistory[index];
            final date = DateTime.parse(appt.date);
            final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(date);
            
            return ListTile(
              leading: Icon(
                Icons.event_note, 
                color: appt.status == Appointment.statusCompleted ? Colors.green : Colors.grey
              ),
              title: Text(appt.reason ?? "Consultation"),
              subtitle: Text(dateStr),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(appt.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getStatusColor(appt.status)),
                ),
                child: Text(
                  appt.status, 
                  style: TextStyle(color: _getStatusColor(appt.status), fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case Appointment.statusConfirmed:
        return Colors.blue;
      case Appointment.statusPending:
        return Colors.orange;
      case Appointment.statusCancelled:
        return Colors.red;
      case Appointment.statusRefused:
        return Colors.redAccent;
      case Appointment.statusCompleted:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
