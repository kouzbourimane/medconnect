import 'package:flutter/material.dart';
import '../../../../models/medical_document_model.dart';
import 'package:intl/intl.dart';

class DocumentTypeBadge extends StatelessWidget {
  final String type;

  const DocumentTypeBadge({Key? key, required this.type}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (type) {
      case 'ORDONNANCE':
        color = const Color(0xFF388E3C);
        icon = Icons.description;
        label = 'Ordonnance';
        break;
      case 'ANALYSE':
        color = const Color(0xFF66BB6A);
        icon = Icons.science;
        label = 'Analyse';
        break;
      default:
        color = Colors.grey;
        icon = Icons.insert_drive_file;
        label = 'Autre';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentCard extends StatelessWidget {
  final MedicalDocument document;
  final VoidCallback onView;
  final VoidCallback onDownload;

  const DocumentCard({
    Key? key,
    required this.document,
    required this.onView,
    required this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(document.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            document.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (document.uploadedBy == 'PATIENT')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF81C784).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Vous',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF388E3C),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    if (document.doctorName != null)
                      Text(
                        'Dr. ${document.doctorName}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF388E3C),
                        ),
                      ),
                    const SizedBox(height: 8),
                    DocumentTypeBadge(type: document.documentType),
                  ],
                ),
              ),
              const VerticalDivider(width: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData icon;
    Color color;

    switch (document.documentType) {
      case 'ORDONNANCE':
        icon = Icons.description_outlined;
        color = const Color(0xFF388E3C);
        break;
      case 'ANALYSE':
        icon = Icons.science_outlined;
        color = const Color(0xFF66BB6A);
        break;
      default:
        icon = Icons.insert_drive_file_outlined;
        color = Colors.grey;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  Widget _buildActions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.remove_red_eye_outlined,
            color: Color(0xFF388E3C),
          ),
          onPressed: onView,
          tooltip: 'Voir',
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
        ),
        IconButton(
          icon: const Icon(Icons.download_outlined, color: Color(0xFF388E3C)),
          onPressed: onDownload,
          tooltip: 'Télécharger',
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
        ),
      ],
    );
  }
}
