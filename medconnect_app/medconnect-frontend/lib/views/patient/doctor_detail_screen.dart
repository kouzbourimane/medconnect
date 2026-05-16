import 'package:flutter/material.dart';
import '../../models/doctor.dart';

class DoctorDetailScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: Text(doctor.fullName),
        backgroundColor: const Color(0xFF388E3C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF388E3C),
                child: Text(
                  doctor.firstName.isNotEmpty ? doctor.firstName[0] : 'D',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                doctor.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
            Center(
              child: Text(
                doctor.speciality,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF388E3C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 30),
            _buildInfoCard(
              title: "À propos",
              content: doctor.bio != null && doctor.bio!.isNotEmpty
                  ? doctor.bio!
                  : "Aucune description disponible.",
              icon: Icons.info_outline,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: "Tarif consultation",
              content: "${doctor.consultationFee.toStringAsFixed(0)} MAD",
              icon: Icons.attach_money,
              isPrice: true,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: "Contact",
              content: doctor.phone,
              icon: Icons.phone,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: "Statut",
              content: doctor.isAvailable ? "Disponible" : "Indisponible",
              icon: doctor.isAvailable ? Icons.check_circle : Icons.cancel,
              contentColor: doctor.isAvailable ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    bool isPrice = false,
    Color? contentColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF388E3C), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
                      color: contentColor ?? Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
