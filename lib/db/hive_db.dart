import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../models/item.dart';

class HiveDB {
  static late Box<Note> noteBox;

  // Initialize Hive and register the adapters for Note and Item
  static Future<void> init() async {
    try {
      await Hive.initFlutter(); // Initialize Hive with Flutter
      Hive.registerAdapter(NoteAdapter()); // Register Note adapter
      Hive.registerAdapter(ItemAdapter()); // Register Item adapter
      noteBox =
          await Hive.openBox<Note>('catatBarang'); // Open the box for notes
    } catch (e) {
      // Handle initialization errors
      print('Error initializing Hive: $e');
      throw Exception(
          'Failed to initialize Hive'); // Throwing an exception to handle at the calling level
    }
  }

  // Add a new note to the Hive box
  static Future<void> addNote(Note note) async {
    try {
      await noteBox.put(note.id, note); // Ensure id is unique
    } catch (e) {
      // Handle errors when adding the note
      print('Error adding note: $e');
      throw Exception('Failed to add note');
    }
  }

  // Get all notes from the Hive box (asynchronous)
  static Future<List<Note>> getNotes() async {
    try {
      return noteBox.values.toList(); // Convert the notes into a list
    } catch (e) {
      // Handle errors when retrieving notes
      print('Error retrieving notes: $e');
      return []; // Return an empty list on error
    }
  }

  // Delete a note by its id
  static Future<void> deleteNote(String id) async {
    try {
      await noteBox.delete(id); // Ensure the note exists before deleting
    } catch (e) {
      // Handle errors when deleting the note
      print('Error deleting note: $e');
      throw Exception('Failed to delete note');
    }
  }

  // Update an existing note
  static Future<void> updateNote(Note note) async {
    try {
      await noteBox.put(note.id, note); // This will overwrite the existing note
    } catch (e) {
      // Handle errors when updating the note
      print('Error updating note: $e');
      throw Exception('Failed to update note');
    }
  }

  // Delete all notes (Reset function)
  static Future<void> clearAllNotes() async {
    try {
      await noteBox.clear(); // Clears all data in the box
      print("All notes have been deleted.");
    } catch (e) {
      print('Error deleting all notes: $e');
      throw Exception('Failed to delete all notes');
    }
  }

  // Close the Hive box (call when app is closed or no longer needed)
  static Future<void> closeBox() async {
    await noteBox.close();
  }
}
