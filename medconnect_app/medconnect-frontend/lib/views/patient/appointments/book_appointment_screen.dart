import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/patient_auth_view_model.dart';
import '../../../services/doctor_service.dart';
import '../../../view_models/patient/appointment_view_model.dart';
import '../../../models/doctor.dart';
<<<<<<< HEAD
=======
import '../doctor_detail_screen.dart';
>>>>>>> 21b118e356682c0277daf70006db17122b794da3

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({Key? key}) : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  int _currentStep = 0;

  // Selection state
  int? _selectedDoctorId;
  Doctor? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedTime;
  final TextEditingController _reasonController = TextEditingController();
<<<<<<< HEAD
=======
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
>>>>>>> 21b118e356682c0277daf70006db17122b794da3

  // Services
  final DoctorService _doctorService = DoctorService();

  // Data
  List<Doctor> _doctors = [];
  bool _isLoadingDoctors = false;

  List<String> _availableSlots = [];
  bool _isLoadingSlots = false;
  String? _slotError;

<<<<<<< HEAD
=======
  bool _isConfirming = false;

>>>>>>> 21b118e356682c0277daf70006db17122b794da3
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDoctors();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
<<<<<<< HEAD
    super.dispose();
  }

=======
    _searchController.dispose();
    super.dispose();
  }

  List<Doctor> get _filteredDoctors {
    return _doctors.where((doc) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          doc.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doc.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doc.speciality.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by availability and active status
      return matchesSearch && doc.isAvailable && doc.isActive;
    }).toList();
  }

