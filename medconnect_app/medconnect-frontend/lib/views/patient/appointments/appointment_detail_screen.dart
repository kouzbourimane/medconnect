import 'package:flutter/material.dart';
import '../../../models/appointment.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({Key? key, required this.appointment})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        title: const Text('Détails du Rendez-vous'),
        backgroundColor: const Color(0xFF567991),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildSection("Médecin", [
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
              Text(appointment.reason ?? "Non spécifié"),
            ]),
            if (appointment.notesPatient != null) ...[
              const SizedBox(height: 16),
              _buildSection("Notes du médecin", [
                Text(appointment.notesPatient!),
              ]),
            ],
            const SizedBox(height: 30),
            if (appointment.status == 'PENDING' ||
                appointment.status == 'CONFIRMED')
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement cancel
                },
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
            _getStatusText(appointment.status),
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

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'En attente';
      case 'CONFIRMED':
        return 'Confirmé';
      case 'CANCELLED':
        return 'Annulé';
      case 'COMPLETED':
        return 'Terminé';
      case 'REJECTED':
        return 'Rejeté';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'REJECTED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
