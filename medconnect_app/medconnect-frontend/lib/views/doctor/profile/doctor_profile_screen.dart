import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/doctor_profile_view_model.dart';
import 'schedule_editor.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({Key? key}) : super(key: key);

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() =>
        Provider.of<DoctorProfileViewModel>(context, listen: false).loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: const Color(0xFF567991),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Informations'),
            Tab(text: 'Horaires'),
          ],
        ),
      ),
      body: Consumer<DoctorProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(viewModel),
              ScheduleEditor(
                schedule: viewModel.schedule,
                onSave: (newSchedule) {
                  viewModel.updateSchedule(newSchedule);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Horaires mis à jour !")));
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTab(DoctorProfileViewModel viewModel) {
    // Basic editing for Bio and Fee
    final TextEditingController bioController = TextEditingController(
      text: viewModel.profileData['bio'] ?? '',
    );
    final TextEditingController feeController = TextEditingController(
      text: viewModel.profileData['fee']?.toString() ?? '50.0',
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text("Informations Générales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: feeController,
            decoration: const InputDecoration(
              labelText: 'Tarif Consultation (DH)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: bioController,
            decoration: const InputDecoration(
              labelText: 'Biographie / Présentation',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF567991),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              viewModel.updateProfile({
                'bio': bioController.text,
                'fee': double.tryParse(feeController.text) ?? 0.0,
              });
               ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profil mis à jour !")));
            },
            child: const Text('Enregistrer les informations'),
          ),
        ],
      ),
    );
  }
}
