import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 1)
class Item {
  @HiveField(0)
  String itemID;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  double price;

  @HiveField(5)
  String description;

  Item({
    required this.itemID,
    required this.name,
    required this.type,
    required this.quantity,
    required this.price,
    required this.description,
  });

  double get totalPrice => price * quantity;

  /// Convert Item to JSON
  Map<String, dynamic> toJson() => {
        'itemID': itemID,
        'name': name,
        'type': type,
        'quantity': quantity,
        'price': price,
        'description': description,
      };

  /// Convert JSON to Item
  factory Item.fromJson(Map<String, dynamic> json) => Item(
        itemID: json['itemID'],
        name: json['name'],
        type: json['type'],
        quantity: json['quantity'],
        price: (json['price'] as num).toDouble(),
        description: json['description'],
      );
}
