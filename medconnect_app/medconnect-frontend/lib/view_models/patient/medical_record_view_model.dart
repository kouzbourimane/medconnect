import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/medical_record_model.dart';
import '../../services/medical_record_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class MedicalRecordViewModel extends ChangeNotifier {
  final MedicalRecordService _service = MedicalRecordService();
  MedicalRecordModel? _record;
  bool _isLoading = false;
  String? _error;

  MedicalRecordModel? get record => _record;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMedicalRecord(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _record = await _service.getMedicalRecord(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> exportToPdf() async {
    if (_record == null) return;

    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Dossier Medical - MedConnect',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  pw.Text('Genere le: ${dateFormat.format(DateTime.now())}'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Section Patient
            pw.Header(level: 1, text: 'Informations Patient'),
            pw.Bullet(text: 'Nom: ${_record!.patientInfo.fullName}'),
            pw.Bullet(
              text:
                  'Groupe sanguin: ${_record!.patientInfo.bloodType ?? "Non spécifié"}',
            ),
            pw.Bullet(
              text: 'Allergies: ${_record!.patientInfo.allergies ?? "Aucune"}',
            ),
            pw.Bullet(
              text:
                  'Taille/Poids: ${_record!.patientInfo.height ?? "--"} cm / ${_record!.patientInfo.weight ?? "--"} kg',
            ),
            pw.SizedBox(height: 20),

            // Section Consultations
            pw.Header(level: 1, text: 'Historique des Consultations'),
            if (_record!.consultations.isEmpty)
              pw.Text('Aucune consultation enregistrée.'),
            ..._record!.consultations
                .map(
                  (c) => pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${dateFormat.format(DateTime.parse(c.date))} - Dr. ${c.doctorName} (${c.specialty})',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('Motif: ${c.reason ?? "N/A"}'),
                      if (c.notes != null) pw.Text('Notes: ${c.notes}'),
                      pw.Divider(),
                    ],
                  ),
                )
                .toList(),
            pw.SizedBox(height: 20),

            // Section Documents
            pw.Header(level: 1, text: 'Documents Médicaux'),
            if (_record!.documents.isEmpty)
              pw.Text('Aucun document disponible.'),
            ..._record!.documents
                .map((d) => pw.Text('- ${d.title} (${d.documentType})'))
                .toList(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'Dossier_Medical_${_record!.patientInfo.fullName.replaceAll(' ', '_')}.pdf',
    );
  }
}
