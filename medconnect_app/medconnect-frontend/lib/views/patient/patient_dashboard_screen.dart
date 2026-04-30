import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/patient/patient_dashboard_view_model.dart';
import '../../view_models/patient_auth_view_model.dart';
import '../auth/combined_login_screen.dart';
import 'appointments/appointment_list_screen.dart';
import 'appointments/book_appointment_screen.dart';
import '../messages/conversations_screen.dart';
import 'profile/patient_profile_screen.dart';
import 'documents/documents_screen.dart';
import 'medical_record/medical_record_screen.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  @override
  void initState() {
    super.initState();
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
      await Provider.of<PatientDashboardViewModel>(
        context,
        listen: false,
      ).fetchDashboardData(token);
    } else {
      // Handle missing token (e.g., redirect to login)
      // For now, we assume token exists if we reached here
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PatientDashboardViewModel>(context);
    final authViewModel = Provider.of<PatientAuthViewModel>(
      context,
      listen: false,
    );
    final user = authViewModel.authResponse?.user;
    final userName = user?.firstName ?? 'Patient';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        title: Text(
          'Bonjour, $userName',
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
              if ((viewModel.dashboardData?.recentNotifications.length ?? 0) >
                  0)
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
      ),
      drawer: _buildDrawer(context),
      body: viewModel.isLoading
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
                    _buildInfosSection(viewModel),
                    const SizedBox(height: 20),
                    _buildSummaryCards(viewModel),
                    const SizedBox(height: 20),
                    const Text(
                      'Actions Rapides',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildQuickActionsGrid(context),
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
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF567991),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'RDV',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Documents'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AppointmentListScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DocumentsScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ConversationsScreen(role: 'PATIENT'),
              ),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PatientProfileScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final authViewModel = Provider.of<PatientAuthViewModel>(
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
              '${user?.firstName ?? ""} ${user?.lastName ?? ""}',
            ),
            accountEmail: Text(user?.email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user?.firstName?.isNotEmpty == true)
                    ? user!.firstName![0].toUpperCase()
                    : "P",
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
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Mon profil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PatientProfileScreen()),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Text('Santé', style: TextStyle(color: Colors.grey)),
          ),

          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Dossier médical'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MedicalRecordScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: const Text('Mes documents'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DocumentsScreen()),
              );
            },
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

  Widget _buildInfosSection(PatientDashboardViewModel viewModel) {
    final profile = viewModel.dashboardData?.patientProfile;
    if (profile == null) return const SizedBox.shrink();

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(
              "Groupe Sanguin",
              profile['blood_type'] ?? 'N/A',
              Icons.bloodtype,
            ),
            _buildInfoItem(
              "Allergies",
              profile['allergies'] ?? 'Aucune',
              Icons.warning_amber,
            ),
            _buildInfoItem(
              "Urgence",
              profile['emergency_phone'] ?? 'N/A',
              Icons.phone_in_talk,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF86B7D7), size: 28),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSummaryCards(PatientDashboardViewModel viewModel) {
    if (viewModel.dashboardData == null) return const SizedBox.shrink();

    final nextAppt = viewModel.dashboardData!.nextAppointment;
    final msgCount = viewModel.dashboardData!.unreadMessagesCount;
    final docCount = viewModel.dashboardData!.newDocumentsCount;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSummaryCard(
            "Prochain RDV",
            nextAppt != null
                ? "${nextAppt.date.split('T')[0]}\n${nextAppt.doctorName}"
                : "Aucun RDV",
            Icons.calendar_month,
            const Color(0xFF567991),
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            "Messages",
            "$msgCount non lus",
            Icons.message,
            const Color(0xFF86B7D7),
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ConversationsScreen(role: 'PATIENT'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            "Documents",
            "$docCount nouveaux",
            Icons.folder,
            Colors.orangeAccent,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DocumentsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String content,
    IconData icon,
    Color color, [
    VoidCallback? onTap,
  ]) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildActionCard(
          context,
          "Prendre RDV",
          Icons.add_alarm,
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookAppointmentScreen()),
          ),
        ),
        _buildActionCard(
          context,
          "Mes Ordonnances",
          Icons.description,
          Colors.green,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DocumentsScreen()),
          ),
        ),
        _buildActionCard(
          context,
          "Contacter Médecin",
          Icons.chat,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ConversationsScreen(role: 'PATIENT'),
            ),
          ),
        ),
        _buildActionCard(
          context,
          "Historique",
          Icons.history,
          Colors.orange,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MedicalRecordScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color, [
    VoidCallback? onTap,
  ]) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(PatientDashboardViewModel viewModel) {
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
            notif.date.split('T')[0], // Simple formatting
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      },
    );
  }
}
