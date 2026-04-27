import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/appointment.dart';
import '../../../view_models/patient/appointment_view_model.dart';
import '../../../view_models/patient_auth_view_model.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({Key? key, required this.appointment})
      : super(key: key);

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late Appointment _appointment;

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
  }

  Future<void> _cancelAppointment() async {
    // Dialog de confirmation avant annulation
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Annuler le rendez-vous'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Êtes-vous sûr de vouloir annuler ce rendez-vous ?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _appointment.doctorName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_appointment.specialty),
                  Text(
                    _appointment.date.replaceAll('T', ' ').substring(0, 16),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Garder le RDV'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Annuler le RDV',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final authViewModel =
        Provider.of<PatientAuthViewModel>(context, listen: false);
    final viewModel =
        Provider.of<AppointmentViewModel>(context, listen: false);
    final token = authViewModel.authResponse?.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expirée, veuillez vous reconnecter')),
      );
      return;
    }

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await viewModel.cancelAppointment(token, _appointment.id);

    if (!mounted) return;
    Navigator.pop(context); // Fermer le loader

    if (success) {
      // Mise à jour locale de l'affichage
      setState(() {
        _appointment = _appointment.copyWith(
          status: Appointment.statusCancelled,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rendez-vous annulé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      // Retourner true pour signaler le refresh à la liste
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${viewModel.error ?? "Annulation impossible"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSection('Médecin', [
              Text(
                _appointment.doctorName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _appointment.specialty,
                style: const TextStyle(color: Colors.grey),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('Date et Heure', [
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Color(0xFF567991)),
                  const SizedBox(width: 8),
                  Text(
                    _appointment.date.replaceAll('T', ' ').substring(0, 16),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${_appointment.duration} minutes',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('Motif de consultation', [
              Text(
                _appointment.reason ?? 'Non spécifié',
                style: const TextStyle(fontSize: 15),
              ),
            ]),
            if (_appointment.notesPatient != null &&
                _appointment.notesPatient!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection('Notes du médecin', [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    _appointment.notesPatient!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ]),
            ],
            const SizedBox(height: 30),
            // Bouton d'annulation uniquement si le statut le permet
            if (_appointment.status == Appointment.statusPending ||
                _appointment.status == Appointment.statusConfirmed)
              ElevatedButton.icon(
                onPressed: _cancelAppointment,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Annuler le Rendez-vous'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: _getStatusColor(_appointment.status).withOpacity(0.1),
            child: Icon(
              Icons.calendar_today,
              size: 40,
              color: _getStatusColor(_appointment.status),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(_appointment.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStatusColor(_appointment.status).withOpacity(0.5),
              ),
            ),
            child: Text(
              _getStatusText(_appointment.status),
              style: TextStyle(
                color: _getStatusColor(_appointment.status),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
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
      case Appointment.statusPending:
        return 'En attente';
      case Appointment.statusConfirmed:
        return 'Confirmé';
      case Appointment.statusCancelled:
        return 'Annulé';
      case Appointment.statusCompleted:
        return 'Terminé';
      case Appointment.statusRefused:
        return 'Refusé par le médecin';
      default:
        return status;
    }
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
        return Colors.purple;
      case Appointment.statusCompleted:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
