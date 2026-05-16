import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth_view_model.dart';
import 'combined_login_screen.dart';

class RegisterDoctorScreen extends StatefulWidget {
  const RegisterDoctorScreen({super.key});

  @override
  State<RegisterDoctorScreen> createState() => _RegisterDoctorScreenState();
}

class _RegisterDoctorScreenState extends State<RegisterDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _specialityController = TextEditingController();
  final _cityController = TextEditingController();
  final _locationController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    // Medical Green Palette
    const primaryColor = Color(0xFF388E3C);
    const lightBackground = Color(0xFFC8E6C9);

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        title: const Text('Inscription Médecin'),
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
                        'Créer un compte Médecin',
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
                          'Email Professionnel*',
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
                      const SizedBox(height: 24),

                      // Section: Informations Professionnelles
                      _buildSectionHeader(
                        'Informations Professionnelles',
                        primaryColor,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _licenseNumberController,
                        decoration: _buildInputDecoration(
                          'Numéro de Licence*',
                          Icons.badge,
                          primaryColor,
                        ),
                         validator: (value) =>
                            value == null || value.isEmpty ? 'Requis' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _specialityController,
                        decoration: _buildInputDecoration(
                          'Spécialité',
                          Icons.local_hospital,
                          primaryColor,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Section: Localisation
                      _buildSectionHeader(
                        'Localisation',
                        primaryColor,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _cityController,
                        decoration: _buildInputDecoration(
                          'Ville',
                          Icons.location_city,
                          primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                       TextFormField(
                        controller: _locationController,
                        decoration: _buildInputDecoration(
                          'Adresse / Localisation',
                          Icons.map,
                          primaryColor,
                        ),
                         maxLines: 2,
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
                             final payload = {
                                'username': _usernameController.text,
                                'email': _emailController.text,
                                'password': _passwordController.text,
                                'first_name': _firstNameController.text,
                                'last_name': _lastNameController.text,
                                'phone': _phoneController.text,
                                'license_number': _licenseNumberController.text,
                                'specialty': _specialityController.text,
                                'city': _cityController.text,
                                'location': _locationController.text,
                             };

                             final success = await authViewModel.registerDoctor(payload);

                             if (success && mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(
                                   content: Text('Compte médecin créé avec succès'),
                                   backgroundColor: Colors.green,
                                 ),
                               );
                               Navigator.pushReplacement(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => const CombinedLoginScreen(),
                                 ),
                               );
                             } else if (mounted) {
                                // Error is displayed via viewModel.errorMessage above or generic snackbar
                                // User asked for red snackbar with backend message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(authViewModel.errorMessage ?? 'Erreur inconnue'),
                                    backgroundColor: Colors.red,
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
                                color: Color(0xFF388E3C),
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
        0xFFF1F8E9,
      ), // Very light green/grey for input background
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
