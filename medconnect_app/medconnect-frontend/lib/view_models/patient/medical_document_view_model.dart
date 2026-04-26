import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../models/medical_document_model.dart';
import '../../services/document_service.dart';

class MedicalDocumentViewModel with ChangeNotifier {
  final DocumentService _documentService = DocumentService();

  List<MedicalDocument> _allDocuments = [];
  List<MedicalDocument> _filteredDocuments = [];
  bool _isLoading = false;
  String? _error;
  String _currentFilter = 'Tous';

  List<MedicalDocument> get documents => _filteredDocuments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentFilter => _currentFilter;

  Future<void> fetchDocuments(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allDocuments = await _documentService.getDocuments(token);
      _applyFilter();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    if (_currentFilter == filter) return;
    _currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_currentFilter == 'Tous') {
      _filteredDocuments = List.from(_allDocuments);
    } else if (_currentFilter == 'Ordonnances') {
      _filteredDocuments = _allDocuments
          .where((doc) => doc.documentType == 'ORDONNANCE')
          .toList();
    } else if (_currentFilter == 'Analyses') {
      _filteredDocuments = _allDocuments
          .where((doc) => doc.documentType == 'ANALYSE')
          .toList();
    } else {
      _filteredDocuments = _allDocuments
          .where((doc) => doc.documentType == 'AUTRE')
          .toList();
    }
  }

  Future<void> uploadDocument({
    required String token,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
    required String title,
    required String documentType,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newDoc = await _documentService.uploadDocument(
        token: token,
        file: file,
        fileBytes: fileBytes,
        fileName: fileName,
        title: title,
        documentType: documentType,
        description: description,
      );
      _allDocuments.insert(0, newDoc);
      _applyFilter();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
