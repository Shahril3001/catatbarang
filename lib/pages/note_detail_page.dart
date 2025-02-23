import 'package:catatbarang/pages/edit_note_page.dart';
import 'package:catatbarang/providers/note_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import 'item_detail_page.dart';

class NoteDetailPage extends StatelessWidget {
  final Note note;

  NoteDetailPage({required this.note});

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${note.notetitle}",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditNotePage(note: note),
                  ),
                );
              } else if (value == 'delete') {
                bool confirmDelete = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Sahkan Hapus?"),
                    content:
                        Text("Apakah anda yakin ingin menghapus nota ini?"),
                    actions: [
                      TextButton(
                        child: Text("Batal"),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        child: Text("Hapus",
                            style: TextStyle(color: Colors.white)),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  ),
                );

                if (confirmDelete == true) {
                  context.read<NoteProvider>().deleteNote(note.id);
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.amber),
                    SizedBox(width: 8),
                    Text("Kemaskini",
                        style: TextStyle(color: Colors.grey[900])),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text("Hapus", style: TextStyle(color: Colors.grey[900])),
                  ],
                ),
              ),
            ],
          ),
        ],
        backgroundColor: Color(0xFF123456),
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Senarai Barang:-",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: note.items.length,
                itemBuilder: (context, index) {
                  final item = note.items[index];

                  return Card(
                    elevation: 1,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      leading: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getItemColor(item.type),
                          shape: BoxShape.circle,
                        ),
                        child: _getItemIcon(item.type),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Kuantiti: ${item.quantity} | Harga: \$${item.price.toStringAsFixed(2)}",
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                          if (item.description.isNotEmpty)
                            Text(
                              "Keterangan: ${_truncateDescription(item.description)}",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                      trailing: Text(
                        "\$${item.totalPrice.toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade400),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailPage(item: item),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Jumlah Keseluruhan: BND\$${note.totalPrice.toStringAsFixed(2)}",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getItemColor(String type) {
    switch (type.toLowerCase()) {
      case 'buah':
        return Colors.orange.shade100;
      case 'sayur':
        return Colors.green.shade100;
      case 'ikan':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Icon _getItemIcon(String type) {
    switch (type.toLowerCase()) {
      case 'buah': // Fruits 🍎
        return Icon(FontAwesomeIcons.appleWhole, color: Colors.orangeAccent);
      case 'sayur': // Vegetables 🥕
        return Icon(FontAwesomeIcons.carrot, color: Colors.green);
      case 'ikan': // Fish 🐟
        return Icon(FontAwesomeIcons.fish, color: Colors.blue);
      default: // Other Items 📦
        return Icon(FontAwesomeIcons.boxOpen, color: Colors.grey);
    }
  }

  // Function to truncate description to 50 characters
  String _truncateDescription(String description) {
    return description.length > 50
        ? '${description.substring(0, 50)}...'
        : description;
  }
}
