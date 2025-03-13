import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db/hive_db.dart';
import 'providers/note_provider.dart';
import 'pages/note_list_page.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);
  await HiveDB.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NoteProvider()..loadNotes(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: NoteListPage(),
      ),
    );
  }
}
