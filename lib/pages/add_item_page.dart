import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/item.dart';
import 'package:catatbarang/db/hive_db.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedType = "Buah"; // Default type
  List<String> _suggestions = [];
  bool _isSearching = false;
  OverlayEntry? _overlayEntry; // Overlay entry reference
  final LayerLink _layerLink = LayerLink(); // Positioning reference
  final FocusNode _focusNode = FocusNode(); // Focus node for the text field

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay(); // Remove overlay when focus is lost
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  Future<List<String>> _searchItems(String query) async {
    try {
      final List<Item> items = await HiveDB.searchItemsByName(query);
      final List<String> suggestions =
          items.map((item) => item.name).toSet().toList();
      return suggestions;
    } catch (e) {
      print('Error searching items: $e');
      return [];
    }
  }

  void _showOverlay() {
    _removeOverlay(); // Remove existing overlay before adding a new one
    final OverlayState overlayState = Overlay.of(context);
    _overlayEntry = _createOverlayEntry();
    overlayState.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: MediaQuery.of(context).size.width * 0.1, // Center the overlay
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: Offset(0, 50), // Adjust position below text field
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // Background color
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: _suggestions.isNotEmpty
                    ? ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: _suggestions.map((suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                            onTap: () {
                              setState(() {
                                _nameController.text = suggestion;
                                _suggestions = [];
                              });
                              _removeOverlay();
                            },
                          );
                        }).toList(),
                      )
                    : SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }

  // Fungsi untuk menyimpan item
  void _saveItem() {
    if (_nameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sila isi semua field yang diperlukan"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Simpan Barang"),
          content: Text("Adakah anda pasti ingin menyimpan barang ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                final item = Item(
                  itemID: DateTime.now().toString(),
                  name: _nameController.text,
                  type: _selectedType,
                  quantity: int.parse(_quantityController.text),
                  price: double.parse(_priceController.text),
                  description: _descriptionController.text,
                );

                Navigator.pop(context); // Close dialog
                Navigator.pop(context, item); // Return item
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400),
              child: Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /// Returns the corresponding icon for the selected item type
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

  /// Returns a color matching the item type
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tambah Barang",
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
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  /// Nama Barang with Overlay
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: TextField(
                      controller: _nameController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        labelText: "Nama Barang",
                        prefixIcon: Icon(Icons.edit, color: Colors.blueAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _isSearching = true);
                        _searchItems(value).then((suggestions) {
                          setState(() {
                            _suggestions = suggestions;
                            _isSearching = false;
                          });
                          if (_suggestions.isNotEmpty) {
                            _showOverlay();
                          } else {
                            _removeOverlay();
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 12),

                  /// Jenis Barang (Dropdown with Icons)
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: "Kategori Barang",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ["Buah", "Sayur", "Ikan", "Lain-lain"]
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(_getItemIcon(type),
                                      color: _getItemColor(type)),
                                  SizedBox(width: 10),
                                  Text(type),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedType = value!),
                  ),
                  SizedBox(height: 12),

                  /// Kuantiti Barang
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Kuantiti",
                      prefixIcon: Icon(Icons.numbers, color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  /// Harga Barang
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Harga (BND\$)",
                      prefixIcon:
                          Icon(Icons.attach_money, color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  /// Deskripsi Barang
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Keterangan",
                      prefixIcon:
                          Icon(Icons.description, color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saveItem,
                icon: Icon(Icons.save),
                label: Text("Simpan", style: TextStyle(color: Colors.white)),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            /// Cancel Button (No Border)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.cancel, color: Colors.white),
                label: Text("Batal", style: TextStyle(color: Colors.white)),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.redAccent, // No border issue
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
