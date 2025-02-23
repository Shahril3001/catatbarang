import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/item.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item;

  ItemDetailPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.name,
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
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1),
          ),
          elevation: 1,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: _getItemColor(item.type),
                      shape: BoxShape.circle,
                    ),
                    child: _getItemIcon(item.type),
                  ),
                ),
                SizedBox(height: 16),
                _buildDetailRow("Nama Barang", item.name),
                _buildDetailRow("Kategori", item.type),
                _buildDetailRow("Kuantiti", item.quantity.toString()),
                _buildDetailRow(
                    "Harga", "BND\$${item.price.toStringAsFixed(2)}"),
                SizedBox(height: 16),

                // Catatan (Notes) Moved Above Total Price
                Text(
                  "Catatan:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  item.description.isNotEmpty
                      ? item.description
                      : "Tiada catatan",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(height: 16),

                // Total Harga (Total Price) Styled Bold
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "Jumlah Harga: BND\$${item.totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to build detail rows for better alignment
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label + ":",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Function to return colors based on item type
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

  // Function to return icons based on item type
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
