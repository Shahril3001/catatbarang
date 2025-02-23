import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserGuidePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tatacara Guna",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color(0xFF123456),
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(FontAwesomeIcons.bookOpen,
                    size: 50, color: Colors.green),
              ),
              SizedBox(height: 20),
              Text(
                "Panduan Penggunaan Aplikasi",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                  "1. Buka aplikasi dan pilih 'Tambah Nota' untuk mencipta catatan baharu."),
              Text("2. Pilih tarikh catatan dan tambah barang."),
              Text("3. Simpan catatan setelah selesai menambah barang."),
              Text("4. Semak catatan dalam senarai nota."),
              Text(
                  "5. Gunakan fungsi eksport dan import data untuk penyimpanan selamat."),
              SizedBox(height: 20),
              Divider(),
              Text(
                "Soalan Lazim (FAQ)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ExpansionTile(
                title: Text("Bagaimana cara mengedit nota?"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "Tekan nota yang ingin diedit dan pilih fungsi edit."),
                  )
                ],
              ),
              ExpansionTile(
                title: Text("Adakah data saya selamat?"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "Ya, data disimpan secara tempatan menggunakan HiveDB."),
                  )
                ],
              ),
              ExpansionTile(
                title: Text("Di manakah lokasi fail eksport data disimpan?"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        """Fail eksport disimpan dalam direktori 'Documents' atau folder lalai storan peranti anda.

  /storage/emulated/0/Android/data/com.yourapp.package/files/Backup/
  """),
                  )
                ],
              ),
              ExpansionTile(
                title: Text(
                    "Bagaimana cara mengimport semula data yang dieksport?"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "Gunakan fungsi 'Import Data' dalam aplikasi dan pilih fail eksport yang telah disimpan untuk memulihkan data."),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
