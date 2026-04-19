import 'package:flutter/material.dart';
import 'package:medconnect_app/views/patient/appointments/book_appointment_screen.dart';
<<<<<<< HEAD
=======
import 'package:medconnect_app/views/patient/appointments/appointment_detail_screen.dart'; // Correct import path assumption or relative
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
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
            Tab(text: 'À venir'),
            Tab(text: 'Passés'),
            Tab(text: 'Annulés'),
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
<<<<<<< HEAD
            MaterialPageRoute(
              builder: (_) => const BookAppointmentScreen(),
            ),
=======
            MaterialPageRoute(builder: (_) => const BookAppointmentScreen()),
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
          );
        },
        backgroundColor: const Color(0xFF567991),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return const Center(child: Text("Aucun rendez-vous trouvé"));
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
<<<<<<< HEAD
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
=======
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AppointmentDetailScreen(appointment: appt),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
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
            ),
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        text = 'En attente';
        break;
      case 'CONFIRMED':
        color = Colors.green;
        text = 'Confirmé';
        break;
      case 'CANCELLED':
        color = Colors.red;
        text = 'Annulé';
        break;
      case 'COMPLETED':
        color = Colors.blue;
        text = 'Terminé';
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
