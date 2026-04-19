import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart'; // Optional for preview
import '../models/medical_document_model.dart';
import '../repositories/medical_document_repository.dart';

class DoctorMedicalDocumentViewModel extends ChangeNotifier {
  final MedicalDocumentRepository _repository = MedicalDocumentRepository();
  List<MedicalDocument> _documents = [];
  bool _isLoading = false;
  String? _error;

  List<MedicalDocument> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDocuments(String token, int patientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _documents = await _repository.getDocumentsByPatient(token, patientId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadDocument({
    required String token,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
    required String title,
    required String type,
    required int patientId,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newDoc = await _repository.uploadDocument(
        token: token,
        file: file,
        fileBytes: fileBytes,
        fileName: fileName,
        title: title,
        type: type,
        patientId: patientId,
        description: description,
      );
      _documents.insert(0, newDoc);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> generateAndUploadPrescription({
    required String token,
    required int patientId,
    required String patientName,
    required String doctorName,
    required List<String> medicines,
    required String instructions,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Generate PDF
      final pdf = pw.Document();
      final dateStr = DateTime.now().toString().split(' ')[0];

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('MedConnect - Ordonnance', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text(dateStr),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Dr. $doctorName', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text('Patient: $patientName', style: pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 20),
                pw.Text('Prescription:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                ...medicines.map((m) => pw.Bullet(text: m, style: const pw.TextStyle(fontSize: 14))),
                pw.SizedBox(height: 20),
                pw.Text('Instructions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(instructions),
                pw.SizedBox(height: 40),
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Text('Signature: ____________________'),
                ),
              ],
            );
          },
        ),
      );

      // 2. Get bytes directly (no file save needed for upload)
      final bytes = await pdf.save();

      // 3. Upload
      final success = await uploadDocument(
        token: token,
        fileBytes: bytes,
        fileName: "ordonnance_${DateTime.now().millisecondsSinceEpoch}.pdf",
        title: "Ordonnance - $dateStr",
        type: "ORDONNANCE",
        patientId: patientId,
        description: "Générée automatiquement par MedConnect",
      );
      
      return success;

    } catch (e) {
      _error = "Erreur generation PDF: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
