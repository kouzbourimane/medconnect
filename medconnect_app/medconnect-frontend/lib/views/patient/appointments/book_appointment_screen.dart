import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/patient_auth_view_model.dart';
import '../../../services/doctor_service.dart';
import '../../../view_models/patient/appointment_view_model.dart';
import '../../../models/doctor.dart';

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

  // Filtre médecins
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSpecialty = 'Toutes';

  // Services
  final DoctorService _doctorService = DoctorService();

  // Data
  List<Doctor> _doctors = [];
  bool _isLoadingDoctors = false;

  List<String> _availableSlots = [];
  bool _isLoadingSlots = false;
  String? _slotError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDoctors();
    });
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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

  /// Retourne la liste des spécialités uniques
  List<String> get _specialties {
    final Set<String> s = {'Toutes'};
    for (final d in _doctors) {
      s.add(d.speciality);
    }
    return s.toList()..sort();
  }

  /// Filtre les médecins selon la recherche et la spécialité
  List<Doctor> get _filteredDoctors {
    return _doctors.where((doc) {
      final matchSearch = _searchQuery.isEmpty ||
          doc.fullName.toLowerCase().contains(_searchQuery) ||
          doc.speciality.toLowerCase().contains(_searchQuery);
      final matchSpec =
          _selectedSpecialty == 'Toutes' || doc.speciality == _selectedSpecialty;
      return matchSearch && matchSpec;
    }).toList();
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
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF567991),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_currentStep == 2 ? 'Confirmer' : 'Suivant'),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
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
            title: const Text('Confirm.'),
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
      // Dialog de confirmation avant de créer le RDV
      _showConfirmationDialog();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Future<void> _showConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.event_available, color: Color(0xFF567991)),
            SizedBox(width: 8),
            Text('Confirmer le rendez-vous'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Voulez-vous confirmer ce rendez-vous ?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF567991).withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF567991).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryRow(Icons.person, _selectedDoctor!.fullName),
                  _summaryRow(Icons.medical_information, _selectedDoctor!.speciality),
                  _summaryRow(
                    Icons.calendar_today,
                    _selectedDate?.toIso8601String().split('T')[0] ?? '',
                  ),
                  _summaryRow(Icons.access_time, _selectedTime ?? ''),
                  if (_reasonController.text.isNotEmpty)
                    _summaryRow(Icons.edit_note, _reasonController.text),
                  _summaryRow(
                    Icons.payments,
                    '${_selectedDoctor!.consultationFee.toStringAsFixed(0)} DH',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF567991),
            ),
            child: const Text(
              'Confirmer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _confirmAppointment();
    }
  }

  Widget _summaryRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF567991)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorSelectionStep() {
    if (_isLoadingDoctors) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_doctors.isEmpty) {
      return const Center(child: Text("Aucun médecin disponible."));
    }

    final filtered = _filteredDoctors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Barre de recherche ──────────────────────────────
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher par nom ou spécialité...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
        const SizedBox(height: 10),
        // ── Filtre par spécialité ───────────────────────────
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _specialties.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final spec = _specialties[i];
              final isSelected = _selectedSpecialty == spec;
              return ChoiceChip(
                label: Text(spec, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                selectedColor: const Color(0xFF567991),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (_) {
                  setState(() => _selectedSpecialty = spec);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // ── Résultats ────────────────────────────────────────
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text("Aucun médecin ne correspond à votre recherche.")),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final doc = filtered[index];
              final isSelected = _selectedDoctorId == doc.id;
              return Card(
                color: isSelected
                    ? const Color(0xFF567991).withOpacity(0.08)
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: isSelected
                      ? const BorderSide(color: Color(0xFF567991), width: 1.5)
                      : BorderSide.none,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF567991),
                    child: Text(
                      doc.firstName.isNotEmpty ? doc.firstName[0] : 'D',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    doc.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.speciality,
                        style: const TextStyle(color: Color(0xFF567991)),
                      ),
                      if (doc.bio != null && doc.bio!.isNotEmpty)
                        Text(
                          doc.bio!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      Text(
                        "Tarif: ${doc.consultationFee.toStringAsFixed(0)} DH",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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
          // UX : 90 jours au lieu de 30
          lastDate: DateTime.now().add(const Duration(days: 90)),
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
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _slotError!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],
            ),
          )
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _summaryRow(Icons.person, _selectedDoctor!.fullName),
                const Divider(),
                _summaryRow(Icons.medical_information, _selectedDoctor!.speciality),
                const Divider(),
                _summaryRow(
                  Icons.calendar_today,
                  "${_selectedDate?.toIso8601String().split('T')[0]}",
                ),
                const Divider(),
                _summaryRow(Icons.access_time, "$_selectedTime"),
                const Divider(),
                _summaryRow(
                  Icons.payments,
                  "${_selectedDoctor!.consultationFee.toStringAsFixed(0)} DH",
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _reasonController,
          decoration: const InputDecoration(
            labelText: 'Motif de consultation (optionnel)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.edit_note),
            hintText: 'Ex: Douleur abdominale, suivi...',
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
      // Afficher l'erreur réelle (ex: médecin sans horaires configurés)
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      setState(() => _slotError = errorMsg.isNotEmpty
          ? errorMsg
          : "Erreur de chargement des créneaux. Ce médecin n'a peut-être pas configuré ses horaires.");
    } finally {
      if (mounted) setState(() => _isLoadingSlots = false);
    }
  }

  Future<void> _confirmAppointment() async {
    if (_selectedDate == null || _selectedTime == null || _selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informations manquantes")),
      );
      return;
    }

    try {
      final parts = _selectedTime!.split(':');
      if (parts.length != 2) throw FormatException("Format d'heure invalide");
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) throw FormatException("Heure invalide");

      final dt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        hour,
        minute,
      );

      final viewModel = Provider.of<AppointmentViewModel>(context, listen: false);
      final authViewModel = Provider.of<PatientAuthViewModel>(context, listen: false);
      final token = authViewModel.authResponse?.token;

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expirée, veuillez vous reconnecter")),
        );
        return;
      }

      // Indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final success = await viewModel.bookAppointment(
        token,
        _selectedDoctorId!,
        dt,
        _reasonController.text.isNotEmpty
            ? _reasonController.text
            : "Consultation générale",
      );

      if (!mounted) return;
      Navigator.pop(context); // Fermer le loader

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Rendez-vous demandé avec succès ! En attente de confirmation du médecin."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${viewModel.error}")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${e.toString()}")),
        );
      }
    }
  }
}
