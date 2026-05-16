import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medconnect_app/view_models/doctor_appointment_view_model.dart';
import 'package:medconnect_app/view_models/doctor_auth_view_model.dart';
import 'package:medconnect_app/models/appointment.dart';
import 'doctor_calendar_screen.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  Future<void> _loadAppointments() async {
    final authViewModel = Provider.of<DoctorAuthViewModel>(context, listen: false);
    final token = authViewModel.authResponse?.token;
    if (token != null) {
      await Provider.of<DoctorAppointmentViewModel>(context, listen: false)
          .fetchAppointments(token);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DoctorAppointmentViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Gestion des Rendez-vous'),
        backgroundColor: const Color(0xFF388E3C),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Demandes'),
            Tab(text: 'A venir'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.error != null
              ? Center(child: Text('Erreur: ${viewModel.error}'))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentList(viewModel.pendingAppointments, isPending: true),
                    _buildAppointmentList(viewModel.upcomingAppointments),
                    _buildAppointmentList(viewModel.pastAppointments),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoctorCalendarScreen()),
          );
        },
        backgroundColor: const Color(0xFF388E3C),
        child: const Icon(Icons.calendar_month),
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments, {bool isPending = false}) {
    if (appointments.isEmpty) {
      return const Center(child: Text('Aucun rendez-vous.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        final canComplete = !isPending &&
            appt.status == Appointment.statusConfirmed &&
            !appt.dateTime.isAfter(DateTime.now());

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFE1F5FE),
                      child: Text(
                        appt.patientName.isNotEmpty ? appt.patientName[0].toUpperCase() : 'P',
                        style: const TextStyle(color: Color(0xFF0288D1)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appt.patientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            appt.reason ?? 'Motif non specifie',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(appt.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        appt.statusLabel,
                        style: TextStyle(
                          color: _getStatusColor(appt.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(appt.date.split('T')[0]),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${appt.date.split('T')[1].substring(0, 5)} (${appt.duration} min)'),
                  ],
                ),
                if (isPending) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _handleAction(context, appt, 'refuse'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Refuser'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _handleAction(context, appt, 'accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF388E3C),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Accepter'),
                      ),
                    ],
                  ),
                ],
                if (!isPending &&
                    appt.status == Appointment.statusConfirmed &&
                    appt.dateTime.isAfter(DateTime.now())) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _handleAction(context, appt, 'cancel'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Annuler'),
                      ),
                    ],
                  )
                ],
                if (canComplete) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => _handleAction(context, appt, 'complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Marquer termine'),
                      ),
                    ],
                  )
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case Appointment.statusConfirmed:
        return Colors.green;
      case Appointment.statusPending:
        return Colors.orange;
      case Appointment.statusCancelled:
      case Appointment.statusRefused:
        return Colors.red;
      case Appointment.statusCompleted:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleAction(BuildContext context, Appointment appt, String action) async {
    final viewModel = Provider.of<DoctorAppointmentViewModel>(context, listen: false);
    final authViewModel = Provider.of<DoctorAuthViewModel>(context, listen: false);
    final token = authViewModel.authResponse?.token;

    if (token == null) return;

    try {
      if (action == 'accept') {
        await viewModel.acceptAppointment(token, appt.id);
      } else if (action == 'refuse') {
        final reason = await _askReason(context, 'Motif du refus');
        if (reason == null) return;
        await viewModel.refuseAppointment(token, appt.id, reason: reason);
      } else if (action == 'cancel') {
        final reason = await _askReason(context, 'Motif d annulation');
        if (reason == null) return;
        await viewModel.cancelAppointment(token, appt.id, reason: reason);
      } else if (action == 'complete') {
        await viewModel.completeAppointment(token, appt.id);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Action effectuee avec succes')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
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
