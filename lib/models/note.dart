import 'package:hive/hive.dart';
import 'item.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  String id;

  @HiveField(1)
  String notetitle;

  @HiveField(2)
  List<Item> items;

  Note({required this.id, required this.notetitle, required this.items});

  double get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);

  /// Convert Note to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'notetitle': notetitle,
        'items': items.map((item) => item.toJson()).toList(),
      };

  /// Convert JSON to Note
  factory Note.fromJson(Map<String, dynamic> json) {
    List<Item> parsedItems =
        (json['items'] as List).map((item) => Item.fromJson(item)).toList();

    return Note(
      id: json['id'],
      notetitle: json['notetitle'],
      items: parsedItems,
    );
  }
}
