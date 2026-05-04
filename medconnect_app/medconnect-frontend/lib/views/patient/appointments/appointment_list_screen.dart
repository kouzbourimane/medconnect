import 'package:flutter/material.dart';
import 'package:medconnect_app/views/patient/appointments/appointment_detail_screen.dart';
import 'package:medconnect_app/views/patient/appointments/book_appointment_screen.dart';
import 'package:provider/provider.dart';
import '../../../view_models/patient/appointment_view_model.dart';
import '../../../view_models/patient_auth_view_model.dart';
import '../../../models/appointment.dart';

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

  void _loadData() {
    final authViewModel = Provider.of<PatientAuthViewModel>(
      context,
      listen: false,
    );
    final token = authViewModel.authResponse?.token;
    if (token != null) {
      Provider.of<AppointmentViewModel>(
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
            Tab(text: 'A venir'),
            Tab(text: 'Passes'),
            Tab(text: 'Annules'),
          ],
        ),
      ),
      body: Consumer<AppointmentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text("Erreur: ${viewModel.error}"));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildList(viewModel.upcomingAppointments),
              _buildList(viewModel.pastAppointments),
              _buildList(viewModel.cancelledAppointments),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BookAppointmentScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF567991),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return const Center(child: Text("Aucun rendez-vous trouve"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF567991).withOpacity(0.1),
              child: const Icon(
                Icons.medical_services,
                color: Color(0xFF567991),
              ),
            ),
            title: Text(
              appt.doctorName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appt.specialty),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(appt.date.replaceAll('T', ' ').substring(0, 16)),
                  ],
                ),
              ],
            ),
            trailing: _buildStatusBadge(appt.status),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AppointmentDetailScreen(appointment: appt),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case Appointment.statusPending:
        color = Colors.orange;
        text = 'En attente';
        break;
      case Appointment.statusConfirmed:
        color = Colors.green;
        text = 'Confirme';
        break;
      case Appointment.statusCancelled:
        color = Colors.red;
        text = 'Annule';
        break;
      case Appointment.statusRefused:
        color = Colors.redAccent;
        text = 'Refuse';
        break;
      case Appointment.statusCompleted:
        color = Colors.blue;
        text = 'Termine';
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
