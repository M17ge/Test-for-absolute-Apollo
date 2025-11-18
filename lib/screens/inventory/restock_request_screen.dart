import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../models/restock_request_model.dart';
import '../../services/restock_request_service.dart';
import '../../services/record_service.dart';
import '../../models/record_model.dart';
import '../../utils/helpers.dart';

class RestockRequestScreen extends StatefulWidget {
  final Product? product;

  const RestockRequestScreen({Key? key, this.product}) : super(key: key);

  @override
  State<RestockRequestScreen> createState() => _RestockRequestScreenState();
}

class _RestockRequestScreenState extends State<RestockRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _restockService = RestockRequestService();
  final _recordService = RecordService();

  Product? _selectedProduct;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedProduct = widget.product;
    if (_selectedProduct != null) {
      _priceController.text = _selectedProduct!.price.toString();
    }
    Future.microtask(() {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.appUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final request = RestockRequest(
        id: '',
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        requestedQuantity: int.parse(_quantityController.text),
        proposedPrice: double.parse(_priceController.text),
        inventoryManagerId: user.id,
        inventoryManagerName: user.name,
        status: RestockRequestStatus.pending,
        createdAt: DateTime.now(),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      final requestId = await _restockService.createRestockRequest(request);

      // Create activity record
      await _recordService.createRecord(
        ActivityRecord(
          id: '',
          type: RecordType.restockRequest,
          userId: user.id,
          userName: user.name,
          userRole: user.role,
          entityId: requestId,
          entityType: 'restockRequest',
          details: {
            'productId': _selectedProduct!.id,
            'productName': _selectedProduct!.name,
            'quantity': int.parse(_quantityController.text),
            'proposedPrice': double.parse(_priceController.text),
          },
          timestamp: DateTime.now(),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restock request submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Restock'),
      ),
      body: productProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product selection
                    DropdownButtonFormField<Product>(
                      value: _selectedProduct,
                      decoration: const InputDecoration(
                        labelText: 'Select Product',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      items: productProvider.products.map((product) {
                        return DropdownMenuItem<Product>(
                          value: product,
                          child: Text(
                            '${product.name} (Stock: ${product.stockQuantity})',
                          ),
                        );
                      }).toList(),
                      onChanged: (product) {
                        setState(() {
                          _selectedProduct = product;
                          if (product != null) {
                            _priceController.text = product.price.toString();
                          }
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a product' : null,
                    ),
                    const SizedBox(height: 16),

                    // Current stock info
                    if (_selectedProduct != null) ...[
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Stock Information',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Quantity:'),
                                  Text(
                                    '${_selectedProduct!.stockQuantity} ${_selectedProduct!.unit}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Price per unit:'),
                                  Text(
                                    AppHelpers.formatCurrency(
                                        _selectedProduct!.price),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Requested quantity
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Requested Quantity',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.add_box),
                        suffixText: _selectedProduct?.unit ?? 'units',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        final quantity = int.tryParse(value);
                        if (quantity == null || quantity <= 0) {
                          return 'Please enter a valid quantity';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Proposed price per unit
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price per Unit',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {}); // Rebuild to update total
                      },
                    ),
                    const SizedBox(height: 16),

                    // Total amount display
                    if (_quantityController.text.isNotEmpty &&
                        _priceController.text.isNotEmpty) ...[
                      Card(
                        color: Colors.green[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount:',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                AppHelpers.formatCurrency(
                                  (int.tryParse(_quantityController.text) ??
                                          0) *
                                      (double.tryParse(_priceController.text) ??
                                          0),
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Submit Restock Request',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
