import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/appointment.dart';
import '../../../view_models/patient/appointment_view_model.dart';
import '../../../view_models/patient_auth_view_model.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({Key? key, required this.appointment})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        title: const Text('Details du Rendez-vous'),
        backgroundColor: const Color(0xFF567991),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildSection("Medecin", [
              Text(
                appointment.doctorName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                appointment.specialty,
                style: const TextStyle(color: Colors.grey),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection("Date et Heure", [
              Text(
                appointment.date.replaceAll('T', ' ').substring(0, 16),
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                "${appointment.duration} minutes",
                style: const TextStyle(color: Colors.grey),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection("Raison", [
              Text(appointment.reason ?? "Non specifie"),
            ]),
            if (appointment.notesPatient != null) ...[
              const SizedBox(height: 16),
              _buildSection("Notes du medecin", [
                Text(appointment.notesPatient!),
              ]),
            ],
            if (appointment.refusalReason != null &&
                appointment.refusalReason!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection("Motif du refus", [
                Text(appointment.refusalReason!),
              ]),
            ],
            if (appointment.cancelReason != null &&
                appointment.cancelReason!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection("Motif d'annulation", [
                Text(appointment.cancelReason!),
              ]),
            ],
            const SizedBox(height: 30),
            if (appointment.status == Appointment.statusPending ||
                appointment.status == Appointment.statusConfirmed)
              ElevatedButton(
                onPressed: () => _cancelAppointment(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Annuler le Rendez-vous'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF567991).withOpacity(0.1),
            child: const Icon(
              Icons.calendar_today,
              size: 40,
              color: Color(0xFF567991),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            appointment.statusLabel,
            style: TextStyle(
              color: _getStatusColor(appointment.status),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case Appointment.statusPending:
        return Colors.orange;
      case Appointment.statusConfirmed:
        return Colors.green;
      case Appointment.statusCancelled:
        return Colors.red;
      case Appointment.statusRefused:
        return Colors.red;
      case Appointment.statusCompleted:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _cancelAppointment(BuildContext context) async {
    final authViewModel = Provider.of<PatientAuthViewModel>(context, listen: false);
    final appointmentViewModel = Provider.of<AppointmentViewModel>(context, listen: false);
    final token = authViewModel.authResponse?.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expiree, veuillez vous reconnecter.')),
      );
      return;
    }

    final reason = await _askReason(context, "Motif d'annulation");
    if (reason == null) return;

    final success = await appointmentViewModel.cancelAppointment(
      token,
      appointment.id,
      reason: reason,
    );
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rendez-vous annule avec succes.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appointmentViewModel.error ?? 'Erreur d\'annulation')),
      );
    }
  }

  Future<String?> _askReason(BuildContext context, String title) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Motif',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Retour'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
}
