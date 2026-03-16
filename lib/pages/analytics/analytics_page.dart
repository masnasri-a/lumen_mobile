import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/ai_insight_model.dart';
import '../../providers/context_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/ai_service.dart';
import '../../services/export_service.dart';
import 'ai_insight_page.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _selectedPeriod = 1; // 0=Minggu, 1=Bulan, 2=Tahun
  final int _selectedContext = 0;
  final _aiService = AiService();
  final _exportService = ExportService();
  AiInsightModel? _insight;
  bool _insightLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final ctxProvider = context.read<ContextProvider>();
    final txProvider = context.read<TransactionProvider>();
    final ctx = ctxProvider.contextForTab(_selectedContext);
    if (ctx != null) {
      await Future.wait([
        txProvider.fetchSummary(contextId: ctx.id),
        txProvider.fetchCategories(contextId: ctx.id, month: _currentMonth()),
      ]);
      _loadInsight(ctx.id);
    }
  }

  Future<void> _loadInsight(String contextId) async {
    if (!mounted) return;
    setState(() => _insightLoading = true);
    try {
      final insight = await _aiService.getInsight(contextId: contextId);
      if (mounted) setState(() => _insight = insight);
    } catch (_) {
      // silently fail — show empty state
    } finally {
      if (mounted) setState(() => _insightLoading = false);
    }
  }

  Future<void> _showExportSheet() async {
    final ctxProvider = context.read<ContextProvider>();
    final ctx = ctxProvider.contextForTab(_selectedContext);
    if (ctx == null) return;

    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExportSheet(
        contextId: ctx.id,
        defaultFrom: firstOfMonth,
        defaultTo: now,
        exportService: _exportService,
      ),
    );
  }

  String _currentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  String _formattedMonth() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = context.watch<TransactionProvider>();
    final categories = txProvider.categories;
    final summary = txProvider.summary;

    final now = DateTime.now();
    final currentMonthKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final currentSummary =
        summary.where((s) => s.month == currentMonthKey).firstOrNull;
    final prevMonthKey = now.month == 1
        ? '${now.year - 1}-12'
        : '${now.year}-${(now.month - 1).toString().padLeft(2, '0')}';
    final prevSummary =
        summary.where((s) => s.month == prevMonthKey).firstOrNull;

    final totalAmount = currentSummary?.totalAmount ?? 0;
    final prevAmount = prevSummary?.totalAmount ?? 0;
    final changePercent = prevAmount > 0
        ? ((totalAmount - prevAmount) / prevAmount * 100).toStringAsFixed(1)
        : null;

    final maxCategory =
        categories.isNotEmpty ? categories.first.totalAmount : 1;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Analitik',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        fontFamily: 'DMSerifDisplay',
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _showExportSheet,
                          icon: const Icon(Icons.download_outlined),
                          color: AppColors.textDark,
                          tooltip: 'Export CSV',
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Text(_formattedMonth(),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(width: 4),
                              Icon(Icons.calendar_today,
                                  size: 16, color: Colors.grey.shade600),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Period tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildPeriodTab('Minggu', 0),
                      _buildPeriodTab('Bulan', 1),
                      _buildPeriodTab('Tahun', 2),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // AI Insight card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                      left: BorderSide(color: AppColors.gold, width: 3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.auto_awesome,
                              color: AppColors.gold, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'LUMEN AI INSIGHT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_insightLoading)
                        const SizedBox(
                          height: 20,
                          child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.gold, strokeWidth: 2),
                          ),
                        )
                      else if (_insight != null) ...[
                        Text(
                          _insight!.insight.length > 120
                              ? '${_insight!.insight.substring(0, 120)}...'
                              : _insight!.insight,
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.5),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const AiInsightPage()),
                          ),
                          child: const Text(
                            'Lihat Selengkapnya →',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Belum ada insight. Generate sekarang.',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            final ctx = context
                                .read<ContextProvider>()
                                .contextForTab(_selectedContext);
                            if (ctx != null) _loadInsight(ctx.id);
                          },
                          icon: const Icon(Icons.auto_awesome,
                              size: 16, color: AppColors.gold),
                          label: const Text('Generate Insight',
                              style: TextStyle(color: AppColors.gold)),
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Summary cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Pengeluaran',
                        _formatAmount(totalAmount),
                        changePercent != null
                            ? '${double.parse(changePercent) >= 0 ? '↑' : '↓'} ${changePercent.replaceAll('-', '')}% vs Bulan Lalu'
                            : 'Bulan ini',
                        changePercent != null && double.parse(changePercent) >= 0
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Transaksi',
                        '${currentSummary?.count ?? 0}',
                        'Total transaksi',
                        AppColors.slateBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Trend chart (monthly)
              if (summary.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tren Pengeluaran',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 160,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: summary.reversed.take(6).map((s) {
                              final maxVal = summary
                                  .map((x) => x.totalAmount)
                                  .reduce((a, b) => a > b ? a : b);
                              final ratio =
                                  maxVal > 0 ? s.totalAmount / maxVal : 0.0;
                              final label = s.month.substring(5); // MM
                              return _buildChartBar(label, ratio.toDouble());
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              // Rincian Kategori
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const Text('Rincian Kategori',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              if (txProvider.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (categories.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('Belum ada data kategori bulan ini',
                        style: TextStyle(color: Colors.grey.shade500)),
                  ),
                )
              else
                ...categories.map((cat) {
                  final ratio =
                      maxCategory > 0 ? cat.totalAmount / maxCategory : 0.0;
                  final color = _categoryColor(cat.category);
                  final pct = totalAmount > 0
                      ? (cat.totalAmount / totalAmount * 100)
                          .toStringAsFixed(0)
                      : '0';
                  return _buildCategoryItem(
                    _categoryIcon(cat.category),
                    cat.category,
                    cat.formattedTotal,
                    '$pct%',
                    ratio.toDouble(),
                    color,
                  );
                }),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodTab(String label, int index) {
    final isActive = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, String change, Color changeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DMSerifDisplay')),
          const SizedBox(height: 4),
          Text(change,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: changeColor)),
        ],
      ),
    );
  }

  Widget _buildChartBar(String label, double ratio) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 120 * ratio,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String name, String amount,
      String percentage, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade100,
                    color: color,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              Text(percentage,
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
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

// ── Export Sheet ─────────────────────────────────────────────────────────────

class _ExportSheet extends StatefulWidget {
  final String contextId;
  final DateTime defaultFrom;
  final DateTime defaultTo;
  final ExportService exportService;

  const _ExportSheet({
    required this.contextId,
    required this.defaultFrom,
    required this.defaultTo,
    required this.exportService,
  });

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  late DateTime _from;
  late DateTime _to;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _from = widget.defaultFrom;
    _to = widget.defaultTo;
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _export() async {
    setState(() => _exporting = true);
    final success = await widget.exportService.exportAndShare(
      contextId: widget.contextId,
      dateFrom: _from,
      dateTo: _to,
    );
    if (!mounted) return;
    setState(() => _exporting = false);
    Navigator.of(context).pop();
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengekspor data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Export CSV',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _from,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _from = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dari',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500)),
                        const SizedBox(height: 4),
                        Text(_fmtDate(_from),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _to,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _to = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sampai',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500)),
                        const SizedBox(height: 4),
                        Text(_fmtDate(_to),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _exporting ? null : _export,
              style: AppStyles.goldButton,
              child: _exporting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Export'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
