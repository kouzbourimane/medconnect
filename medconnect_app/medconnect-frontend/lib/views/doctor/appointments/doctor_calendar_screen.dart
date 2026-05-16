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

class _DoctorCalendarScreenState extends State<DoctorCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    final viewModel = Provider.of<DoctorAppointmentViewModel>(context, listen: false);
    return viewModel.appointments.where((appointment) {
      return appointment.dateTime.year == day.year &&
             appointment.dateTime.month == day.month &&
             appointment.dateTime.day == day.day &&
             appointment.status != Appointment.statusCancelled;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
        backgroundColor: const Color(0xFF388E3C),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildDaysOfWeek(),
          _buildCalendarGrid(),
          const Divider(),
          Expanded(child: _buildAppointmentList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
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
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDaysOfWeek() {
    final days = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) => Text(day, style: const TextStyle(fontWeight: FontWeight.bold))).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun
    
    // Calculate total slots needed (padding for start + days)
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
        final isSelected = _selectedDay != null && isSameDay(_selectedDay!, date);
        final appointments = _getAppointmentsForDay(date);

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF388E3C) : null,
              shape: BoxShape.circle,
              border: isToday(date) && !isSelected ? Border.all(color: const Color(0xFF388E3C)) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                if (appointments.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
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

  Widget _buildAppointmentList() {
    if (_selectedDay == null) return const SizedBox.shrink();
    
    final appointments = _getAppointmentsForDay(_selectedDay!);
    
    if (appointments.isEmpty) {
      return Center(
        child: Text(
          'Aucun rendez-vous pour le ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        return ListTile(
          leading: Icon(Icons.access_time, color: Theme.of(context).primaryColor),
          title: Text(appt.patientName),
          subtitle: Text('${appt.date.split('T')[1].substring(0, 5)} (${appt.duration} min) - ${appt.statusLabel}'),
        );
      },
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }
}
