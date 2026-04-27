import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medconnect_app/view_models/doctor_appointment_view_model.dart';
import 'package:medconnect_app/view_models/doctor_auth_view_model.dart';
import 'package:medconnect_app/models/appointment.dart';
import 'doctor_calendar_screen.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  Future<void> _loadAppointments() async {
    final authViewModel =
        Provider.of<DoctorAuthViewModel>(context, listen: false);
    final token = authViewModel.authResponse?.token;
    if (token != null) {
      await Provider.of<DoctorAppointmentViewModel>(context, listen: false)
          .fetchAppointments(token);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DoctorAppointmentViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        title: const Text('Gestion des Rendez-vous'),
        backgroundColor: const Color(0xFF567991),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Demandes'),
                  if (viewModel.allPendingAppointments.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${viewModel.allPendingAppointments.length}',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'À venir'),
            const Tab(text: 'Historique'),
          ],
        ),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Erreur: ${viewModel.error}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadAppointments,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAppointments,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPendingList(viewModel),
                      _buildAppointmentList(viewModel.upcomingAppointments),
                      _buildAppointmentList(viewModel.pastAppointments),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoctorCalendarScreen()),
          );
        },
        backgroundColor: const Color(0xFF567991),
        child: const Icon(Icons.calendar_month),
      ),
    );
  }

  /// Liste spéciale pour les demandes PENDING (actives + expirées avec badge)
  Widget _buildPendingList(DoctorAppointmentViewModel viewModel) {
    final appointments = viewModel.allPendingAppointments;
    if (appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Aucune demande en attente.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        final isExpired = appt.dateTime.isBefore(DateTime.now());
        return _buildPendingCard(appt, isExpired);
      },
    );
  }

  Widget _buildPendingCard(Appointment appt, bool isExpired) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: isExpired ? 0 : 2,
      color: isExpired ? Colors.grey.shade100 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête patient ─────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isExpired
                      ? Colors.grey.shade200
                      : const Color(0xFFE1F5FE),
                  child: Text(
                    appt.patientName.isNotEmpty
                        ? appt.patientName[0].toUpperCase()
                        : 'P',
                    style: TextStyle(
                      color: isExpired
                          ? Colors.grey
                          : const Color(0xFF0288D1),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appt.patientName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isExpired ? Colors.grey : Colors.black,
                        ),
                      ),
                      Text(
                        appt.reason ?? 'Motif non spécifié',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Badge "Expiré" pour les PENDING passés
                if (isExpired)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 12, color: Colors.red),
                        SizedBox(width: 4),
                        Text(
                          'Date dépassée',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'En attente',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // ── Date et heure ────────────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(appt.date.split('T')[0]),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                    '${appt.date.split('T')[1].substring(0, 5)} (${appt.duration} min)'),
              ],
            ),
            // ── Boutons action (seulement si pas expiré) ────────────────
            if (!isExpired) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _handleAction(context, appt, 'refuse'),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Refuser'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _handleAction(context, appt, 'accept'),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Accepter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF567991),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),
              const Text(
                'Ce rendez-vous ne peut plus être traité (date dépassée).',
                style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Aucun rendez-vous.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFE1F5FE),
                      child: Text(
                        appt.patientName.isNotEmpty
                            ? appt.patientName[0].toUpperCase()
                            : 'P',
                        style: const TextStyle(color: Color(0xFF0288D1)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appt.patientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            appt.reason ?? 'Motif non spécifié',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(appt.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(appt.date.split('T')[0]),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                        '${appt.date.split('T')[1].substring(0, 5)} (${appt.duration} min)'),
                  ],
                ),
                // Bouton annuler uniquement pour les RDV confirmés à venir
                if (appt.status == Appointment.statusConfirmed &&
                    appt.dateTime.isAfter(DateTime.now())) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () =>
                            _handleAction(context, appt, 'cancel'),
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text('Annuler'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    switch (status) {
      case Appointment.statusConfirmed:
        color = Colors.green;
        text = 'Confirmé';
        break;
      case Appointment.statusPending:
        color = Colors.orange;
        text = 'En attente';
        break;
      case Appointment.statusCancelled:
        color = Colors.red;
        text = 'Annulé';
        break;
      case Appointment.statusRefused:
        color = Colors.purple;
        text = 'Refusé';
        break;
      case Appointment.statusCompleted:
        color = Colors.blue;
        text = 'Terminé';
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Gestion des actions avec dialog de confirmation
  Future<void> _handleAction(
    BuildContext context,
    Appointment appt,
    String action,
  ) async {
    // ── Dialog de confirmation personnalisé selon l'action ────────────────
    if (action == 'refuse') {
      await _showRefuseDialog(context, appt);
      return;
    }

    final String title;
    final String message;
    final Color confirmColor;
    final String confirmText;

    if (action == 'accept') {
      title = 'Accepter le rendez-vous';
      message =
          'Confirmez-vous l\'acceptation du rendez-vous de ${appt.patientName} ?';
      confirmColor = const Color(0xFF567991);
      confirmText = 'Accepter';
    } else {
      title = 'Annuler le rendez-vous';
      message =
          'Voulez-vous annuler le rendez-vous de ${appt.patientName} ?\nLe patient sera notifié.';
      confirmColor = Colors.red;
      confirmText = 'Annuler le RDV';
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appt.patientName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(appt.reason ?? 'Motif non spécifié'),
                  Text(
                    '${appt.date.split('T')[0]} à ${appt.date.split('T')[1].substring(0, 5)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Non, retour'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(
              confirmText,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await _executeAction(context, appt, action);
  }

  /// Dialog spécial refus avec champ raison
  Future<void> _showRefuseDialog(BuildContext context, Appointment appt) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.block, color: Colors.red),
            SizedBox(width: 8),
            Text('Refuser le rendez-vous'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refuser le rendez-vous de ${appt.patientName} ?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appt.reason ?? 'Motif non spécifié'),
                  Text(
                    '${appt.date.split('T')[0]} à ${appt.date.split('T')[1].substring(0, 5)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Raison du refus (optionnel)',
                hintText: 'Ex: Agenda complet, hors spécialité...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message_outlined),
              ),
              maxLines: 3,
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Refuser',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    final refusalReason = reasonController.text.trim();
    reasonController.dispose();
    if (confirmed != true || !context.mounted) return;
    await _executeAction(
      context,
      appt,
      'refuse',
      refusalReason: refusalReason,
    );
  }

  Future<void> _executeAction(
    BuildContext context,
    Appointment appt,
    String action,
    {String? refusalReason}
  ) async {
    final viewModel =
        Provider.of<DoctorAppointmentViewModel>(context, listen: false);
    final authViewModel =
        Provider.of<DoctorAuthViewModel>(context, listen: false);
    final token = authViewModel.authResponse?.token;
    if (token == null) return;

    try {
      if (action == 'accept') {
        await viewModel.acceptAppointment(token, appt.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('RDV de ${appt.patientName} accepté ✓'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (action == 'refuse') {
        await viewModel.refuseAppointment(
          token,
          appt.id,
          reason: refusalReason,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('RDV de ${appt.patientName} refusé'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else if (action == 'cancel') {
        await viewModel.cancelAppointment(token, appt.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rendez-vous annulé'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }
}
