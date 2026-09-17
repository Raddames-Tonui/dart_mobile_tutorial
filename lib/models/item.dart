/// Mirrors the shape of a row you'd get back from the Java backend's
/// JooqFetchUtil.fetch("items") — see the Sunfyre jOOQ guide. Field
/// names are snake_case on the wire (matching the platform's JSON
/// convention) and converted to camelCase here.
class Item {
  final int id;
  final String name;
  final String category;
  final String status;
  final double amount;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['date_created'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'status': status,
      'amount': amount,
      'date_created': createdAt.toIso8601String(),
    };
  }
}
