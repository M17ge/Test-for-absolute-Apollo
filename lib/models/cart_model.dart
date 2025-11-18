class CartItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String unit;
  final String? imageUrl;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.unit,
    this.imageUrl,
  });

  double get totalPrice => price * quantity;

  CartItem copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    String? unit,
    String? imageUrl,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'imageUrl': imageUrl,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      unit: map['unit'] ?? 'unit',
      imageUrl: map['imageUrl'],
    );
  }
}
