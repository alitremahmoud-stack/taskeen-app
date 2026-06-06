import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../models/invoice_model.dart';
import '../../widgets/navbar.dart';
import '../../widgets/custom_empty_state.dart';
import '../../widgets/custom_error_state.dart';
import '../../widgets/custom_invoice_card.dart';
import '../../core/routes_names.dart';
import '../../core/user_session.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final SqlDb _sqlDb = SqlDb();
  int currentUserId = UserSession.userId;

  Future<List<Invoice>> _fetchInvoices() async {
    return await _sqlDb.getAllInvoices(currentUserId);
  }

  double _getTotalAmount(List<Invoice> invoices) {
    return invoices.fold(0.0, (sum, invoice) => sum + invoice.amount);
  }

  int _getPaidCount(List<Invoice> invoices) {
    return invoices.where((invoice) => invoice.status == 'مدفوعة').length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('الفواتير'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'تحديث',
          ),
        ],
      ),
      drawer: const Navbar(),
      body: RefreshIndicator(
        onRefresh: _fetchInvoices,
        child: FutureBuilder<List<Invoice>>(
          future: _fetchInvoices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return CustomErrorState(
                message: 'حدث خطأ: ${snapshot.error}',
                onRetry: () => setState(() {}),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return CustomEmptyState(
                title: 'لا توجد فواتير مضافة بعد',
                subtitle: 'اضغط على زر + لإضافة أول فاتورة',
                icon: Icons.receipt_long_outlined,
                buttonText: 'إضافة فاتورة',
                onButtonPressed: () {
                  Navigator.pushNamed(context, RoutesNames.addInvoice)
                      .then((_) => setState(() {}));
                },
              );
            }

            final invoices = snapshot.data!;
            final totalAmount = _getTotalAmount(invoices);
            final paidCount = _getPaidCount(invoices);

            return Column(
              children: [
                // بطاقة إحصائية
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('إجمالي الفواتير', style: theme.textTheme.bodySmall),
                          Text(
                            '${invoices.length}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('مدفوعة', style: theme.textTheme.bodySmall),
                          Text(
                            '$paidCount',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('الإجمالي (د.ل)', style: theme.textTheme.bodySmall),
                          Text(
                            '${totalAmount.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: invoices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final invoice = invoices[index];
                      return CustomInvoiceCard(
                        invoice: invoice,
                        onEdit: () {
                          Navigator.pushNamed(context, RoutesNames.editInvoice, arguments: invoice)
                              .then((_) => setState(() {}));
                        },
                        onDelete: () async {
                          await _sqlDb.deleteInvoice(invoice.id!, currentUserId);
                          if (mounted) setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RoutesNames.addInvoice).then((_) => setState(() {}));
        },
        backgroundColor: colorScheme.secondary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.receipt_long),
      ),
    );
  }
}
