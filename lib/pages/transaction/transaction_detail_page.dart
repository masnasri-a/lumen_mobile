import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import 'add_transaction_page.dart';

class TransactionDetailPage extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late TransactionModel _tx;

  @override
  void initState() {
    super.initState();
    _tx = widget.transaction;
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final ok = await context.read<TransactionProvider>().deleteTransaction(_tx.id);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true); // signal refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<TransactionProvider>().error ?? 'Gagal menghapus'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _updateReimbursement(String status) async {
    final ok = await context
        .read<TransactionProvider>()
        .updateReimbursement(_tx.id, status);
    if (!mounted) return;
    if (ok) {
      final updated = context
          .read<TransactionProvider>()
          .transactions
          .firstWhere((t) => t.id == _tx.id, orElse: () => _tx);
      setState(() => _tx = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(status == 'approved' ? 'Reimburse disetujui' : 'Reimburse ditolak')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Detail Transaksi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Text(
                _tx.formattedAmount,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'DMSerifDisplay',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(child: _buildStatusBadge()),
            const SizedBox(height: 32),
            // Merchant info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EAE0),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.storefront_outlined,
                        color: AppColors.gold, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tx.merchant ?? _tx.category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text('Merchant',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(Icons.calendar_today_outlined, 'Tanggal',
                _formatDate(_tx.transactionDate)),
            _buildDetailRow(Icons.category_outlined, 'Kategori', _tx.category),
            _buildDetailRow(Icons.people_outline, 'Konteks', _tx.contextId),
            if (_tx.notes != null && _tx.notes!.isNotEmpty)
              _buildDetailRow(Icons.notes_outlined, 'Catatan', _tx.notes!),
            if (_tx.isPrivate)
              _buildDetailRow(Icons.lock_outline, 'Visibilitas', 'Privat'),
            const SizedBox(height: 24),
            // Reimbursement section
            if (_tx.isReimbursable) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('REIMBURSEMENT',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        letterSpacing: 1.0)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Status',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade500)),
                          _buildReimburseBadge(_tx.reimbursementStatus),
                        ],
                      ),
                      if (_tx.reimbursementStatus == 'pending') ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    _updateReimbursement('rejected'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Tolak'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    _updateReimbursement('approved'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22C55E),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Setujui',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Struk Digital
            if (_tx.receiptUrl != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('STRUK DIGITAL',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        letterSpacing: 1.0)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    _tx.receiptUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                          child: Icon(Icons.broken_image_outlined, size: 48)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Ubah Transaksi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final provider = context.read<TransactionProvider>();
                    final updated = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AddTransactionPage(
                        defaultContextId: _tx.contextId,
                        editTransaction: _tx,
                      ),
                    );
                    if (updated == true && mounted) {
                      final fresh = provider.transactions.firstWhere(
                        (t) => t.id == _tx.id,
                        orElse: () => _tx,
                      );
                      setState(() => _tx = fresh);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text('Ubah Transaksi',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 16, color: Color(0xFF22C55E)),
          SizedBox(width: 6),
          Text('BERHASIL',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF22C55E),
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildReimburseBadge(String status) {
    final (label, color) = switch (status) {
      'approved' => ('DISETUJUI', const Color(0xFF22C55E)),
      'rejected' => ('DITOLAK', Colors.redAccent),
      _ => ('MENUNGGU', AppColors.gold),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Text(label,
              style:
                  TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}, '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
