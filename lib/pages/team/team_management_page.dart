import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/context_provider.dart';
import '../../providers/transaction_provider.dart';
import '../transaction/reimbursement_page.dart';
import '../transaction/transaction_history_page.dart';

class TeamManagementPage extends StatefulWidget {
  const TeamManagementPage({super.key});

  @override
  State<TeamManagementPage> createState() => _TeamManagementPageState();
}

class _TeamManagementPageState extends State<TeamManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final ctxProvider = context.read<ContextProvider>();
    final txProvider = context.read<TransactionProvider>();
    final team = ctxProvider.teamContext;
    if (team == null) return;
    await Future.wait([
      txProvider.fetchTransactions(contextId: team.id),
      txProvider.fetchSummary(contextId: team.id),
    ]);
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

  @override
  Widget build(BuildContext context) {
    final ctxProvider = context.watch<ContextProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final team = ctxProvider.teamContext;

    if (team == null) {
      return SafeArea(
        child: Center(
          child: Text(
            'Belum bergabung ke tim',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    final teamTxs = txProvider.transactionsFor(team.id);
    final currentMonth = _currentMonth();
    final monthTotal = txProvider.summaryFor(team.id)
        .where((s) => s.month == currentMonth)
        .fold(0, (sum, s) => sum + s.totalAmount);
    final pendingCount =
        teamTxs.where((t) => t.reimbursementStatus == 'pending').length;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Header ────────────────────────────────────────────────────
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
                            'Management Tim',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                              fontFamily: 'DMSerifDisplay',
                            ),
                          ),
                          Text(
                            team.name,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade500),
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
            ),

            // ── Spending summary card ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A3050), Color(0xFF0D1E35)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.business_outlined,
                              size: 12, color: const Color(0xFF60A5FA)),
                          const SizedBox(width: 4),
                          const Text(
                            'PENGELUARAN TIM BULAN INI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF60A5FA),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      txProvider.loading
                          ? const SizedBox(
                              height: 36,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              _formatAmount(monthTotal),
                              style: const TextStyle(
                                fontSize: 32,
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
                            child: _buildCardStat(
                                'Transaksi', '${teamTxs.length}'),
                          ),
                          Expanded(
                            child: _buildCardStat(
                              'Pending Reimburse',
                              '$pendingCount',
                              valueColor: pendingCount > 0
                                  ? const Color(0xFFEF4444)
                                  : Colors.white,
                            ),
                          ),
                          Expanded(
                            child: _buildCardStat(
                                'Anggota', '${team.members.length}'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Quick actions ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.receipt_long_outlined,
                        label: 'Reimbursement',
                        color: const Color(0xFFD97706),
                        badge: pendingCount > 0 ? '$pendingCount' : null,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  ReimbursementPage(contextId: team.id)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.history_outlined,
                        label: 'Riwayat Tim',
                        color: AppColors.slateBlue,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  TransactionHistoryPage(contextId: team.id)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.person_add_outlined,
                        label: 'Undang',
                        color: const Color(0xFF10B981),
                        onTap: () => _showInviteSheet(team.id),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Pending reimbursements ────────────────────────────────────
            if (pendingCount > 0) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Menunggu Persetujuan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          fontFamily: 'DMSerifDisplay',
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  ReimbursementPage(contextId: team.id)),
                        ),
                        child: Text(
                          'Lihat Semua',
                          style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF60A5FA),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final pending = teamTxs
                        .where((t) => t.reimbursementStatus == 'pending')
                        .toList();
                    if (i >= pending.length) return null;
                    final tx = pending[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 4),
                      child: _buildPendingCard(tx),
                    );
                  },
                  childCount: pendingCount.clamp(0, 3),
                ),
              ),
            ],

            // ── Anggota Tim ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: const Text(
                  'Anggota Tim',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    fontFamily: 'DMSerifDisplay',
                  ),
                ),
              ),
            ),
            team.members.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      child: Text('Belum ada anggota',
                          style:
                              TextStyle(color: Colors.grey.shade500)),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final m = team.members[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.grey.shade200,
                                  child: Text(
                                    m.name.isNotEmpty
                                        ? m.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(m.name,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600)),
                                      Text(m.email,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade500)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _roleColor(m.role)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    m.roleLabel,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _roleColor(m.role)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: team.members.length,
                    ),
                  ),

            // ── Recent team transactions ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaksi Terbaru Tim',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        fontFamily: 'DMSerifDisplay',
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                TransactionHistoryPage(contextId: team.id)),
                      ),
                      child: Text(
                        'Lihat Semua',
                        style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF60A5FA),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            txProvider.loading
                ? const SliverToBoxAdapter(
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator())))
                : teamTxs.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 20),
                          child: Text('Belum ada transaksi',
                              style:
                                  TextStyle(color: Colors.grey.shade500)),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final tx = teamTxs.take(5).toList()[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 4),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF60A5FA)
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                          Icons.receipt_long_outlined,
                                          color: Color(0xFF60A5FA),
                                          size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              tx.merchant ?? tx.category,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                          Text(
                                              '${tx.category} • ${tx.formattedDate}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      Colors.grey.shade500)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '-${tx.formattedAmount}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFEF4444)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: teamTxs.take(5).length,
                        ),
                      ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.5))),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: valueColor)),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
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
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle),
                      child: Text(badge,
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingCard(dynamic tx) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE4B5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: const Color(0xFFD97706).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.assignment_outlined,
                color: Color(0xFFD97706), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.merchant ?? tx.category,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(tx.formattedDate,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(tx.formattedAmount,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              const Text('Pending',
                  style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFD97706),
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  void _showInviteSheet(String contextId) {
    final emailCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            const Text('Undang Anggota',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'DMSerifDisplay')),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: AppStyles.inputDecoration(
                  hintText: 'Email anggota baru'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final email = emailCtrl.text.trim();
                  if (email.isEmpty) return;
                  final success = await context
                      .read<ContextProvider>()
                      .addMember(
                          contextId: contextId,
                          email: email,
                          role: 'member');
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                      content: Text(success
                          ? 'Anggota berhasil diundang'
                          : 'Gagal mengundang anggota')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkButton,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Undang',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'owner':
        return AppColors.gold;
      case 'admin':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF10B981);
    }
  }
}
