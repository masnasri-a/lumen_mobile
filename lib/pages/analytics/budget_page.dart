import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/budget_provider.dart';
import '../../providers/context_provider.dart';
import '../../providers/transaction_provider.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _amountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final ctxProvider = context.read<ContextProvider>();
    final ctx = ctxProvider.personalContext ?? ctxProvider.contextForTab(0);
    if (ctx != null) {
      await context.read<BudgetProvider>().fetchBudget(ctx.id);
    }
  }

  Future<void> _saveBudget() async {
    final text = _amountCtrl.text.replaceAll('.', '').replaceAll(',', '');
    final amount = int.tryParse(text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah yang valid')),
      );
      return;
    }
    final ctxProvider = context.read<ContextProvider>();
    final ctx = ctxProvider.personalContext ?? ctxProvider.contextForTab(0);
    if (ctx == null) return;

    final success =
        await context.read<BudgetProvider>().setBudget(ctx.id, amount);
    if (!mounted) return;
    if (success) {
      _amountCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget berhasil disimpan')),
      );
    } else {
      final err = context.read<BudgetProvider>().error ?? 'Gagal menyimpan';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err)),
      );
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final ctxProvider = context.watch<ContextProvider>();
    final txProvider = context.watch<TransactionProvider>();
    final ctx = ctxProvider.personalContext ?? ctxProvider.contextForTab(0);
    final budget = budgetProvider.currentBudget;
    final spent = txProvider.currentMonthTotal;
    final budgetAmount = budget?.amount ?? 0;
    final progress =
        budgetAmount > 0 ? (spent / budgetAmount).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = budgetAmount > 0 && spent / budgetAmount > 0.8;

    final now = DateTime.now();
    const monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final monthLabel = '${monthNames[now.month - 1]} ${now.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Atur Budget Bulanan'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: budgetProvider.loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Context name
                  if (ctx != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ctx.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Current budget card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget $monthLabel',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          budget != null
                              ? budget.formattedAmount
                              : 'Belum diatur',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            fontFamily: 'DMSerifDisplay',
                          ),
                        ),
                        if (budget != null) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade100,
                              color: isOverBudget
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF22C55E),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${txProvider.currentMonthFormatted} / ${budget.formattedAmount}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isOverBudget
                                      ? const Color(0xFFEF4444)
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isOverBudget
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF22C55E),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Set budget form
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget != null
                              ? 'Ubah Budget'
                              : 'Atur Budget Baru',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: AppStyles.inputDecoration(
                            hintText: 'Contoh: 5000000',
                            labelText: 'Jumlah Budget (Rp)',
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveBudget,
                            style: AppStyles.goldButton,
                            child: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
