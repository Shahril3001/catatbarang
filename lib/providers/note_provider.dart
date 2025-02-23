import 'package:flutter/material.dart';
import '../models/note.dart';
import '../db/hive_db.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false; // Track loading state

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  // Load notes from Hive
  Future<void> loadNotes() async {
    _isLoading = true; // Set loading state
    notifyListeners();

    try {
      _notes = await HiveDB
          .getNotes(); // Assuming HiveDB.getNotes() returns a Future<List<Note>>
    } catch (error) {
      print('Error loading notes: $error');
      // Handle errors appropriately here
    } finally {
      _isLoading = false; // Reset loading state
      notifyListeners();
    }
  }

  // Add a new note
  Future<void> addNote(Note note) async {
    try {
      await HiveDB.addNote(note); // Add the note to the database
      await loadNotes(); // Reload notes after adding
    } catch (error) {
      print('Error adding note: $error');
      // Handle errors here (e.g., show a Snackbar or AlertDialog)
    }
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    try {
      await HiveDB.deleteNote(id); // Delete the note from the database
      await loadNotes(); // Reload notes after deleting
    } catch (error) {
      print('Error deleting note: $error');
      // Handle errors here
    }
  }

  // Update an existing note
  Future<void> updateNote(Note note) async {
    try {
      await HiveDB.updateNote(note); // Update the note in the database
      await loadNotes(); // Reload notes after updating
    } catch (error) {
      print('Error updating note: $error');
      // Handle errors here
    }
  }
}
