import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart'; // For app-specific directories
import 'package:file_picker/file_picker.dart'; // Import FilePicker here
import '../models/note.dart'; // Import your custom model

class FileHelper {
  // 📤 Export Notes to JSON
  static Future<void> exportNotes(BuildContext context) async {
    // Request storage permission before proceeding
    bool permissionGranted = await Permission.storage.request().isGranted;

    if (permissionGranted) {
      // Permission granted, proceed with the export logic
      var noteBox = Hive.box<Note>('catatBarang');
      List<Map<String, dynamic>> noteData =
          noteBox.values.map((note) => note.toJson()).toList();
      String jsonData = jsonEncode(noteData);

      try {
        // For Android 10 and above, Scoped Storage
        Directory? directory = await getExternalFilesDir();
        if (directory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Gagal untuk mengakses external direktori")),
          );
          return;
        }

        // Ensure the directory exists
        Directory backupDir = Directory("${directory.path}/Backup");
        if (!await backupDir.exists()) {
          await backupDir.create();
        }

        String filePath =
            "${backupDir.path}/notes_backup_${DateTime.now().toIso8601String()}.json";
        File file = File(filePath);

        // Write JSON data to the file
        await file.writeAsString(jsonData);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ekspor berjaya: $filePath")),
        );
      } catch (e) {
        // Handle errors during export
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Ekspor gagal: $e")),
        );
      }
    } else {
      // Permission denied, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Diperlukan kebenaran untuk mengekspor!")),
      );
    }
  }

  // 📥 Import Notes from JSON
  static Future<void> importNotes(BuildContext context) async {
    try {
      // Pick a JSON file for import
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        // Read the selected JSON file
        File file = File(result.files.single.path!);
        String jsonData = await file.readAsString();

        // Validate the JSON data before proceeding
        if (jsonData.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Fil yang dipilih adalah kosong.")),
          );
          return;
        }

        List<dynamic> noteList = jsonDecode(jsonData);

        // Save notes to Hive
        var noteBox = Hive.box<Note>('catatBarang');
        for (var noteJson in noteList) {
          Note newNote = Note.fromJson(noteJson);
          await noteBox.put(newNote.id, newNote);
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berjaya mengimpor data!")),
        );
      } else {
        // User canceled the import
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impor dibatalkan.")),
        );
      }
    } catch (e) {
      // Handle errors during import
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal untuk mengimpor: $e")),
      );
    }
  }

  // For Scoped Storage: Get the external files directory (app-specific)
  static Future<Directory?> getExternalFilesDir() async {
    Directory? directory = await getExternalStorageDirectory();
    return directory;
  }
}
