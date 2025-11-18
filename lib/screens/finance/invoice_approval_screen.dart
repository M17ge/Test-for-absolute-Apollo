import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/receipt_model.dart';
import '../../services/receipt_service.dart';
import '../../services/restock_request_service.dart';
import '../../services/product_service.dart';
import '../../services/record_service.dart';
import '../../models/record_model.dart';
import '../../utils/helpers.dart';

class InvoiceApprovalScreen extends StatefulWidget {
  const InvoiceApprovalScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceApprovalScreen> createState() => _InvoiceApprovalScreenState();
}

class _InvoiceApprovalScreenState extends State<InvoiceApprovalScreen> {
  final _receiptService = ReceiptService();
  final _restockService = RestockRequestService();
  final _productService = ProductService();
  final _recordService = RecordService();
  List<Receipt> _pendingInvoices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPendingInvoices();
  }

  Future<void> _loadPendingInvoices() async {
    setState(() => _isLoading = true);
    try {
      final receipts =
          await _receiptService.getReceiptsByType(ReceiptType.supplier);
      final pending =
          receipts.where((r) => r.status == ReceiptStatus.pending).toList();

      if (mounted) {
        setState(() {
          _pendingInvoices = pending;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading invoices: $e')),
        );
      }
    }
  }

  Future<void> _approveInvoice(Receipt receipt) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.appUser;

    if (user == null) return;

    try {
      // Approve receipt
      await _receiptService.approveReceipt(
        receipt.id,
        user.id,
        user.name,
      );

      // Get restock request
      final restockRequest = await _restockService.getRestockRequestById(
        receipt.relatedEntityId ?? receipt.entityId,
      );

      if (restockRequest != null) {
        // Approve by finance manager
        await _restockService.approveByFinanceManager(
          restockRequest.id,
          user.id,
          user.name,
        );

        // Create activity record
        await _recordService.createRecord(
          ActivityRecord(
            id: '',
            type: RecordType.invoiceApproval,
            userId: user.id,
            userName: user.name,
            userRole: user.role,
            entityId: receipt.id,
            entityType: 'receipt',
            details: {
              'receiptId': receipt.id,
              'restockRequestId': restockRequest.id,
              'productName': restockRequest.productName,
              'amount': receipt.amount,
            },
            timestamp: DateTime.now(),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPendingInvoices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateReceipt(Receipt receipt) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.appUser;

    if (user == null) return;

    try {
      // Mark receipt as paid
      await _receiptService.markAsPaid(receipt.id);

      // Get restock request
      final restockRequest = await _restockService.getRestockRequestById(
        receipt.relatedEntityId ?? receipt.entityId,
      );

      if (restockRequest != null) {
        // Mark as dispatched (supplier will dispatch)
        await _restockService.markAsDispatched(restockRequest.id);

        // Update product stock
        final product =
            await _productService.getProductById(restockRequest.productId);
        if (product != null) {
          final newStock =
              product.stockQuantity + restockRequest.requestedQuantity;
          await _productService.updateStock(restockRequest.productId, newStock);

          // Mark restock as completed
          await _restockService.markAsCompleted(restockRequest.id);
        }

        // Create activity record
        await _recordService.createRecord(
          ActivityRecord(
            id: '',
            type: RecordType.receiptGeneration,
            userId: user.id,
            userName: user.name,
            userRole: user.role,
            entityId: receipt.id,
            entityType: 'receipt',
            details: {
              'receiptId': receipt.id,
              'restockRequestId': restockRequest.id,
              'productName': restockRequest.productName,
              'amount': receipt.amount,
            },
            timestamp: DateTime.now(),
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receipt generated and stock updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPendingInvoices();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating receipt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingInvoices,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingInvoices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long,
                          size: 100, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No pending invoices',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text('Invoices will appear here for approval'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPendingInvoices,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingInvoices.length,
                    itemBuilder: (context, index) {
                      final invoice = _pendingInvoices[index];
                      return _buildInvoiceCard(invoice);
                    },
                  ),
                ),
    );
  }

  Widget _buildInvoiceCard(Receipt invoice) {
    final isApproved = invoice.financeManagerId != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Invoice #${invoice.id.substring(0, 8).toUpperCase()}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Chip(
                  label: Text(
                    isApproved ? 'APPROVED' : 'PENDING',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: isApproved ? Colors.green : Colors.orange,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Description', invoice.description),
            _buildInfoRow('Amount', AppHelpers.formatCurrency(invoice.amount)),
            _buildInfoRow('Issued To', invoice.issuedTo ?? 'N/A'),
            _buildInfoRow('Issued By', invoice.issuedBy ?? 'N/A'),
            _buildInfoRow(
              'Created',
              AppHelpers.formatDate(invoice.createdAt),
            ),
            if (isApproved && invoice.financeManagerName != null) ...[
              const Divider(height: 24),
              _buildInfoRow('Approved By', invoice.financeManagerName!),
              _buildInfoRow(
                'Approved At',
                AppHelpers.formatDate(invoice.financeManagerApprovedAt!),
              ),
            ],
            const SizedBox(height: 16),
            if (!isApproved)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _approveInvoice(invoice),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Approve Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _generateReceipt(invoice),
                  icon: const Icon(Icons.receipt),
                  label: const Text('Generate Receipt & Update Stock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
