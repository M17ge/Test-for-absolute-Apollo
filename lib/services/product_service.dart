import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  Future<List<Product>> getAllProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isAvailable', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get all products error: $e');
      return [];
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Product.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Get product by id error: $e');
    }
    return null;
  }

  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection(_collection).add(product.toMap());
    } catch (e) {
      print('Add product error: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(product.id)
          .update(product.toMap());
    } catch (e) {
      print('Update product error: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collection).doc(productId).delete();
    } catch (e) {
      print('Delete product error: $e');
      rethrow;
    }
  }

  Future<void> updateStock(String productId, int quantity) async {
    try {
      await _firestore.collection(_collection).doc(productId).update({
        'stockQuantity': quantity,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Update stock error: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProductsByCategory(ProductCategory category) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category.toString().split('.').last)
          .where('isAvailable', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get products by category error: $e');
      return [];
    }
  }

  Future<List<Product>> getLowStockProducts({int threshold = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('stockQuantity', isLessThan: threshold)
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get low stock products error: $e');
      return [];
    }
  }
}
