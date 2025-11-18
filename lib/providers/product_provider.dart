import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  ProductCategory? _selectedCategory;

  List<Product> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  ProductCategory? get selectedCategory => _selectedCategory;

  ProductProvider() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _productService.getAllProducts();
      _filteredProducts = List.from(_products);
    } catch (e) {
      print('Load products error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Alias for compatibility
  Future<void> fetchProducts() async {
    await loadProducts();
  }

  void filterByCategory(ProductCategory? category) {
    _selectedCategory = category;
    if (category == null) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts =
          _products.where((p) => p.category == category).toList();
    }
    notifyListeners();
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products.where((p) {
        return p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<bool> addProduct(Product product) async {
    try {
      await _productService.addProduct(product);
      await loadProducts();
      return true;
    } catch (e) {
      print('Add product error: $e');
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      await _productService.updateProduct(product);
      await loadProducts();
      return true;
    } catch (e) {
      print('Update product error: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _productService.deleteProduct(productId);
      await loadProducts();
      return true;
    } catch (e) {
      print('Delete product error: $e');
      return false;
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
