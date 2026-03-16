import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/context_provider.dart';
import '../../providers/transaction_provider.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    final ctxProvider = context.read<ContextProvider>();
    final txProvider = context.read<TransactionProvider>();
    final futures = <Future>[];
    for (final ctx in ctxProvider.contexts) {
      futures.add(txProvider.fetchSummary(contextId: ctx.id));
    }
    if (futures.isNotEmpty) await Future.wait(futures);
  }

  String _formatAmount(int amount) {
    if (amount == 0) return 'Rp 0';
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp ${buf.toString()}';
  }

  String _currentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String _formattedMonthLabel() {
    final now = DateTime.now();
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ctxProvider = context.watch<ContextProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final currentMonth = _currentMonth();

    // Total across all contexts (from summary)
    final total = txProvider.summary
        .where((s) => s.month == currentMonth)
        .fold(0, (sum, s) => sum + s.totalAmount);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dompet',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'DMSerifDisplay',
                ),
              ),
              const SizedBox(height: 4),
              Text(_formattedMonthLabel(),
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
              const SizedBox(height: 24),

              // Total spending card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3A3530), Color(0xFF2A2520)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PENGELUARAN BULAN INI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    txProvider.loading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : Text(
                            _formatAmount(total),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'DMSerifDisplay',
                            ),
                          ),
                    const SizedBox(height: 20),
                    Container(height: 0.5, color: Colors.grey.shade700),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Konteks Aktif',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500)),
                              const SizedBox(height: 4),
                              Text('${ctxProvider.contexts.length}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Transaksi',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500)),
                              const SizedBox(height: 4),
                              Text(
                                  '${txProvider.summary.where((s) => s.month == currentMonth).fold(0, (sum, s) => sum + s.count)}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Konteks section
              const Text('Konteks Keuangan',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      fontFamily: 'DMSerifDisplay')),
              const SizedBox(height: 16),

              if (ctxProvider.contexts.isEmpty)
                Center(
                  child: Text('Belum ada konteks',
                      style: TextStyle(color: Colors.grey.shade500)),
                )
              else
                ...ctxProvider.contexts.map((ctx) {
                  final (icon, color) = switch (ctx.type) {
                    'couple' => (Icons.favorite_outline, const Color(0xFFEC4899)),
                    'team' => (Icons.groups_outlined, const Color(0xFF6366F1)),
                    _ => (Icons.person_outline, AppColors.gold),
                  };
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ctx.name,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              Text(ctx.type,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            color: Colors.grey.shade400),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 28),

              // Tren 6 bulan
              if (txProvider.summary.isNotEmpty) ...[
                const Text('Tren 6 Bulan',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        fontFamily: 'DMSerifDisplay')),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 140,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: () {
                            final sorted = [...txProvider.summary]
                              ..sort((a, b) => a.month.compareTo(b.month));
                            final last6 = sorted.length > 6
                                ? sorted.sublist(sorted.length - 6)
                                : sorted;
                            final maxVal = last6.isEmpty
                                ? 1
                                : last6
                                    .map((s) => s.totalAmount)
                                    .reduce((a, b) => a > b ? a : b);
                            return last6.map((s) {
                              final ratio =
                                  maxVal > 0 ? s.totalAmount / maxVal : 0.0;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 100 * ratio,
                                    decoration: BoxDecoration(
                                      color: s.month == currentMonth
                                          ? AppColors.gold
                                          : const Color(0xFFE8D5B0),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(s.month.substring(5),
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade500)),
                                ],
                              );
                            }).toList();
                          }(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
