import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../services/transaction_service.dart';
import 'transaction_detail_page.dart';

class TransactionHistoryPage extends StatefulWidget {
  final String contextId;
  const TransactionHistoryPage({super.key, required this.contextId});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final _service = TransactionService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filtered = [];
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _offset = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filtered = List.from(_allTransactions);
      } else {
        _filtered = _allTransactions.where((tx) {
          final merchant = (tx.merchant ?? '').toLowerCase();
          final category = tx.category.toLowerCase();
          return merchant.contains(query) || category.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _error = null;
      _offset = 0;
      _allTransactions = [];
      _filtered = [];
      _hasMore = true;
    });
    try {
      final result = await _service.list(
        contextId: widget.contextId,
        limit: _pageSize,
        offset: 0,
      );
      setState(() {
        _allTransactions = result;
        _offset = result.length;
        _hasMore = result.length == _pageSize;
        _loading = false;
      });
      _applySearch();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final result = await _service.list(
        contextId: widget.contextId,
        limit: _pageSize,
        offset: _offset,
      );
      setState(() {
        _allTransactions.addAll(result);
        _offset += result.length;
        _hasMore = result.length == _pageSize;
        _loadingMore = false;
      });
      _applySearch();
    } catch (e) {
      setState(() => _loadingMore = false);
    }
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
          'Riwayat Transaksi',
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
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari merchant atau kategori...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: AppColors.backgroundLight,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.gold, width: 1.5),
                ),
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
                              onPressed: _loadInitial,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _filtered.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada transaksi',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadInitial,
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 100),
                              itemCount:
                                  _filtered.length + (_loadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _filtered.length) {
                                  return const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                }
                                return _buildTransactionItem(_filtered[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    final iconData = _categoryIcon(tx.category);
    final iconColor = _categoryColor(tx.category);
    final iconBg = iconColor.withValues(alpha: 0.12);
    final tagColor = tx.reimbursementStatus == 'pending'
        ? const Color(0xFFD97706)
        : AppColors.slateBlue;

    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) =>
                    TransactionDetailPage(transaction: tx),
              ),
            )
            .then((_) => _loadInitial());
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
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: tagColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tx.reimbursementLabel,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: tagColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
