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
<<<<<<< HEAD

=======
  final _passwordFormKey = GlobalKey<FormState>();

  // Personal Info
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _dateOfBirthCtrl = TextEditingController();

  // Medical Info
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
  String? _selectedBloodType;
  final TextEditingController _allergiesCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _emergencyContactCtrl = TextEditingController();
  final TextEditingController _emergencyPhoneCtrl = TextEditingController();

<<<<<<< HEAD
=======
  // Password Change
  final TextEditingController _oldPasswordCtrl = TextEditingController();
  final TextEditingController _newPasswordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isChangingPassword = false;

>>>>>>> 21b118e356682c0277daf70006db17122b794da3
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
<<<<<<< HEAD
    if (profile != null) {
=======

    if (profile != null) {
      // User Info
      _firstNameCtrl.text = profile.user?.firstName ?? '';
      _lastNameCtrl.text = profile.user?.lastName ?? '';
      _emailCtrl.text = profile.user?.email ?? '';
      _phoneCtrl.text = profile.user?.phone ?? '';

      _addressCtrl.text = profile.user?.address ?? '';
      _dateOfBirthCtrl.text = profile.user?.dateOfBirth ?? '';

      // Medical Info
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
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
<<<<<<< HEAD
=======
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();

    _addressCtrl.dispose();
    _dateOfBirthCtrl.dispose();

>>>>>>> 21b118e356682c0277daf70006db17122b794da3
    _allergiesCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _emergencyContactCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
<<<<<<< HEAD
=======

    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
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
<<<<<<< HEAD
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
=======
      body: profileVM.isLoading && !_isChangingPassword
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildPersonalSection(),
                  const SizedBox(height: 24),
                  _buildMedicalSection(),
                  const SizedBox(height: 24),
                  _buildSecuritySection(authVM, profileVM),
                  const SizedBox(height: 32),
                  _buildActionButtons(authVM, profileVM),
                ],
              ),
            ),
    );
  }

  Widget _buildPersonalSection() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Informations Personnelles"),
          _buildCard([
            _buildTextField(_firstNameCtrl, "Prénom", Icons.person),
            const SizedBox(height: 16),
            _buildTextField(_lastNameCtrl, "Nom", Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(
              _emailCtrl,
              "Email",
              Icons.email,
              isEmail: true,
            ), // Email might be read-only depending on requirements, but user asked to edit.
            const SizedBox(height: 16),
            _buildTextField(
              _phoneCtrl,
              "Téléphone",
              Icons.phone,
              isPhone: true,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate:
                      DateTime.tryParse(_dateOfBirthCtrl.text) ??
                      DateTime.now().subtract(const Duration(days: 365 * 18)),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  locale: const Locale("fr", "FR"),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF567991),
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _dateOfBirthCtrl.text =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  });
                }
              },
              child: AbsorbPointer(
                child: _buildTextField(
                  _dateOfBirthCtrl,
                  "Date de naissance",
                  Icons.calendar_today,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(_addressCtrl, "Adresse", Icons.home, maxLines: 2),
          ]),
        ],
      ),
    );
  }

  Widget _buildMedicalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Informations Médicales"),
        _buildCard([
          _buildBloodTypeDropdown(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _heightCtrl,
                  "Taille (cm)",
                  Icons.height,
                  isNumeric: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  _weightCtrl,
                  "Poids (kg)",
                  Icons.monitor_weight,
                  isNumeric: true,
                ),
              ),
            ],
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
      ],
    );
  }

  Widget _buildSecuritySection(
    PatientAuthViewModel authVM,
    PatientProfileViewModel profileVM,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Sécurité"),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ExpansionTile(
              title: const Text(
                "Changer le mot de passe",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: const Icon(Icons.lock, color: Color(0xFF567991)),
              childrenPadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 8,
              ),
              children: [
                Form(
                  key: _passwordFormKey,
                  child: Column(
                    children: [
                      _buildPasswordTextField(
                        _oldPasswordCtrl,
                        "Ancien mot de passe",
                        _obscureOld,
                        () => setState(() => _obscureOld = !_obscureOld),
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordTextField(
                        _newPasswordCtrl,
                        "Nouveau mot de passe",
                        _obscureNew,
                        () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordTextField(
                        _confirmPasswordCtrl,
                        "Confirmer le mot de passe",
                        _obscureConfirm,
                        () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        validator: (value) {
                          if (value != _newPasswordCtrl.text) {
                            return "Les mots de passe ne correspondent pas";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF567991),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _changePassword(
                            authVM.authResponse?.token,
                            profileVM,
                          ),
                          child: profileVM.isLoading && _isChangingPassword
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Mettre à jour le mot de passe",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    PatientAuthViewModel authVM,
    PatientProfileViewModel profileVM,
  ) {
    return Row(
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
                ? () => _saveProfile(authVM.authResponse!.token!, profileVM)
                : null,
            child: const Text(
              "Enregistrer le Profil",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
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

<<<<<<< HEAD
=======
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumeric = false,
    bool isPhone = false,
    bool isEmail = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric
          ? TextInputType.number
          : (isPhone
                ? TextInputType.phone
                : (isEmail ? TextInputType.emailAddress : TextInputType.text)),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF86B7D7)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (isNumeric && value != null && value.isNotEmpty) {
          final val = double.tryParse(value);
          if (val == null || val <= 0) return "Entrez un nombre valide";
        }
        return null;
      },
    );
  }

  Widget _buildPasswordTextField(
    TextEditingController controller,
    String label,
    bool obscureText,
    VoidCallback onToggle, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF86B7D7)),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return "Ce champ est obligatoire";
            }
            return null;
          },
    );
  }

>>>>>>> 21b118e356682c0277daf70006db17122b794da3
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

<<<<<<< HEAD
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

=======
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
  void _saveProfile(String token, PatientProfileViewModel vm) async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = {
        'blood_type': _selectedBloodType,
        'allergies': _allergiesCtrl.text.trim(),
        'height': double.tryParse(_heightCtrl.text),
        'weight': double.tryParse(_weightCtrl.text),
        'emergency_contact': _emergencyContactCtrl.text.trim(),
        'emergency_phone': _emergencyPhoneCtrl.text.trim(),
<<<<<<< HEAD
=======
        'user': {
          'first_name': _firstNameCtrl.text.trim(),
          'last_name': _lastNameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'address': _addressCtrl.text.trim(),
          'date_of_birth': _dateOfBirthCtrl.text.trim(),
        },
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
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
<<<<<<< HEAD
=======

  void _changePassword(String? token, PatientProfileViewModel vm) async {
    if (token == null) return;
    if (_passwordFormKey.currentState!.validate()) {
      setState(() => _isChangingPassword = true);

      final success = await vm.changePassword(
        token,
        _oldPasswordCtrl.text,
        _newPasswordCtrl.text,
        _confirmPasswordCtrl.text,
      );

      setState(() => _isChangingPassword = false);

      if (success && mounted) {
        _oldPasswordCtrl.clear();
        _newPasswordCtrl.clear();
        _confirmPasswordCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mot de passe modifié avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              vm.error ?? "Erreur lors du changement de mot de passe",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
}
