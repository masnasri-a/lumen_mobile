import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../services/transaction_service.dart';
import 'transaction_detail_page.dart';

class ReimbursementPage extends StatefulWidget {
  final String contextId;
  const ReimbursementPage({super.key, required this.contextId});

  @override
  State<ReimbursementPage> createState() => _ReimbursementPageState();
}

class _ReimbursementPageState extends State<ReimbursementPage> {
  final _service = TransactionService();

  List<TransactionModel> _transactions = [];
  List<ReimbursementSummaryItem> _summary = [];
  bool _loading = false;
  String? _error;
  int _selectedTab = 0; // 0=Semua, 1=Pending, 2=Disetujui, 3=Ditolak

  static const _tabs = ['Semua', 'Pending', 'Disetujui', 'Ditolak'];
  static const _statusMap = ['', 'pending', 'approved', 'rejected'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final status = _statusMap[_selectedTab];
      final results = await Future.wait([
        _service.list(
          contextId: widget.contextId,
          isReimbursable: true,
          reimbursementStatus: status.isEmpty ? null : status,
          limit: 100,
          offset: 0,
        ),
        _service.reimbursementSummary(contextId: widget.contextId),
      ]);
      setState(() {
        _transactions = results[0] as List<TransactionModel>;
        _summary = results[1] as List<ReimbursementSummaryItem>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  int _countFor(String status) {
    final item = _summary.where((s) => s.status == status).firstOrNull;
    return item?.count ?? 0;
  }

  int _totalFor(String status) {
    final item = _summary.where((s) => s.status == status).firstOrNull;
    return item?.totalAmount ?? 0;
  }

  String _formatAmount(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp ${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        centerTitle: false,
        title: const Text(
          'Reimbursement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            fontFamily: 'DMSerifDisplay',
          ),
        ),
      ),
      body: Column(
        children: [
          // Summary stats cards
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _buildStatCard('Pending', _countFor('pending'),
                    _formatAmount(_totalFor('pending')), const Color(0xFFD97706)),
                const SizedBox(width: 8),
                _buildStatCard('Disetujui', _countFor('approved'),
                    _formatAmount(_totalFor('approved')), const Color(0xFF22C55E)),
                const SizedBox(width: 8),
                _buildStatCard('Ditolak', _countFor('rejected'),
                    _formatAmount(_totalFor('rejected')), Colors.redAccent),
              ],
            ),
          ),
          // Filter tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (i) {
                  final isActive = _selectedTab == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (_selectedTab == i) return;
                        setState(() => _selectedTab = i);
                        _loadData();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.gold
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? AppColors.gold
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          _tabs[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Gagal memuat data',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _loadData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _transactions.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada transaksi',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 100),
                              itemCount: _transactions.length,
                              itemBuilder: (context, index) =>
                                  _buildItem(_transactions[index]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, int count, String total, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color),
            ),
            const SizedBox(height: 4),
            Text(
              '$count item',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
            const SizedBox(height: 2),
            Text(
              total,
              style: TextStyle(
                  fontSize: 10,
                  color: color.withValues(alpha: 0.8)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(TransactionModel tx) {
    final iconData = _categoryIcon(tx.category);
    final iconColor = _categoryColor(tx.category);
    final iconBg = iconColor.withValues(alpha: 0.12);

    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) =>
                    TransactionDetailPage(transaction: tx),
              ),
            )
            .then((_) => _loadData());
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(iconData, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.merchant ?? tx.category,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tx.category} • ${tx.formattedDate}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-${tx.formattedAmount}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusBadge(tx.reimbursementStatus),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final (label, color) = switch (status) {
      'approved' => ('Disetujui', const Color(0xFF22C55E)),
      'rejected' => ('Ditolak', Colors.redAccent),
      'pending' => ('Pending', const Color(0xFFD97706)),
      _ => ('Menunggu', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makan':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'hiburan':
        return Icons.movie_outlined;
      case 'kesehatan':
        return Icons.medical_services_outlined;
      case 'belanja':
        return Icons.shopping_cart_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makan':
        return const Color(0xFFEF4444);
      case 'transport':
        return const Color(0xFF6366F1);
      case 'hiburan':
        return const Color(0xFFF59E0B);
      case 'kesehatan':
        return const Color(0xFF10B981);
      case 'belanja':
        return const Color(0xFF22C55E);
      default:
        return AppColors.gold;
    }
  }
}
