import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/doctor_patients_view_model.dart';
import '../../../view_models/doctor_auth_view_model.dart';
import 'patient_detail_screen.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<DoctorAuthViewModel>(context, listen: false).authResponse?.token;
      if (token != null) {
        Provider.of<DoctorPatientsViewModel>(context, listen: false).fetchPatients(token);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Patients'),
        backgroundColor: const Color(0xFF567991),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un patient...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                Provider.of<DoctorPatientsViewModel>(context, listen: false).search(value);
              },
            ),
          ),
          Expanded(
            child: Consumer<DoctorPatientsViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.patients.isEmpty) {
                  return const Center(child: Text("Aucun patient trouvé."));
                }

                return ListView.builder(
                  itemCount: viewModel.patients.length,
                  itemBuilder: (context, index) {
                    final patient = viewModel.patients[index];
                    final user = patient.user;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF567991),
                          child: Text(
                             (user.firstName != null && user.firstName!.isNotEmpty) 
                                ? user.firstName![0].toUpperCase() 
                                : 'P',
                             style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text("${user.firstName ?? ''} ${user.lastName ?? ''}"),
                        subtitle: Text(user.phone ?? 'Pas de téléphone'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientDetailScreen(patient: patient),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
