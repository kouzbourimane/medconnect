import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/appointment.dart';
import '../../../view_models/patient/appointment_view_model.dart';
import '../../../view_models/patient_auth_view_model.dart';
import 'appointment_detail_screen.dart';
import 'book_appointment_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen>
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
      await Provider.of<AppointmentViewModel>(
        context,
        listen: false,
      ).fetchAppointments(token);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        title: const Text('Mes Rendez-vous'),
        backgroundColor: const Color(0xFF567991),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          tabs: const [
            Tab(text: 'Demandes'),
            Tab(text: 'A venir'),
            Tab(text: 'Passes'),
          ],
        ),
      ),
      body: Consumer<AppointmentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text('Erreur: ${viewModel.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Reessayer'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(
                  viewModel.pendingAppointments,
                  emptyIcon: Icons.inbox_outlined,
                  emptyText: 'Aucune demande de rendez-vous.',
                ),
                _buildList(
                  viewModel.upcomingAppointments,
                  emptyIcon: Icons.event_available_outlined,
                  emptyText: 'Aucun rendez-vous a venir.',
                ),
                _buildList(
                  viewModel.pastAppointments,
                  emptyIcon: Icons.history,
                  emptyText: 'Aucun rendez-vous passe.',
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BookAppointmentScreen(),
            ),
          );
          _loadData();
        },
        backgroundColor: const Color(0xFF567991),
        icon: const Icon(Icons.add),
        label: const Text('Nouveau RDV'),
      ),
    );
  }

  Widget _buildList(
    List<Appointment> appointments, {
    required IconData emptyIcon,
    required String emptyText,
  }) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              emptyText,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        return _buildAppointmentCard(appt);
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appt) {
    final isRefused = appt.status == Appointment.statusRefused;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => AppointmentDetailScreen(appointment: appt),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isRefused
                    ? Colors.purple.withOpacity(0.1)
                    : const Color(0xFF567991).withOpacity(0.1),
                child: Icon(
                  Icons.medical_services,
                  color: isRefused ? Colors.purple : const Color(0xFF567991),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appt.doctorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      appt.specialty,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          appt.date.replaceAll('T', ' ').substring(0, 16),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _buildStatusBadge(appt.status),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    late final Color color;
    late final String text;
    late final IconData icon;

    switch (status) {
      case Appointment.statusPending:
        color = Colors.orange;
        text = 'En attente';
        icon = Icons.hourglass_empty;
        break;
      case Appointment.statusConfirmed:
        color = Colors.green;
        text = 'Confirme';
        icon = Icons.check_circle_outline;
        break;
      case Appointment.statusCancelled:
        color = Colors.red;
        text = 'Annule';
        icon = Icons.cancel_outlined;
        break;
      case Appointment.statusCompleted:
        color = Colors.blue;
        text = 'Termine';
        icon = Icons.task_alt;
        break;
      case Appointment.statusRefused:
        color = Colors.purple;
        text = 'Refuse';
        icon = Icons.block;
        break;
      default:
        color = Colors.grey;
        text = status;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
