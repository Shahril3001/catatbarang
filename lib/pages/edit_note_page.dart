import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../models/item.dart';
import '../providers/note_provider.dart';

class EditNotePage extends StatefulWidget {
  final Note note;

  EditNotePage({required this.note});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late DateTime _selectedDate;
  late List<Item> _items;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.tryParse(widget.note.notetitle) ?? DateTime.now();
    _items = List.from(widget.note.items);
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1990),
      lastDate: DateTime(2050),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _confirmUpdateNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Sahkan Kemaskini"),
        content: Text("Adakah anda pasti ingin menyimpan perubahan?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateNote();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _updateNote() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    Note updatedNote = Note(
      id: widget.note.id,
      notetitle: _dateFormat.format(_selectedDate),
      items: _items,
    );
    noteProvider.updateNote(updatedNote);
    Navigator.pop(context);
  }

  void _removeItem(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Padam Item"),
        content: Text("Adakah anda pasti ingin memadam item ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _items.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text("Padam", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editItem(int index) {
    TextEditingController nameController =
        TextEditingController(text: _items[index].name);
    TextEditingController quantityController =
        TextEditingController(text: _items[index].quantity.toString());
    TextEditingController priceController =
        TextEditingController(text: _items[index].price.toString());
    TextEditingController descriptionController =
        TextEditingController(text: _items[index].description);

    String selectedType = _items[index].type.toLowerCase();
    List<String> validTypes = ["buah", "sayur", "ikan", "lain-lain"];

    if (!validTypes.contains(selectedType)) {
      selectedType = "buah";
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: "Nama Barang", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: validTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
                decoration: InputDecoration(
                    labelText: "Kategori Barang", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Kuantiti", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Harga (BND\$)", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                    labelText: "Keterangan", border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
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
                  Navigator.pop(context);
                },
                icon: Icon(Icons.save, color: Colors.white),
                label: Text("Simpan", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addItem() {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    String selectedType = "buah";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: "Nama Barang", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: ["buah", "sayur", "ikan", "lain-lain"]
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
                decoration: InputDecoration(
                    labelText: "Kategori Barang", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Kuantiti", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Harga (BND\$)", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                    labelText: "Keterangan", border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _items.add(Item(
                      itemID: DateTime.now().toString(),
                      name: nameController.text,
                      type: selectedType,
                      quantity: int.tryParse(quantityController.text) ?? 1,
                      price: double.tryParse(priceController.text) ?? 0.0,
                      description: descriptionController.text,
                    ));
                  });
                  Navigator.pop(context);
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text("Tambah Barang",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Kemaskini Nota",
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
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(
                      text: _dateFormat.format(_selectedDate)),
                  decoration: InputDecoration(
                    labelText: "Tarikh",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.blue),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    elevation: 1,
                    margin: EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1)),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      leading: CircleAvatar(
                        backgroundColor: _getItemColor(item.type),
                        child: _getItemIcon(item.type),
                      ),
                      title: Text(item.name,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          "${item.type.toLowerCase()} | ${item.quantity} x BND\$${item.price.toStringAsFixed(2)}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: Icon(Icons.edit, color: Colors.amber),
                              onPressed: () => _editItem(index)),
                          IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(index)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text("Tambah Barang",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _addItem, // Fungsi untuk menambah item
                    ),
                  ),
                  SizedBox(width: 10), // Spasi antar tombol
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.save, color: Colors.white),
                      label: Text("Kemaskini",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed:
                          _confirmUpdateNote, // Fungsi untuk menyimpan nota
                    ),
                  ),
                ],
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
}
