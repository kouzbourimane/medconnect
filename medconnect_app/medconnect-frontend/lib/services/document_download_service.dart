import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';

class DocumentDownloadService {
  final Dio _dio = Dio();

  Future<void> downloadFile(
    BuildContext context,
    String url,
    String fileName,
  ) async {
    try {
      if (await _requestPermission(Permission.storage)) {
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
    } else {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) {
          throw Exception("Impossible de trouver le dossier de stockage");
        }

        final String savePath = '${directory.path}/$fileName';
        _showSnackBar(context, "Téléchargement en cours...", isError: false);

        await _dio.download(
          url,
          savePath,
          onReceiveProgress: (received, total) {
            // Optional: Show progress via a stream or callback if needed
          },
        );

        _showSnackBar(context, "Téléchargement terminé", isError: false);

        // Open the file
        final result = await OpenFile.open(savePath);
        if (result.type != ResultType.done) {
          _showSnackBar(
            context,
            "Impossible d'ouvrir le fichier: ${result.message}",
          );
        }
      } else {
        _showSnackBar(context, "Permission de stockage refusée");
      }
    } catch (e) {
      _showSnackBar(context, "Erreur de téléchargement: $e");
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return true;
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
