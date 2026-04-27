import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:medconnect_app/view_models/doctor_appointment_view_model.dart';
import 'package:medconnect_app/models/appointment.dart';

class DoctorCalendarScreen extends StatefulWidget {
  const DoctorCalendarScreen({Key? key}) : super(key: key);

  @override
  State<DoctorCalendarScreen> createState() => _DoctorCalendarScreenState();
}

class _DoctorCalendarScreenState extends State<DoctorCalendarScreen>
    with SingleTickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late TabController _viewTabController;

  @override
  void initState() {
    super.initState();
    _viewTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _viewTabController.dispose();
    super.dispose();
  }

  List<Appointment> _getAppointmentsForDay(
    DateTime day,
    List<Appointment> appointments,
  ) {
    return appointments.where((a) {
      return a.dateTime.year == day.year &&
          a.dateTime.month == day.month &&
          a.dateTime.day == day.day &&
          a.status != Appointment.statusCancelled &&
          a.status != Appointment.statusRefused;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  @override
  Widget build(BuildContext context) {
    // Consumer pour que le calendrier se reconstruise quand les données chargent
    return Consumer<DoctorAppointmentViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Calendrier'),
            backgroundColor: const Color(0xFF567991),
            bottom: TabBar(
              controller: _viewTabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              tabs: const [
                Tab(icon: Icon(Icons.grid_view), text: 'Mois'),
                Tab(icon: Icon(Icons.view_agenda), text: 'Agenda'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _viewTabController,
            children: [
              _buildMonthView(viewModel),
              _buildAgendaView(viewModel),
            ],
          ),
        );
      },
    );
  }

  // ─── VUE MENSUELLE ─────────────────────────────────────────────────────────

  Widget _buildMonthView(DoctorAppointmentViewModel viewModel) {
    return Column(
      children: [
        _buildHeader(),
        _buildDaysOfWeek(),
        _buildCalendarGrid(viewModel),
        const Divider(height: 1),
        Expanded(
          child: _buildDayAppointmentList(
            _getAppointmentsForDay(_selectedDay, viewModel.appointments),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay =
                    DateTime(_focusedDay.year, _focusedDay.month - 1);
              });
            },
          ),
          Text(
            DateFormat.yMMMM('fr_FR').format(_focusedDay).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDay =
                    DateTime(_focusedDay.year, _focusedDay.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    final days = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days
            .map(
              (day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(DoctorAppointmentViewModel viewModel) {
    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday; // 1=Lun, 7=Dim
    final int totalSlots = daysInMonth + (firstWeekday - 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: totalSlots,
      itemBuilder: (context, index) {
        if (index < firstWeekday - 1) {
          return const SizedBox.shrink();
        }
        final day = index - (firstWeekday - 1) + 1;
        final date = DateTime(_focusedDay.year, _focusedDay.month, day);
        final isSelected = _isSameDay(_selectedDay, date);
        final isToday = _isSameDay(DateTime.now(), date);
        // Utiliser les données du viewModel passé en paramètre (listen: true via Consumer)
        final dayAppointments =
            _getAppointmentsForDay(date, viewModel.appointments);
        final hasAppointments = dayAppointments.isNotEmpty;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = date;
              _focusedDay = DateTime(date.year, date.month);
            });
          },
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF567991) : null,
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(color: const Color(0xFF567991), width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                if (hasAppointments)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayAppointmentList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_available, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Aucun RDV le ${DateFormat('EEEE dd MMMM', 'fr_FR').format(_selectedDay)}',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '${appointments.length} RDV — ${DateFormat('EEEE dd MMMM', 'fr_FR').format(_selectedDay)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF567991),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appt = appointments[index];
              return _buildAgendaCard(appt);
            },
          ),
        ),
      ],
    );
  }

  // ─── VUE AGENDA ────────────────────────────────────────────────────────────

  Widget _buildAgendaView(DoctorAppointmentViewModel viewModel) {
    // Regrouper les RDV des 30 prochains jours par date
    final now = DateTime.now();
    final until = now.add(const Duration(days: 30));
    final upcoming = viewModel.appointments
        .where(
          (a) =>
              a.dateTime.isAfter(now.subtract(const Duration(days: 1))) &&
              a.dateTime.isBefore(until) &&
              a.status != Appointment.statusCancelled &&
              a.status != Appointment.statusRefused,
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    if (upcoming.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Aucun rendez-vous à venir\ndans les 30 prochains jours.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Grouper par jour
    final Map<String, List<Appointment>> byDay = {};
    for (final appt in upcoming) {
      final key = DateFormat('yyyy-MM-dd').format(appt.dateTime);
      byDay.putIfAbsent(key, () => []).add(appt);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: byDay.length,
      itemBuilder: (context, index) {
        final dateKey = byDay.keys.elementAt(index);
        final dayAppts = byDay[dateKey]!;
        final date = DateTime.parse(dateKey);
        final isToday = _isSameDay(date, DateTime.now());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── En-tête du jour ──────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(bottom: 8, top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isToday
                    ? const Color(0xFF567991)
                    : const Color(0xFF567991).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isToday
                    ? "Aujourd'hui — ${DateFormat('dd MMMM', 'fr_FR').format(date)}"
                    : DateFormat('EEEE dd MMMM', 'fr_FR').format(date),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isToday ? Colors.white : const Color(0xFF567991),
                  fontSize: 13,
                ),
              ),
            ),
            // ── RDV de ce jour ──────────────────────────────────────
            ...dayAppts.map((appt) => _buildAgendaCard(appt)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildAgendaCard(Appointment appt) {
    final timeStr = appt.date.split('T')[1].substring(0, 5);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Bande colorée à gauche
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: appt.status == Appointment.statusConfirmed
                    ? Colors.green
                    : Colors.orange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    // Heure + durée
                    SizedBox(
                      width: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF567991),
                            ),
                          ),
                          Text(
                            '${appt.duration}min',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 20),
                    // Infos patient
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            appt.patientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (appt.reason != null && appt.reason!.isNotEmpty)
                            Text(
                              appt.reason!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    // Statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: appt.status == Appointment.statusConfirmed
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        appt.status == Appointment.statusConfirmed
                            ? 'Confirmé'
                            : 'En attente',
                        style: TextStyle(
                          color: appt.status == Appointment.statusConfirmed
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
