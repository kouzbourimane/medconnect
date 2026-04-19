import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/register_request.dart';
import '../../view_models/auth_view_model.dart';
import 'combined_login_screen.dart';

class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
<<<<<<< HEAD
=======
  final _addressController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  DateTime? _selectedDateOfBirth;
>>>>>>> 21b118e356682c0277daf70006db17122b794da3

  String? _selectedBloodType;
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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    // Medical Blue Palette
    const primaryColor = Color.fromARGB(255, 86, 121, 145);
    const lightBackground = Color.fromARGB(255, 213, 231, 243);

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        title: const Text('Inscription Patient'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Créer un compte',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Section: Informations de Compte
                      _buildSectionHeader(
                        'Informations de Compte',
                        primaryColor,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        decoration: _buildInputDecoration(
                          'Nom d\'utilisateur*',
                          Icons.person,
                          primaryColor,
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Requis' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: _buildInputDecoration(
                          'Email*',
                          Icons.email,
                          primaryColor,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Requis';
                          if (!value.contains('@')) return 'Email invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration:
                            _buildInputDecoration(
                              'Mot de passe*',
                              Icons.lock,
                              primaryColor,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: primaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                        obscureText: _obscurePassword,
                        validator: (value) =>
                            (value == null || value.length < 6)
                            ? 'Min 6 caractères'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration:
                            _buildInputDecoration(
                              'Confirmer mot de passe*',
                              Icons.lock_outline,
                              primaryColor,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: primaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Requis';
                          if (value != _passwordController.text)
                            return 'Les mots de passe ne correspondent pas';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Section: Informations Personnelles
                      _buildSectionHeader(
                        'Informations Personnelles',
                        primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: _buildInputDecoration(
                                'Prénom',
                                Icons.person_outline,
                                primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: _buildInputDecoration(
                                'Nom',
                                Icons.person_outline,
                                primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        decoration: _buildInputDecoration(
                          'Téléphone',
                          Icons.phone,
                          primaryColor,
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
<<<<<<< HEAD
=======
                      TextFormField(
                        controller: _addressController,
                        decoration: _buildInputDecoration(
                          'Adresse',
                          Icons.home,
                          primaryColor,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate:
                                _selectedDateOfBirth ??
                                DateTime.now().subtract(
                                  const Duration(days: 365 * 18),
                                ),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            locale: const Locale("fr", "FR"),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: primaryColor,
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
                              _selectedDateOfBirth = picked;
                              _dateOfBirthController.text =
                                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: _dateOfBirthController,
                            decoration: _buildInputDecoration(
                              'Date de naissance',
                              Icons.calendar_today,
                              primaryColor,
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Requis'
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
                      DropdownButtonFormField<String>(
                        value: _selectedBloodType,
                        decoration: _buildInputDecoration(
                          'Groupe sanguin',
                          Icons.bloodtype,
                          primaryColor,
                        ),
                        items: _bloodTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedBloodType = value),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _allergiesController,
                        decoration: _buildInputDecoration(
                          'Allergies',
                          Icons.warning_amber,
                          primaryColor,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      // Section: Urgence
                      _buildSectionHeader('Contact d\'urgence', primaryColor),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emergencyContactController,
                        decoration: _buildInputDecoration(
                          'Nom du contact',
                          Icons.contact_emergency,
                          primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emergencyPhoneController,
                        decoration: _buildInputDecoration(
                          'Téléphone urgence',
                          Icons.phone_in_talk,
                          primaryColor,
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 32),

                      if (authViewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            authViewModel.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      authViewModel.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final request = RegisterRequest(
                                    username: _usernameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    first_name:
                                        _firstNameController.text.isEmpty
                                        ? null
                                        : _firstNameController.text,
                                    last_name: _lastNameController.text.isEmpty
                                        ? null
                                        : _lastNameController.text,
                                    phone: _phoneController.text.isEmpty
                                        ? null
                                        : _phoneController.text,
                                    role: "PATIENT",
                                    blood_type: _selectedBloodType,
                                    allergies: _allergiesController.text.isEmpty
                                        ? null
                                        : _allergiesController.text,
                                    emergency_contact:
                                        _emergencyContactController.text.isEmpty
                                        ? null
                                        : _emergencyContactController.text,
                                    emergency_phone:
                                        _emergencyPhoneController.text.isEmpty
                                        ? null
                                        : _emergencyPhoneController.text,
<<<<<<< HEAD
=======
                                    address: _addressController.text.isEmpty
                                        ? null
                                        : _addressController.text,
                                    dateOfBirth:
                                        _dateOfBirthController.text.isEmpty
                                        ? null
                                        : _dateOfBirthController.text,
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
                                  );

                                  final success = await authViewModel
                                      .registerPatient(request);

                                  if (success && mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CombinedLoginScreen(),
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Inscription réussie ! Veuillez vous connecter.',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                "S'INSCRIRE",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Déjà un compte ? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CombinedLoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Se connecter",
                              style: TextStyle(
                                color: Color.fromARGB(255, 86, 121, 145),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon,
    Color color,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: color),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: const Color(
        0xFFF5F9FC,
      ), // Very light blue/grey for input background
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.0,
          ),
        ),
        Divider(color: color.withOpacity(0.5), thickness: 1),
      ],
    );
  }
}
