import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/patient/patient_profile_view_model.dart';
import '../../../view_models/patient_auth_view_model.dart';
import 'edit_profile_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = Provider.of<PatientAuthViewModel>(
        context,
        listen: false,
      );
      if (authViewModel.authResponse?.token != null) {
        Provider.of<PatientProfileViewModel>(
          context,
          listen: false,
        ).fetchProfile(authViewModel.authResponse!.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<PatientProfileViewModel>();
    final authVM = context.watch<PatientAuthViewModel>();
    final user = authVM.authResponse?.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        title: const Text(
          'Mon Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF567991),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _navigateToEdit(context),
          ),
        ],
      ),
      body: profileVM.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF567991)),
            )
          : RefreshIndicator(
              onRefresh: () async {
                if (authVM.authResponse?.token != null) {
                  await profileVM.fetchProfile(authVM.authResponse!.token!);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("Informations Personnelles"),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.person,
                              "Nom complet",
                              "${user?.firstName ?? ''} ${user?.lastName ?? ''}",
                            ),
                            const Divider(),
                            _buildInfoRow(
                              Icons.email,
                              "Email",
                              user?.email ?? "Non renseigné",
                            ),
                            const Divider(),
                            _buildInfoRow(
                              Icons.phone,
                              "Téléphone",
                              user?.phone ?? "Non renseigné",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Informations Médicales"),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoRow(
                                    Icons.bloodtype,
                                    "Groupe Sanguin",
                                    profileVM.profileData?.bloodType ??
                                        "Non spécifié",
                                  ),
                                ),
                                if (profileVM.profileData?.bloodType != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF567991,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      profileVM.profileData!.bloodType!,
                                      style: const TextStyle(
                                        color: Color(0xFF567991),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const Divider(),
                            _buildInfoRow(
                              Icons.height,
                              "Taille",
                              profileVM.profileData?.height != null
                                  ? "${profileVM.profileData!.height} cm"
                                  : "Non renseigné",
                            ),
                            const Divider(),
                            _buildInfoRow(
                              Icons.monitor_weight,
                              "Poids",
                              profileVM.profileData?.weight != null
                                  ? "${profileVM.profileData!.weight} kg"
                                  : "Non renseigné",
                            ),
                            if (profileVM.profileData?.calculateBMI() !=
                                null) ...[
                              const Divider(),
                              _buildBMIRow(
                                profileVM.profileData!.calculateBMI()!,
                              ),
                            ],
                            const Divider(),
                            _buildInfoRow(
                              Icons.warning_amber,
                              "Allergies",
                              profileVM.profileData?.allergies ??
                                  "Aucune déclarée",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader("Contact d'Urgence"),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.contact_phone,
                              "Nom",
                              profileVM.profileData?.emergencyContact ??
                                  "Non renseigné",
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildInfoRow(
                                    Icons.phone_forwarded,
                                    "Téléphone",
                                    profileVM.profileData?.emergencyPhone ??
                                        "Non renseigné",
                                  ),
                                ),
                                if (profileVM.profileData?.emergencyPhone !=
                                    null)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.call,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      // Implementation de l'appel (url_launcher ou autre)
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Appel de ${profileVM.profileData!.emergencyPhone}",
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          "Modifier mon profil",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF567991),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _navigateToEdit(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF567991),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF86B7D7), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIRow(double bmi) {
    String category;
    Color color;
    if (bmi < 18.5) {
      category = "Insuffisance pondérale";
      color = Colors.orange;
    } else if (bmi < 25) {
      category = "Poids normal";
      color = Colors.green;
    } else if (bmi < 30) {
      category = "Surpoids";
      color = Colors.orange;
    } else {
      category = "Obésité";
      color = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.calculate, color: Color(0xFF86B7D7), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "IMC (Indice de Masse Corporelle)",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Row(
                  children: [
                    Text(
                      bmi.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
