import 'package:catatbarang/pages/add_item_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../models/item.dart';
import '../providers/note_provider.dart';

class AddNotePage extends StatefulWidget {
  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _dateController = TextEditingController();
  final List<Item> _items = [];

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _addItem() async {
    final item = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddItemPage()),
    );
    if (item != null) {
      setState(() {
        _items.add(item);
      });
    }
  }

  void _editItem(int index) {
    // Controllers for text fields
    TextEditingController nameController =
        TextEditingController(text: _items[index].name);
    TextEditingController quantityController =
        TextEditingController(text: _items[index].quantity.toString());
    TextEditingController priceController =
        TextEditingController(text: _items[index].price.toString());
    TextEditingController descriptionController =
        TextEditingController(text: _items[index].description);

    // Dropdown value and valid types
    String selectedType = _items[index].type.toLowerCase();
    List<String> validTypes = ["buah", "sayur", "ikan", "lain-lain"];

    // Ensure the selected type is valid
    if (!validTypes.contains(selectedType)) {
      selectedType = "buah";
    }

    // Show the bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the sheet to expand with the keyboard
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nama Barang
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nama Barang",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              SizedBox(height: 12), // Spacing

              // Jenis Barang Dropdown
              DropdownButtonFormField<String>(
                value: selectedType,
                items: validTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type.toUpperCase(),
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Kategori Barang",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12), // Spacing

              // Kuantiti
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Kuantiti",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              SizedBox(height: 12), // Spacing

              // Harga
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Harga (BND)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              SizedBox(height: 12), // Spacing

              // Keterangan
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Keterangan",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              SizedBox(height: 20), // Spacing

              // Simpan Button
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _items[index] = Item(
                      itemID: _items[index].itemID,
                      name: nameController.text,
                      type: selectedType,
                      quantity: int.tryParse(quantityController.text) ?? 1,
                      price: double.tryParse(priceController.text) ?? 0.0,
                      description: descriptionController.text,
                    );
                  });
                  Navigator.pop(context); // Close the bottom sheet
                },
                icon: Icon(Icons.save, color: Colors.white),
                label: Text(
                  "Simpan",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateTotalPrice() {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _confirmSaveNote() async {
    if (_dateController.text.isEmpty || _items.isEmpty) {
      return;
    }

    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Sahkan Simpan Nota"),
        content: Text("Adakah anda pasti mahu menyimpan nota ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400),
            child: Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _saveNote();
    }
  }

  void _saveNote() {
    final note = Note(
      id: DateTime.now().toString(),
      notetitle: _dateController.text,
      items: _items,
    );

    Provider.of<NoteProvider>(context, listen: false).addNote(note);
    Navigator.pop(context);
  }

  Color _getItemColor(String type) {
    switch (type.toLowerCase()) {
      case 'buah':
        return Colors.orangeAccent;
      case 'sayur':
        return Colors.green;
      case 'ikan':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getItemIcon(String type) {
    switch (type.toLowerCase()) {
      case 'buah': // Fruits
        return FontAwesomeIcons.appleWhole; // 🍏 Apple icon
      case 'sayur': // Vegetables
        return FontAwesomeIcons.carrot; // 🥕 Carrot icon
      case 'ikan': // Fish
        return FontAwesomeIcons.fish; // 🐟 Fish icon
      default: // Others
        return FontAwesomeIcons.boxOpen; // 📦 Generic item icon
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tambah Nota",
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tarikh:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                ),
                child: Text(
                  _dateController.text.isEmpty
                      ? "Pilih Tarikh"
                      : _dateController.text,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _addItem,
                icon: Icon(Icons.add, color: Colors.white),
                label: Text("Tambah Barang",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Text(
                        "Tiada barang ditambahkan",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => Divider(),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _getItemColor(item.type),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getItemIcon(item.type),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(
                              "Kuantiti: ${item.quantity} \nHarga: \$${item.price.toStringAsFixed(2)}",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "\$${item.totalPrice.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.green.shade400),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.amber),
                                  onPressed: () => _editItem(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      _items.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Divider(height: 2, color: Colors.black45),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Jumlah Keseluruhan:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text("BND\$${_calculateTotalPrice().toStringAsFixed(2)}",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade400)),
                ],
              ),
            ),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _confirmSaveNote,
                  icon: Icon(Icons.save, color: Colors.white),
                  label: Text("Simpan Nota",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.green.shade400,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
