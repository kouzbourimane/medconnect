import 'package:flutter/material.dart';
import 'widgets/patient_login_form.dart';
import 'widgets/doctor_login_form.dart';

class CombinedLoginScreen extends StatefulWidget {
  const CombinedLoginScreen({Key? key}) : super(key: key);

  @override
  _CombinedLoginScreenState createState() => _CombinedLoginScreenState();
}

class _CombinedLoginScreenState extends State<CombinedLoginScreen> {
  // true = Patient, false = Doctor
  bool _isPatientSelected = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F9FC,
      ), // Very light blue/grey background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or Header
              const Icon(
                Icons.health_and_safety,
                size: 80,
                color: Color.fromARGB(255, 86, 121, 145),
              ),
              const SizedBox(height: 20),
              const Text(
                'MedConnect',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 40),

              // Main Card
              Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
      color: Color.fromARGB(255, 86, 121, 145), // Votre couleur médicale bleue
      width: 1.5, // Épaisseur de la bordure
    ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Toggle Switch
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 224, 234, 240),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            // Doctor Tab
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isPatientSelected = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !_isPatientSelected
                                        ? Color.fromARGB(255, 86, 121, 145)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: !_isPatientSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Médecin',
                                      style: TextStyle(
                                        color: !_isPatientSelected
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Patient Tab
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isPatientSelected = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isPatientSelected
                                        ? Color.fromARGB(255, 86, 121, 145)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: _isPatientSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Patient',
                                      style: TextStyle(
                                        color: _isPatientSelected
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Animated Switcher for Form Content
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isPatientSelected
                            ? const PatientLoginForm(
                                key: ValueKey('PatientForm'),
                              )
                            : const DoctorLoginForm(
                                key: ValueKey('DoctorForm'),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
