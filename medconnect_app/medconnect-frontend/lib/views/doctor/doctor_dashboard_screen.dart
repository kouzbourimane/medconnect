import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/doctor_dashboard_view_model.dart';
import '../../view_models/doctor_auth_view_model.dart';
import '../auth/combined_login_screen.dart';
import 'appointments/doctor_appointments_screen.dart';
import '../messages/conversations_screen.dart';
import 'profile/doctor_profile_screen.dart';
import 'patients/doctor_patients_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authViewModel = Provider.of<DoctorAuthViewModel>(
      context,
      listen: false,
    );
    final token = authViewModel.authResponse?.token;

   // Assuming we have a token or mock logic handles it
   await Provider.of<DoctorDashboardViewModel>(
        context,
        listen: false,
      ).fetchDashboardData(token ?? "");
  }

  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SizedBox.shrink(), // Dashboard home is handled separately in build method
    const DoctorAppointmentsScreen(),
    const ConversationsScreen(role: 'DOCTOR'),
    const DoctorPatientsScreen(),
    const DoctorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // ... existing variable declarations if needed, but managing state for tab switching
    // We need to refactor the Scaffold body to switch based on _currentIndex
    
    // NOTE: The original code had the dashboard content directly in build. 
    // I should move the original dashboard content to a separate method or widget or just condition it here.
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      // AppBar needs to change or stay generic? 
      // The original AppBar had logic for dashboard. Let's keep it for now but maybe make it conditional if needed.
      // For simplicity, let's keep the same AppBar for now or update it.
      appBar: _currentIndex == 0 ? _buildDashboardAppBar(context) : null,
      drawer: _buildDrawer(context),
      body: _currentIndex == 0 ? _buildDashboardBody(context) : _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF567991),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  PreferredSizeWidget _buildDashboardAppBar(BuildContext context) {
    final viewModel = Provider.of<DoctorDashboardViewModel>(context);
    final authViewModel = Provider.of<DoctorAuthViewModel>(context, listen: false);
    final user = authViewModel.authResponse?.user;
    final doctorName = user?.firstName ?? 'Docteur';
    
    return AppBar(
        title: Text(
          'Bonjour, Dr. $doctorName',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF567991),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
              if ((viewModel.dashboardData?.recentNotifications.length ?? 0) > 0)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '${viewModel.dashboardData?.recentNotifications.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
  }

  Widget _buildDashboardBody(BuildContext context) {
    final viewModel = Provider.of<DoctorDashboardViewModel>(context);
    return viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Erreur: ${viewModel.error}'),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsSection(viewModel),
                        const SizedBox(height: 20),
                        const Text(
                          'Rendez-vous du jour',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTodayAppointments(viewModel),
                        const SizedBox(height: 20),
                         const Text(
                          'Notifications Récentes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildNotificationsList(viewModel),
                      ],
                    ),
                  ),
                );
  }

    Widget _buildDrawer(BuildContext context) {
    final authViewModel = Provider.of<DoctorAuthViewModel>(
      context,
      listen: false,
    );
    final user = authViewModel.authResponse?.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              'Dr. ${user?.firstName ?? ""} ${user?.lastName ?? ""}',
            ),
            accountEmail: Text(user?.email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user?.firstName?.isNotEmpty == true)
                    ? user!.firstName![0].toUpperCase()
                    : "D",
                style: const TextStyle(
                  fontSize: 40.0,
                  color: Color(0xFF567991),
                ),
              ),
            ),
            decoration: const BoxDecoration(color: Color(0xFF567991)),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Tableau de bord'),
            onTap: () => Navigator.pop(context),
          ),
           const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Déconnexion'),
            onTap: () async {
              await authViewModel.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const CombinedLoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(DoctorDashboardViewModel viewModel) {
      if (viewModel.dashboardData == null) return const SizedBox.shrink();

      final patients = viewModel.dashboardData!.patientsSeenCount;
      final upcoming = viewModel.dashboardData!.upcomingAppointmentsCount;
      final messages = viewModel.dashboardData!.unreadMessagesCount;

      return Row(
          children: [
              Expanded(child: _buildStatCard("Patients Vus", "$patients", Icons.people, Colors.blue)),
              const SizedBox(width: 10),
              Expanded(child: _buildStatCard("RDV à venir", "$upcoming", Icons.calendar_month, Colors.orange)),
               const SizedBox(width: 10),
              Expanded(child: _buildStatCard("Messages", "$messages", Icons.message, Colors.purple)),
          ],
      );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
      return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
               boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
          ),
          child: Column(
              children: [
                  Icon(icon, color: color, size: 30),
                  const SizedBox(height: 8),
                  Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center,),
              ],
          ),
      );
  }

  Widget _buildTodayAppointments(DoctorDashboardViewModel viewModel) {
      final appointments = viewModel.dashboardData?.todayAppointments ?? [];
      if (appointments.isEmpty) {
          return const Card(
              child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text("Aucun rendez-vous aujourd'hui")),
              ),
          );
      }

      return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
              final appt = appointments[index];
              return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: const Color(0xFFF5F9FC),
                          child: Icon(Icons.person, color: Colors.grey[600]),
                      ),
                      title: Text(appt.doctorName, style: const TextStyle(fontWeight: FontWeight.bold)), // Using doctorName field for Patient Name
                      subtitle: Text("${appt.specialty} - ${appt.date.split('T')[1].substring(0, 5)}"), // Specialty as Type
                      trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: appt.status == 'Confirmé' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                              appt.status,
                              style: TextStyle(
                                  color: appt.status == 'Confirmé' ? Colors.green : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold
                              ),
                          ),
                      ),
                  ),
              );
          },
      );
  }

    Widget _buildNotificationsList(DoctorDashboardViewModel viewModel) {
    final notifications = viewModel.dashboardData?.recentNotifications ?? [];
    if (notifications.isEmpty) {
      return const Text(
        "Aucune notification récente.",
        style: TextStyle(color: Colors.grey),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notifications.length,
      separatorBuilder: (ctx, i) => const Divider(),
      itemBuilder: (ctx, i) {
        final notif = notifications[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFF5F9FC),
            child: Icon(Icons.notifications_none, color: Colors.grey[600]),
          ),
          title: Text(
            notif.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(notif.message),
          trailing: Text(
            notif.date.split('T')[0],
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      },
    );
  }
}
