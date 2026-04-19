import 'package:flutter/material.dart';
import '../../../models/doctor_schedule.dart';

class ScheduleEditor extends StatefulWidget {
  final DoctorSchedule schedule;
  final ValueChanged<DoctorSchedule> onSave;

  const ScheduleEditor({
    Key? key,
    required this.schedule,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ScheduleEditor> createState() => _ScheduleEditorState();
}

class _ScheduleEditorState extends State<ScheduleEditor> {
  late int _slotDuration;
  late Map<int, List<TimeRange>> _workingHours;

  @override
  void initState() {
    super.initState();
    _slotDuration = widget.schedule.slotDurationMinutes;
    _workingHours = Map.from(widget.schedule.workingHours);
  }

  void _addRange(int day) {
    setState(() {
      if (!_workingHours.containsKey(day)) {
        _workingHours[day] = [];
      }
      _workingHours[day]!.add(TimeRange(
        start: const TimeOfDay(hour: 9, minute: 0),
        end: const TimeOfDay(hour: 17, minute: 0),
      ));
    });
  }

  void _removeRange(int day, int index) {
    setState(() {
      _workingHours[day]!.removeAt(index);
      if (_workingHours[day]!.isEmpty) {
        _workingHours.remove(day);
      }
    });
  }

  void _updateRange(int day, int index, TimeRange newRange) {
    setState(() {
      _workingHours[day]![index] = newRange;
    });
  }

  Future<void> _pickTime(
      int day, int index, bool isStart, TimeRange current) async {
    final initial = isStart ? current.start : current.end;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) { // Force 24h format for clarity
         return MediaQuery(
           data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
           child: child!,
         );
      }
    );

    if (picked != null) {
      final newRange = TimeRange(
        start: isStart ? picked : current.start,
        end: isStart ? current.end : picked,
      );
      _updateRange(day, index, newRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text("Durée des créneaux (min): "),
              DropdownButton<int>(
                value: _slotDuration,
                items: [15, 30, 45, 60].map((e) {
                  return DropdownMenuItem(value: e, child: Text("$e min"));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _slotDuration = val);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = index + 1; // 1 = Monday
              final ranges = _workingHours[day] ?? [];
              final dayName = _getDayName(day);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dayName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Color(0xFF567991)),
                            onPressed: () => _addRange(day),
                          ),
                        ],
                      ),
                      if (ranges.isEmpty)
                        const Text("Non travaillé",
                            style: TextStyle(color: Colors.grey)),
                      ...ranges.asMap().entries.map((entry) {
                        final i = entry.key;
                        final range = entry.value;
                        return Row(
                          children: [
                            TextButton(
                              onPressed: () => _pickTime(day, i, true, range),
                              child: Text(range.start.format(context)),
                            ),
                            const Text("-"),
                            TextButton(
                              onPressed: () => _pickTime(day, i, false, range),
                              child: Text(range.end.format(context)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeRange(day, i),
                            )
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF567991),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              widget.onSave(DoctorSchedule(
                slotDurationMinutes: _slotDuration,
                workingHours: _workingHours,
              ));
            },
            child: const Text("Sauvegarder les horaires"),
          ),
        ),
      ],
    );
  }

  String _getDayName(int day) {
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];
    return days[day - 1];
  }
}
