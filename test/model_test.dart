import 'package:flutter_test/flutter_test.dart';
import 'package:apollo_agro/models/user_model.dart';
import 'package:apollo_agro/models/product_model.dart';
import 'package:apollo_agro/models/order_model.dart';
import 'package:apollo_agro/models/credit_model.dart';

void main() {
  group('User Model Tests', () {
    test('User model should be created correctly', () {
      final user = AppUser(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        phone: '1234567890',
        role: UserRole.farmer,
        createdAt: DateTime.now(),
      );

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.role, UserRole.farmer);
    });

    test('User model should convert to and from map', () {
      final user = AppUser(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        phone: '1234567890',
        role: UserRole.farmer,
        createdAt: DateTime.now(),
      );

      final map = user.toMap();
      final newUser = AppUser.fromMap(map, '123');

      expect(newUser.email, user.email);
      expect(newUser.name, user.name);
      expect(newUser.role, user.role);
    });
  });

  group('Product Model Tests', () {
    test('Product model should be created correctly', () {
      final product = Product(
        id: '1',
        name: 'Maize Seeds',
        description: 'High quality maize seeds',
        category: ProductCategory.seeds,
        price: 100.0,
        stockQuantity: 50,
        unit: 'kg',
        imageUrls: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.name, 'Maize Seeds');
      expect(product.category, ProductCategory.seeds);
      expect(product.price, 100.0);
      expect(product.stockQuantity, 50);
    });

    test('Product model should convert to and from map', () {
      final product = Product(
        id: '1',
        name: 'Maize Seeds',
        description: 'High quality maize seeds',
        category: ProductCategory.seeds,
        price: 100.0,
        stockQuantity: 50,
        unit: 'kg',
        imageUrls: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final map = product.toMap();
      final newProduct = Product.fromMap(map, '1');

      expect(newProduct.name, product.name);
      expect(newProduct.category, product.category);
      expect(newProduct.price, product.price);
    });
  });

  group('Order Model Tests', () {
    test('Order item should calculate total price correctly', () {
      final item = OrderItem(
        productId: '1',
        productName: 'Test Product',
        quantity: 5,
        unitPrice: 20.0,
        totalPrice: 100.0,
      );

      expect(item.totalPrice, 100.0);
      expect(item.quantity, 5);
    });

    test('Order model should be created correctly', () {
      final items = [
        OrderItem(
          productId: '1',
          productName: 'Product 1',
          quantity: 2,
          unitPrice: 50.0,
          totalPrice: 100.0,
        ),
      ];

      final order = Order(
        id: '1',
        farmerId: '123',
        farmerName: 'Test Farmer',
        items: items,
        totalAmount: 100.0,
        status: OrderStatus.pending,
        deliveryAddress: '123 Test St',
        createdAt: DateTime.now(),
      );

      expect(order.totalAmount, 100.0);
      expect(order.items.length, 1);
      expect(order.status, OrderStatus.pending);
    });
  });

  group('Credit Model Tests', () {
    test('Credit model should be created correctly', () {
      final credit = Credit(
        id: '1',
        farmerId: '123',
        farmerName: 'Test Farmer',
        amount: 5000.0,
        interestRate: 5.0,
        durationMonths: 12,
        status: CreditStatus.pending,
        requestDate: DateTime.now(),
        amountDue: 5250.0,
        purpose: 'Farm equipment',
      );

      expect(credit.amount, 5000.0);
      expect(credit.interestRate, 5.0);
      expect(credit.status, CreditStatus.pending);
    });

    test('Payment should be created correctly', () {
      final payment = Payment(
        id: '1',
        amount: 500.0,
        date: DateTime.now(),
        method: 'Bank Transfer',
      );

      expect(payment.amount, 500.0);
      expect(payment.method, 'Bank Transfer');
    });
  });
}
