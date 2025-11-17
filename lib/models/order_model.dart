enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
    );
  }
}

class Order {
  final String id;
  final String farmerId;
  final String farmerName;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String deliveryAddress;
  final String? driverId;
  final String? dispatchManagerId;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? notes;

  Order({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    this.driverId,
    this.dispatchManagerId,
    required this.createdAt,
    this.deliveredAt,
    this.notes,
  });

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    return Order(
      id: id,
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      items: (map['items'] as List? ?? [])
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${map['status']}',
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: map['deliveryAddress'] ?? '',
      driverId: map['driverId'],
      dispatchManagerId: map['dispatchManagerId'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      deliveredAt: map['deliveredAt'] != null ? DateTime.parse(map['deliveredAt']) : null,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'farmerName': farmerName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'deliveryAddress': deliveryAddress,
      'driverId': driverId,
      'dispatchManagerId': dispatchManagerId,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'notes': notes,
    };
  }
}
