import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/restock_request_model.dart';
import '../../services/restock_request_service.dart';
import '../../services/record_service.dart';
import '../../services/receipt_service.dart';
import '../../models/record_model.dart';
import '../../models/receipt_model.dart';
import '../../utils/helpers.dart';

class SupplierHomeScreen extends StatefulWidget {
  const SupplierHomeScreen({Key? key}) : super(key: key);

  @override
  State<SupplierHomeScreen> createState() => _SupplierHomeScreenState();
}

class _SupplierHomeScreenState extends State<SupplierHomeScreen> {
  final _restockService = RestockRequestService();
  final _recordService = RecordService();
  final _receiptService = ReceiptService();
  List<RestockRequest> _requests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await _restockService.getPendingRestockRequests();
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading requests: $e')),
        );
      }
    }
  }

  Future<void> _approveRequest(RestockRequest request) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.appUser;

    if (user == null) return;

    try {
      // Approve request
      await _restockService.approveRestockRequestBySupplier(
        request.id,
        user.id,
        user.name,
      );

      // Generate invoice (receipt)
      final receipt = Receipt(
        id: '',
        type: ReceiptType.supplier,
        entityId: request.id,
        relatedEntityId: request.id,
        farmerId: request.inventoryManagerId,
        farmerName: request.inventoryManagerName,
        supplierId: user.id,
        supplierName: user.name,
        amount: request.totalAmount,
        description:
            'Restock: ${request.productName} - ${request.requestedQuantity} units',
        status: ReceiptStatus.pending,
        createdAt: DateTime.now(),
        lineItems: {
          'productId': request.productId,
          'productName': request.productName,
          'quantity': request.requestedQuantity,
        },
        issuedTo: request.inventoryManagerName,
        issuedBy: user.name,
      );

      final receiptId = await _receiptService.createReceipt(receipt);

      // Update restock request with invoice ID
      await _restockService.generateInvoice(request.id, receiptId);

      // Create activity record
      await _recordService.createRecord(
        ActivityRecord(
          id: '',
          type: RecordType.restockApproval,
          userId: user.id,
          userName: user.name,
          userRole: user.role,
          entityId: request.id,
          entityType: 'restockRequest',
          details: {
            'requestId': request.id,
            'productName': request.productName,
            'quantity': request.requestedQuantity,
            'receiptId': receiptId,
          },
          timestamp: DateTime.now(),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request approved and invoice generated'),
            backgroundColor: Colors.green,
          ),
        );
        _loadRequests();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest(RestockRequest request) async {
    final reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _restockService.rejectRestockRequest(
          request.id,
          reasonController.text.isNotEmpty
              ? reasonController.text
              : 'No reason provided',
        );

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.appUser;

        if (user != null) {
          await _recordService.createRecord(
            ActivityRecord(
              id: '',
              type: RecordType.restockRejection,
              userId: user.id,
              userName: user.name,
              userRole: user.role,
              entityId: request.id,
              entityType: 'restockRequest',
              details: {
                'requestId': request.id,
                'productName': request.productName,
                'reason': reasonController.text.isNotEmpty
                    ? reasonController.text
                    : 'No reason provided',
              },
              timestamp: DateTime.now(),
            ),
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request rejected'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadRequests();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error rejecting request: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_shipping,
                          size: 100, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No pending restock requests',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text('Requests will appear here when created'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return _buildRequestCard(request);
                    },
                  ),
                ),
    );
  }

  Widget _buildRequestCard(RestockRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.productName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Chip(
                  label: Text(
                      request.status.toString().split('.').last.toUpperCase()),
                  backgroundColor: Colors.orange,
                  labelStyle:
                      const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Quantity', '${request.requestedQuantity} units'),
            _buildInfoRow('Price per Unit',
                AppHelpers.formatCurrency(request.proposedPrice)),
            _buildInfoRow(
              'Total Amount',
              AppHelpers.formatCurrency(request.totalAmount),
            ),
            _buildInfoRow('Requested by', request.inventoryManagerName),
            _buildInfoRow(
              'Request Date',
              AppHelpers.formatDate(request.createdAt),
            ),
            if (request.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notes:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(request.notes!),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectRequest(request),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveRequest(request),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
