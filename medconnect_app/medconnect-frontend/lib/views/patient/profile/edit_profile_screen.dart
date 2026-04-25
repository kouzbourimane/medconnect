import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/patient/patient_profile_view_model.dart';
import '../../../view_models/patient_auth_view_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedBloodType;
  final TextEditingController _allergiesCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _emergencyContactCtrl = TextEditingController();
  final TextEditingController _emergencyPhoneCtrl = TextEditingController();

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<PatientProfileViewModel>(
      context,
      listen: false,
    ).profileData;
    if (profile != null) {
      _selectedBloodType = profile.bloodType;
      _allergiesCtrl.text = profile.allergies ?? '';
      _heightCtrl.text = profile.height?.toString() ?? '';
      _weightCtrl.text = profile.weight?.toString() ?? '';
      _emergencyContactCtrl.text = profile.emergencyContact ?? '';
      _emergencyPhoneCtrl.text = profile.emergencyPhone ?? '';
    }
  }

  @override
  void dispose() {
    _allergiesCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _emergencyContactCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<PatientProfileViewModel>();
    final authVM = context.watch<PatientAuthViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        title: const Text(
          'Modifier le Profil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF567991),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: profileVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Informations Médicales"),
                    _buildCard([
                      _buildBloodTypeDropdown(),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _heightCtrl,
                        "Taille (cm)",
                        Icons.height,
                        isNumeric: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _weightCtrl,
                        "Poids (kg)",
                        Icons.monitor_weight,
                        isNumeric: true,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _allergiesCtrl,
                        "Allergies",
                        Icons.warning_amber,
                        maxLines: 3,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Contact d'Urgence"),
                    _buildCard([
                      _buildTextField(
                        _emergencyContactCtrl,
                        "Nom du contact",
                        Icons.person_pin,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        _emergencyPhoneCtrl,
                        "Téléphone d'urgence",
                        Icons.phone_forwarded,
                        isPhone: true,
                      ),
                    ]),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Color(0xFF567991)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Annuler",
                              style: TextStyle(color: Color(0xFF567991)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF567991),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: authVM.authResponse?.token != null
                                ? () => _saveProfile(
                                    authVM.authResponse!.token!,
                                    profileVM,
                                  )
                                : null,
                            child: const Text(
                              "Enregistrer",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF567991),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildBloodTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodType,
      decoration: InputDecoration(
        labelText: "Groupe Sanguin",
        prefixIcon: const Icon(Icons.bloodtype, color: Color(0xFF86B7D7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _bloodTypes
          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
          .toList(),
      onChanged: (value) => setState(() => _selectedBloodType = value),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumeric = false,
    bool isPhone = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric
          ? TextInputType.number
          : (isPhone ? TextInputType.phone : TextInputType.text),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF86B7D7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (isNumeric && value != null && value.isNotEmpty) {
          final val = double.tryParse(value);
          if (val == null || val <= 0) return "Entrez un nombre positif";
        }
        return null;
      },
    );
  }

  void _saveProfile(String token, PatientProfileViewModel vm) async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = {
        'blood_type': _selectedBloodType,
        'allergies': _allergiesCtrl.text.trim(),
        'height': double.tryParse(_heightCtrl.text),
        'weight': double.tryParse(_weightCtrl.text),
        'emergency_contact': _emergencyContactCtrl.text.trim(),
        'emergency_phone': _emergencyPhoneCtrl.text.trim(),
      };

      final success = await vm.updateProfile(token, data);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil mis à jour avec succès"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vm.error ?? "Une erreur est survenue"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
