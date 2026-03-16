import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/context_provider.dart';
import '../../services/recurring_service.dart';

class RecurringPage extends StatefulWidget {
  const RecurringPage({super.key});

  @override
  State<RecurringPage> createState() => _RecurringPageState();
}

class _RecurringPageState extends State<RecurringPage> {
  final _service = RecurringService();
  List<RecurringModel> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.list();
      if (mounted) setState(() => _items = list);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(RecurringModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Tagihan?'),
        content: Text(
            'Hapus "${item.merchant ?? item.category}" dari daftar tagihan berulang?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus',
                  style: TextStyle(color: Color(0xFFEF4444)))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _service.delete(item.id);
      setState(() => _items.removeWhere((r) => r.id == item.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddRecurringSheet(
        onCreated: (item) {
          setState(() => _items.insert(0, item));
        },
      ),
    );
  }

  // Group items by interval
  Map<String, List<RecurringModel>> get _grouped {
    final order = ['monthly', 'weekly', 'yearly', 'daily'];
    final map = <String, List<RecurringModel>>{};
    for (final item in _items) {
      map.putIfAbsent(item.interval, () => []).add(item);
    }
    return Map.fromEntries(
      order
          .where((k) => map.containsKey(k))
          .map((k) => MapEntry(k, map[k]!)),
    );
  }

  int get _monthlyTotal => _items
      .where((r) => r.active && r.interval == 'monthly')
      .fold(0, (sum, r) => sum + r.amount);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tagihan Berulang',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                              fontFamily: 'DMSerifDisplay',
                            ),
                          ),
                          Text(
                            'Pantau semua tagihan rutin Anda',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _showAddSheet,
                      icon: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.darkButton,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Summary card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: _buildSummaryCard(),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                    child: Text(_error!,
                        style: TextStyle(color: Colors.grey.shade500))),
              )
            else if (_items.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.repeat_outlined,
                          size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada tagihan berulang',
                        style:
                            TextStyle(fontSize: 15, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tambahkan tagihan rutin seperti Netflix,\nlistrik, atau cicilan.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _showAddSheet,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Tambah Tagihan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkButton,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              for (final entry in _grouped.entries) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _intervalGroupLabel(entry.key),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.value.length} tagihan',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 4),
                      child: _buildBillCard(entry.value[i]),
                    ),
                    childCount: entry.value.length,
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final activeCount = _items.where((r) => r.active).length;
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.repeat, size: 12, color: AppColors.gold),
              const SizedBox(width: 4),
              Text(
                'ESTIMASI TAGIHAN BULANAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatAmount(_monthlyTotal),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'DMSerifDisplay',
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 0.5, color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Tagihan',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5))),
                    const SizedBox(height: 4),
                    Text('${_items.length}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aktif',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5))),
                    const SizedBox(height: 4),
                    Text('$activeCount',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: activeCount > 0
                                ? const Color(0xFF4ADE80)
                                : Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(RecurringModel item) {
    final daysLeft = item.nextRun.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 3;
    const iconMap = {
      'makan': Icons.restaurant,
      'transport': Icons.directions_car,
      'hiburan': Icons.movie_outlined,
      'kesehatan': Icons.medical_services_outlined,
      'belanja': Icons.shopping_cart_outlined,
    };
    final icon = iconMap[item.category.toLowerCase()] ?? Icons.repeat;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUrgent
            ? Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3))
            : null,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: item.active
                ? AppColors.gold.withValues(alpha: 0.12)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon,
              color:
                  item.active ? AppColors.gold : Colors.grey.shade400,
              size: 22),
        ),
        title: Text(
          item.merchant ?? item.category,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color:
                item.active ? AppColors.textDark : Colors.grey.shade400,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(item.intervalLabel,
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade600)),
              ),
              const SizedBox(width: 6),
              Text(
                isUrgent
                    ? (daysLeft == 0 ? 'Hari ini!' : '$daysLeft hari lagi')
                    : item.nextRunFormatted,
                style: TextStyle(
                  fontSize: 11,
                  color: isUrgent
                      ? const Color(0xFFEF4444)
                      : Colors.grey.shade500,
                  fontWeight:
                      isUrgent ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.formattedAmount,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _delete(item),
              child: Icon(Icons.delete_outline,
                  size: 18, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  String _intervalGroupLabel(String interval) {
    switch (interval) {
      case 'daily':
        return 'Harian';
      case 'weekly':
        return 'Mingguan';
      case 'monthly':
        return 'Bulanan';
      case 'yearly':
        return 'Tahunan';
      default:
        return interval;
    }
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
}

// ── Add Recurring Bottom Sheet ─────────────────────────────────────────────

class _AddRecurringSheet extends StatefulWidget {
  final void Function(RecurringModel) onCreated;

  const _AddRecurringSheet({required this.onCreated});

  @override
  State<_AddRecurringSheet> createState() => _AddRecurringSheetState();
}

class _AddRecurringSheetState extends State<_AddRecurringSheet> {
  final _merchantCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _interval = 'monthly';
  String _category = 'Lainnya';
  bool _submitting = false;

  final _intervals = ['monthly', 'weekly', 'yearly', 'daily'];
  final _intervalLabels = {
    'monthly': 'Bulanan',
    'weekly': 'Mingguan',
    'yearly': 'Tahunan',
    'daily': 'Harian',
  };
  final _categories = [
    'Makan', 'Transport', 'Hiburan', 'Kesehatan',
    'Belanja', 'Langganan', 'Utilitas', 'Lainnya'
  ];

  @override
  void dispose() {
    _merchantCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final merchant = _merchantCtrl.text.trim();
    final amountStr = _amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (merchant.isEmpty || amountStr.isEmpty) return;

    final ctxProvider = context.read<ContextProvider>();
    final ctx = ctxProvider.personalContext;
    if (ctx == null) return;

    setState(() => _submitting = true);
    try {
      final nextRun = _nextRunFromInterval(_interval);
      final item = await RecurringService().create(
        contextId: ctx.id,
        amount: int.parse(amountStr),
        category: _category.toLowerCase(),
        merchant: merchant,
        interval: _interval,
        nextRun: nextRun,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onCreated(item);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  DateTime _nextRunFromInterval(String interval) {
    final now = DateTime.now();
    switch (interval) {
      case 'daily':
        return now.add(const Duration(days: 1));
      case 'weekly':
        return now.add(const Duration(days: 7));
      case 'yearly':
        return DateTime(now.year + 1, now.month, now.day);
      default:
        return DateTime(now.year, now.month + 1, now.day);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tambah Tagihan Berulang',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              fontFamily: 'DMSerifDisplay',
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _merchantCtrl,
            decoration: AppStyles.inputDecoration(hintText: 'Nama tagihan (cth: Netflix, PLN)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: AppStyles.inputDecoration(hintText: 'Jumlah (Rp)'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  value: _interval,
                  items: _intervals,
                  labelOf: (v) => _intervalLabels[v] ?? v,
                  onChanged: (v) => setState(() => _interval = v!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  value: _category,
                  items: _categories,
                  labelOf: (v) => v,
                  onChanged: (v) => setState(() => _category = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkButton,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan',
                      style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String Function(String) labelOf,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1E8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              size: 18, color: Colors.grey.shade500),
          items: items.map((v) {
            return DropdownMenuItem(
                value: v,
                child:
                    Text(labelOf(v), style: const TextStyle(fontSize: 14)));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