>>>>>>> 21b118e356682c0277daf70006db17122b794da3
  Future<void> _fetchDoctors() async {
    setState(() => _isLoadingDoctors = true);
    try {
      final authViewModel = Provider.of<PatientAuthViewModel>(
        context,
        listen: false,
      );
      final token = authViewModel.authResponse?.token;
      if (token != null) {
        final doctors = await _doctorService.getDoctors(token);
        setState(() {
          _doctors = doctors;
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur chargement médecins: $e")),
        );
    } finally {
      if (mounted) setState(() => _isLoadingDoctors = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prendre Rendez-vous'),
        backgroundColor: const Color(0xFF567991),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepCancel: _prevStep,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
<<<<<<< HEAD
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF567991),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Suivant'),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
=======
                if (_isConfirming)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF567991),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_currentStep == 2 ? 'Confirmer' : 'Suivant'),
                  ),
                const SizedBox(width: 12),
                if (_currentStep > 0 && !_isConfirming)
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text(
                      'Retour',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Médecin'),
            content: _buildDoctorSelectionStep(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.editing,
          ),
          Step(
            title: const Text('Date'),
            content: _buildDateSelectionStep(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.editing,
          ),
          Step(
            title: const Text('Confirm'),
            content: _buildConfirmationStep(),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.editing,
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_selectedDoctorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez sélectionner un médecin")),
        );
        return;
      }
      setState(() => _currentStep += 1);
    } else if (_currentStep == 1) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Veuillez choisir une date et une heure"),
          ),
        );
        return;
      }
      setState(() => _currentStep += 1);
    } else if (_currentStep == 2) {
      _confirmAppointment();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Widget _buildDoctorSelectionStep() {
    if (_isLoadingDoctors) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_doctors.isEmpty) {
      return const Center(child: Text("Aucun médecin disponible."));
    }
    return Column(
      children: [
        const Text(
          "Sélectionnez un médecin dans la liste ci-dessous :",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _doctors.length,
          itemBuilder: (context, index) {
            final doc = _doctors[index];
            final isSelected = _selectedDoctorId == doc.id;
            return Card(
              color: isSelected
                  ? const Color(0xFF567991).withOpacity(0.1)
                  : Colors.white,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF567991),
                  child: Text(
                    doc.firstName.isNotEmpty ? doc.firstName[0] : 'D',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(doc.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.speciality, style: const TextStyle(color: Color(0xFF567991))),
                    if (doc.bio != null && doc.bio!.isNotEmpty)
                      Text(doc.bio!, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text("Tarif: ${doc.consultationFee.toStringAsFixed(0)} DH", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFF567991))
                    : null,
                onTap: () {
                  setState(() {
                    _selectedDoctorId = doc.id;
                    _selectedDoctor = doc;
                  });
                },
              ),
            );
          },
        ),
      ],
    );
  }


  Widget _buildDateSelectionStep() {
    return Column(
      children: [
        CalendarDatePicker(
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          onDateChanged: (date) {
            setState(() {
              _selectedDate = date;
              _selectedTime = null;
              _slotError = null;
            });
            _fetchSlots(date);
          },
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Horaires disponibles",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        if (_isLoadingSlots)
          const CircularProgressIndicator()
        else if (_selectedDate == null)
          const Text("Veuillez sélectionner une date sur le calendrier.")
        else if (_slotError != null)
          Text(_slotError!, style: const TextStyle(color: Colors.red))
        else if (_availableSlots.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Aucun créneau disponible pour cette date.\nVeuillez vérifier un autre jour.",
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            children: _availableSlots.map((slot) {
              final isSelected = _selectedTime == slot;
              return ChoiceChip(
                label: Text(slot),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedTime = selected ? slot : null);
                },
                selectedColor: const Color(0xFF567991),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    if (_selectedDoctor == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDoctor!.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text("${_selectedDate?.toIso8601String().split('T')[0]}"),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text("$_selectedTime"),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _reasonController,
          decoration: const InputDecoration(
            labelText: 'Motif de consultation',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.edit_note),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Future<void> _fetchSlots(DateTime date) async {
    if (_selectedDoctorId == null) return;

    setState(() {
      _isLoadingSlots = true;
      _slotError = null;
    });

    try {
      final authViewModel = Provider.of<PatientAuthViewModel>(
        context,
        listen: false,
      );
      final token = authViewModel.authResponse?.token;
      if (token != null) {
        final data = await _doctorService.getAvailability(
          token,
          _selectedDoctorId!,
          date,
        );
        final slots = List<String>.from(data['slots']);

        setState(() {
          _availableSlots = slots;
        });
      }
    } catch (e) {
      setState(() => _slotError = "Erreur de chargement.");
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      if (mounted) setState(() => _isLoadingSlots = false);
    }
  }

  Future<void> _confirmAppointment() async {
<<<<<<< HEAD
    // Vérification plus robuste
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Date non sélectionnée")),
      );
      return;
    }
    
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Heure non sélectionnée")),
      );
      return;
    }
    
    if (_selectedDoctorId == null || _selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Médecin non sélectionné")),
      );
      return;
    }

=======
    if (_isConfirming) return;

    // Vérification plus robuste
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Date non sélectionnée")));
      return;
    }

    if (_selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Heure non sélectionnée")));
      return;
    }

    if (_selectedDoctorId == null || _selectedDoctor == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Médecin non sélectionné")));
      return;
    }

    setState(() {
      _isConfirming = true;
    });

>>>>>>> 21b118e356682c0277daf70006db17122b794da3
    try {
      // Parse time avec validation
      final parts = _selectedTime!.split(':');
      if (parts.length != 2) {
        throw FormatException("Format d'heure invalide");
      }
<<<<<<< HEAD
      
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      
      if (hour == null || minute == null) {
        throw FormatException("Heure invalide");
      }
      
=======

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) {
        throw FormatException("Heure invalide");
      }

>>>>>>> 21b118e356682c0277daf70006db17122b794da3
      final dt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        hour,
        minute,
      );

<<<<<<< HEAD
      final viewModel = Provider.of<AppointmentViewModel>(context, listen: false);
=======
      final viewModel = Provider.of<AppointmentViewModel>(
        context,
        listen: false,
      );
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
      final authViewModel = Provider.of<PatientAuthViewModel>(
        context,
        listen: false,
      );
<<<<<<< HEAD
      
      final token = authViewModel.authResponse?.token;
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expirée, veuillez vous reconnecter")),
=======

      final token = authViewModel.authResponse?.token;
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Session expirée, veuillez vous reconnecter"),
          ),
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
        );
        return;
      }

      final success = await viewModel.bookAppointment(
        token,
        _selectedDoctorId!, // Assurez-vous que c'est un int
        dt,
<<<<<<< HEAD
        _reasonController.text.isNotEmpty ? _reasonController.text : "Consultation générale",
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rendez-vous confirmé !")),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${viewModel.error}")),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${e.toString()}")),
        );
=======
        _reasonController.text.isNotEmpty
            ? _reasonController.text
            : "Consultation générale",
      );

      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Rendez-vous confirmé !")));
        Navigator.pop(context);
      } else if (mounted) {
        // If it was just a duplicate submission caught late or something similar,
        // we might not want to show an error if it actually succeeded before.
        // But here we rely on viewModel returning false.
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur: ${viewModel.error}")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur: ${e.toString()}")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
      }
    }
  }
}
