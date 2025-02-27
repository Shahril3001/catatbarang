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
      print('Error initializing Hive: $e');
      throw Exception('Failed to initialize Hive');
    }
  }

  // Add a new note to the Hive box
  static Future<void> addNote(Note note) async {
    try {
      await noteBox.put(note.id, note); // Ensure id is unique
    } catch (e) {
      print('Error adding note: $e');
      throw Exception('Failed to add note');
    }
  }

  // Get all notes from the Hive box
  static Future<List<Note>> getNotes() async {
    try {
      return noteBox.values.toList();
    } catch (e) {
      print('Error retrieving notes: $e');
      return [];
    }
  }

  // Delete a note by its ID
  static Future<void> deleteNote(String id) async {
    try {
      await noteBox.delete(id);
    } catch (e) {
      print('Error deleting note: $e');
      throw Exception('Failed to delete note');
    }
  }

  // Update an existing note
  static Future<void> updateNote(Note note) async {
    try {
      await noteBox.put(note.id, note);
    } catch (e) {
      print('Error updating note: $e');
      throw Exception('Failed to update note');
    }
  }

  // Delete all notes (Reset function)
  static Future<void> clearAllNotes() async {
    try {
      await noteBox.clear();
      print("All notes have been deleted.");
    } catch (e) {
      print('Error deleting all notes: $e');
      throw Exception('Failed to delete all notes');
    }
  }

  // Get all items from all notes
  static Future<List<Item>> getAllItems() async {
    try {
      return noteBox.values.expand((note) => note.items).toList();
    } catch (e) {
      print('Error retrieving items: $e');
      return [];
    }
  }

  // Search items by name
  static Future<List<Item>> searchItemsByName(String query) async {
    try {
      final allItems = await getAllItems();
      return allItems
          .where(
              (item) => item.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Error searching items: $e');
      return [];
    }
  }

  // Close the Hive box
  static Future<void> closeBox() async {
    await noteBox.close();
  }

  // Delete all items (Reset function)
  static Future<void> clearAllItems() async {
    try {
      await noteBox
          .clear(); // This clears all notes, including items within them
      print("All items have been deleted.");
    } catch (e) {
      print('Error deleting all items: $e');
      throw Exception('Failed to delete all items');
    }
  }
}
