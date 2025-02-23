import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DeveloperPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pengembang",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF123456),
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(FontAwesomeIcons.code, size: 50, color: Colors.blue),
            ),
            SizedBox(height: 20),
            Text(
              "Maklumat Pengembang",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Aplikasi ini dibangunkan oleh Shahril3001."),
            Text("Versi Aplikasi: 1.0.0"),
            Text("Hak Cipta © 2025. Semua Hak Terpelihara."),
            SizedBox(height: 20),
            Divider(),
            Text(
              "Hubungi Pengembang",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: Icon(Icons.email, color: Colors.red),
              title: Text("Email: shahril3001.sr@gmail.com"),
            ),
            ListTile(
              leading: Icon(FontAwesomeIcons.github, color: Colors.black),
              title: Text("GitHub: github.com/Shahril30"),
            ),
          ],
        ),
      ),
    );
  }
}
