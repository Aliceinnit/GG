import 'package:api_test/model/imat/shopping_item.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs

class ShoppingList {
  String id;
  String title;
  List<ShoppingItem> items;
  DateTime createdAt;

  ShoppingList({
    String? id, // Make id optional for creation
    required this.title,
    List<ShoppingItem>? items,
    DateTime? createdAt,
  }) : this.id = id ?? Uuid().v4(), // Generate unique ID if not provided
       this.items = items ?? [],
       this.createdAt = createdAt ?? DateTime.now();

  double getTotal() {
    if (items.isEmpty) {
      return 0.0;
    }
    return items.fold(0.0, (sum, item) => sum + (item.product.price * item.amount));
  }

  // Helper method to find an item
  ShoppingItem? findItem(int productId) { // Changed to int productId
    try {
      return items.firstWhere((item) => item.product.productId == productId);
    } catch (e) {
      return null; // Not found
    }
  }

  // toJson and fromJson for potential persistence (optional for now)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'items': items.map((item) => item.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory ShoppingList.fromJson(Map<String, dynamic> json) => ShoppingList(
        id: json['id'],
        title: json['title'],
        items: (json['items'] as List)
            .map((itemJson) => ShoppingItem.fromJson(itemJson))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
      );
}
