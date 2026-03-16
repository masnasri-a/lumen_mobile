import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/context_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../transaction/transaction_detail_page.dart';
import '../transaction/scan_receipt_page.dart';
import '../transaction/add_transaction_page.dart';
import '../transaction/transaction_history_page.dart';
import '../transaction/reimbursement_page.dart';

class HomeTab extends StatefulWidget {
  final String userName;

  const HomeTab({super.key, required this.userName});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _selectedContext = 0;
  late final PageController _cardController = PageController();

  // ── Card configs per context ─────────────────────────────────────────────

  static const _cardConfigs = [
    _CardConfig(
      gradientColors: [Color(0xFF3A3530), Color(0xFF2A2520)],
      accentColor: AppColors.gold,
      label: 'PENGELUARAN SAYA',
      subtitleIcon: Icons.person_outline,
      subtitle: 'Akun Personal',
    ),
    _CardConfig(
      gradientColors: [Color(0xFF4A2545), Color(0xFF321730)],
      accentColor: Color(0xFFE879A0),
      label: 'PENGELUARAN BERSAMA',
      subtitleIcon: Icons.favorite_border,
      subtitle: 'Akun Pasangan',
    ),
    _CardConfig(
      gradientColors: [Color(0xFF1A3050), Color(0xFF0D1E35)],
      accentColor: Color(0xFF60A5FA),
      label: 'PENGELUARAN TIM',
      subtitleIcon: Icons.business_outlined,
      subtitle: 'Tim Kantor',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Pre-load all contexts so swipe is instant
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAllContexts());
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  /// Load all 3 contexts in parallel on init / pull-to-refresh.
  Future<void> _loadAllContexts() async {
    final ctxProvider = context.read<ContextProvider>();
    final txProvider = context.read<TransactionProvider>();
    final futures = <Future>[];
    for (int i = 0; i < 3; i++) {
      final ctx = ctxProvider.contextForTab(i);
      if (ctx != null) {
        futures.add(txProvider.fetchTransactions(contextId: ctx.id));
        futures.add(txProvider.fetchSummary(contextId: ctx.id));
      }
    }
    await Future.wait(futures);
  }

  /// Pull-to-refresh — reload active context only for speed, then the others.
  Future<void> _loadData() => _loadAllContexts();

  /// Called when a tab pill is tapped — drives the PageView.
  void _onContextTabChanged(int index) {
    if (_selectedContext == index) return;
    setState(() => _selectedContext = index);
    _cardController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    _ensureContextLoaded(index);
  }

  /// Called when the PageView settles — drives the tab pills.
  void _onCardPageChanged(int index) {
    setState(() => _selectedContext = index);
    _ensureContextLoaded(index);
  }

  /// Fetch only if not yet cached.
  void _ensureContextLoaded(int tabIndex) {
    final ctx = context.read<ContextProvider>().contextForTab(tabIndex);
    if (ctx == null) return;
    final txProvider = context.read<TransactionProvider>();
    if (txProvider.transactionsFor(ctx.id).isEmpty) {
      txProvider.fetchTransactions(contextId: ctx.id);
      txProvider.fetchSummary(contextId: ctx.id);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final ctxProvider = context.watch<ContextProvider>();
    final txProvider = context.watch<TransactionProvider>();

    final activeCtx = ctxProvider.contextForTab(_selectedContext);
    final activeCtxId = activeCtx?.id;
    final activeTxs = activeCtxId != null
        ? txProvider.transactionsFor(activeCtxId)
        : <TransactionModel>[];
    final activeCfg = _cardConfigs[_selectedContext];

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat pagi,',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade500),
                          ),
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                              fontFamily: 'DMSerifDisplay',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Icon(Icons.notifications_outlined,
                          color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Context tab pills ────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildContextTab('Personal', 0),
                    const SizedBox(width: 8),
                    _buildContextTab('Pasangan', 1),
                    const SizedBox(width: 8),
                    _buildContextTab('Tim Kantor', 2),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Swipeable expense cards ──────────────────────────────────
              SizedBox(
                height: 200,
                child: PageView.builder(
                  controller: _cardController,
                  itemCount: 3,
                  onPageChanged: _onCardPageChanged,
                  itemBuilder: (context, index) {
                    final cfg = _cardConfigs[index];
                    final ctx = ctxProvider.contextForTab(index);
                    final ctxId = ctx?.id;
                    final txs = ctxId != null
                        ? txProvider.transactionsFor(ctxId)
                        : <TransactionModel>[];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _buildExpenseCard(
                        cfg: cfg,
                        ctxId: ctxId,
                        txCount: txs.length,
                        pendingCount: txs
                            .where((t) => t.reimbursementStatus == 'pending')
                            .length,
                        loading: txProvider.loading,
                        formatted: ctxId != null
                            ? txProvider.formattedTotalFor(ctxId)
                            : 'Rp 0',
                      ),
                    );
                  },
                ),
              ),

              // ── Dot indicator ────────────────────────────────────────────
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _selectedContext == i ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _selectedContext == i
                          ? activeCfg.accentColor
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Quick actions ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickAction(Icons.camera_alt_outlined, 'Scan\nStruk',
                        onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ScanReceiptPage()));
                    }),
                    _buildQuickAction(Icons.edit_outlined, 'Catat\nManual',
                        onTap: () {
                      final activeCtxNow = context
                          .read<ContextProvider>()
                          .contextForTab(_selectedContext);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => AddTransactionPage(
                            defaultContextId: activeCtxNow?.id),
                      ).then((_) => _loadData());
                    }),
                    _buildQuickAction(Icons.mic_outlined, 'Input\nSuara'),
                    _buildQuickAction(
                        Icons.receipt_long_outlined, 'Reimburse',
                        onTap: () {
                      final activeCtxNow = context
                          .read<ContextProvider>()
                          .contextForTab(_selectedContext);
                      if (activeCtxNow != null) {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                              builder: (_) => ReimbursementPage(
                                  contextId: activeCtxNow.id),
                            ))
                            .then((_) => _loadData());
                      }
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Recent transactions header ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedContext == 1
                          ? 'Transaksi Bersama'
                          : _selectedContext == 2
                              ? 'Transaksi Tim'
                              : 'Transaksi Terbaru',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        fontFamily: 'DMSerifDisplay',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (activeCtxId != null) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                TransactionHistoryPage(contextId: activeCtxId),
                          ));
                        }
                      },
                      child: Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: activeCfg.accentColor == AppColors.gold
                              ? AppColors.slateBlue
                              : activeCfg.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Transaction list ─────────────────────────────────────────
              if (txProvider.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (activeCtxId == null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: _buildCreateContextBanner(
                    ctxProvider,
                    activeCfg,
                  ),
                )
              else if (activeTxs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Belum ada transaksi',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                )
              else
                ...activeTxs.take(10).map((tx) => _buildTransactionItem(tx)),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Future<void> _createCurrentContext(ContextProvider ctxProvider) async {
    final type = _selectedContext == 1 ? 'couple' : 'team';
    final name = _selectedContext == 1 ? 'Pasangan' : 'Tim Kantor';
    final created = await ctxProvider.createContext(name: name, type: type);
    if (created != null) {
      _ensureContextLoaded(_selectedContext);
    }
  }

  Widget _buildCreateContextBanner(
      ContextProvider ctxProvider, _CardConfig cfg) {
    final isCouple = _selectedContext == 1;
    final label = isCouple ? 'Belum ada akun pasangan' : 'Belum bergabung ke tim';
    final btnLabel = isCouple ? 'Buat Akun Pasangan' : 'Buat Tim Kantor';
    final icon = isCouple ? Icons.favorite_border : Icons.business_outlined;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: cfg.accentColor),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCouple
                ? 'Catat pengeluaran bersama pasangan secara transparan.'
                : 'Kelola pengeluaran tim dan approval reimbursement.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _createCurrentContext(ctxProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: cfg.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(btnLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard({
    required _CardConfig cfg,
    required String? ctxId,
    required int txCount,
    required int pendingCount,
    required bool loading,
    required String formatted,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cfg.gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              bottom: -40,
              left: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(cfg.subtitleIcon,
                          size: 12, color: cfg.accentColor),
                      const SizedBox(width: 4),
                      Text(
                        cfg.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cfg.accentColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  loading
                      ? const SizedBox(
                          height: 36,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          ctxId == null ? 'Belum tersedia' : formatted,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: 'DMSerifDisplay',
                          ),
                        ),
                  const SizedBox(height: 20),
                  Container(height: 0.5, color: Colors.white24),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildCardStat('Transaksi', '$txCount')),
                      Expanded(
                        child: _buildCardStat(
                          'Reimburse',
                          '$pendingCount',
                          valueColor: pendingCount > 0
                              ? const Color(0xFFEF4444)
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardStat(String label, String value,
      {Color valueColor = Colors.white}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.5))),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: valueColor)),
      ],
    );
  }

  Widget _buildContextTab(String label, int index) {
    final isActive = _selectedContext == index;
    final activeAccent = _cardConfigs[index].accentColor;
    return GestureDetector(
      onTap: () => _onContextTabChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? activeAccent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(icon, size: 28, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    final iconData = _categoryIcon(tx.category);
    final iconColor = _categoryColor(tx.category);
    final tagColor = tx.reimbursementStatus == 'pending'
        ? const Color(0xFFD97706)
        : AppColors.slateBlue;

    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (_) => TransactionDetailPage(transaction: tx),
            ))
            .then((_) => _loadData());
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
                  color: iconColor.withValues(alpha: 0.12),
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

class _CardConfig {
  final List<Color> gradientColors;
  final Color accentColor;
  final String label;
  final IconData subtitleIcon;
  final String subtitle;

  const _CardConfig({
    required this.gradientColors,
    required this.accentColor,
    required this.label,
    required this.subtitleIcon,
    required this.subtitle,
  });
}
