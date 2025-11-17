enum ProductCategory {
  seeds,
  fertilizers,
  pesticides,
  tools,
  equipment,
  services,
  other
}

class Product {
  final String id;
  final String name;
  final String description;
  final ProductCategory category;
  final double price;
  final int stockQuantity;
  final String unit; // e.g., kg, liters, pieces
  final List<String> imageUrls;
  final String? supplierId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isAvailable;
  final Map<String, dynamic>? specifications;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.unit,
    required this.imageUrls,
    this.supplierId,
    required this.createdAt,
    required this.updatedAt,
    this.isAvailable = true,
    this.specifications,
  });

  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: ProductCategory.values.firstWhere(
        (e) => e.toString() == 'ProductCategory.${map['category']}',
        orElse: () => ProductCategory.other,
      ),
      price: (map['price'] ?? 0).toDouble(),
      stockQuantity: map['stockQuantity'] ?? 0,
      unit: map['unit'] ?? 'unit',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      supplierId: map['supplierId'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      isAvailable: map['isAvailable'] ?? true,
      specifications: map['specifications'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category.toString().split('.').last,
      'price': price,
      'stockQuantity': stockQuantity,
      'unit': unit,
      'imageUrls': imageUrls,
      'supplierId': supplierId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isAvailable': isAvailable,
      'specifications': specifications,
    };
  }
}
