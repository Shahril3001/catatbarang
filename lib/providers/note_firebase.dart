import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/note.dart';

class FirebaseHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String collectionName = "catatBarang";

  /// **Export Notes from Hive to Firebase**
  static Future<void> exportNotesToFirebase(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from closing the dialog
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      var noteBox = await Hive.openBox<Note>('catatBarang');
      var batch = _firestore.batch();

      for (var note in noteBox.values) {
        var docRef = _firestore.collection(collectionName).doc(note.id);
        batch.set(docRef, note.toJson());
      }

      await batch.commit();
      Navigator.pop(context); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Data berjaya dieksport ke Firebase!")),
      );
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Ralat mengeksport data: $e")),
      );
    }
  }

  /// **Import Notes from Firebase to Hive**
  static Future<void> importNotesFromFirebase(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from closing the dialog
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      var noteBox = await Hive.openBox<Note>('catatBarang');
      QuerySnapshot querySnapshot =
          await _firestore.collection(collectionName).get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('id') && data.containsKey('items')) {
          Note note = Note.fromJson(data);
          noteBox.put(note.id, note);
        }
      }

      Navigator.pop(context); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Data berjaya diimport dari Firebase!")),
      );
    } catch (e) {
      Navigator.pop(context); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Ralat mengimport data: $e")),
      );
    }
  }
}
