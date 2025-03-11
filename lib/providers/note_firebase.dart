import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';
import '../models/item.dart';
import 'package:hive/hive.dart';

class FirebaseHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String collectionName = "catatBarang";

  /// **Export Notes from Hive to Firebase**
  static Future<void> exportNotesToFirebase() async {
    var noteBox = await Hive.openBox<Note>('catatBarang');

    for (var note in noteBox.values) {
      await _firestore
          .collection(collectionName)
          .doc(note.id)
          .set(note.toJson());
    }

    print("✅ Data berjaya dieksport ke Firebase!");
  }

  /// **Import Notes from Firebase to Hive**
  static Future<void> importNotesFromFirebase() async {
    var noteBox = await Hive.openBox<Note>('catatBarang');

    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('catatBarang').get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Ensure data contains required fields before inserting
        if (data.containsKey('id') && data.containsKey('items')) {
          Note note = Note.fromJson(data);
          noteBox.put(note.id, note);
        }
      }

      print("✅ Data berjaya diimport dari Firebase!");
    } catch (e) {
      print("❌ Ralat mengimport data: $e");
    }
  }
}
