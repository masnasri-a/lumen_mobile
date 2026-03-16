import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../providers/context_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/transaction_service.dart';

class AddTransactionPage extends StatefulWidget {
  final String? defaultContextId;
  final TransactionModel? editTransaction;

  const AddTransactionPage({
    super.key,
    this.defaultContextId,
    this.editTransaction,
  });

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();
  int _rawAmount = 0;
  int _selectedCategory = 0;
  int _selectedContext = 0;
  bool _isPrivate = false;
  bool _isReimburse = false;

  final List<String> _categories = [
    'Makan',
    'Transport',
    'Hiburan',
    'Kesehatan',
    'Belanja',
    'Lainnya',
  ];

  bool get _isEditing => widget.editTransaction != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.editTransaction;
    if (tx != null) {
      _rawAmount = tx.amount;
      _merchantController.text = tx.merchant ?? '';
      _notesController.text = tx.notes ?? '';
      _isPrivate = tx.isPrivate;
      _isReimburse = tx.isReimbursable;
      final idx = _categories.indexWhere(
          (c) => c.toLowerCase() == tx.category.toLowerCase());
      if (idx != -1) _selectedCategory = idx;
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String get _formattedAmount {
    if (_rawAmount == 0) return '0';
    final s = _rawAmount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  void _showAmountDialog() {
    final controller = TextEditingController(
      text: _rawAmount == 0 ? '' : _rawAmount.toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Masukkan Jumlah'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: 'Rp ',
            hintText: '0',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text) ?? 0;
              setState(() => _rawAmount = val);
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _getContextId() {
    final ctxProvider = context.read<ContextProvider>();
    if (widget.defaultContextId != null) {
      final match = ctxProvider.contexts
          .where((c) => c.id == widget.defaultContextId)
          .firstOrNull;
      if (match != null) return match.id;
    }
    return ctxProvider.contextForTab(_selectedContext)?.id ??
        ctxProvider.contexts.firstOrNull?.id;
  }

  Future<void> _save() async {
    if (_rawAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan jumlah pengeluaran')),
      );
      return;
    }

    final contextId = _isEditing
        ? widget.editTransaction!.contextId
        : _getContextId();
    if (contextId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada konteks tersedia')),
      );
      return;
    }

    final data = CreateTransactionData(
      contextId: contextId,
      amount: _rawAmount,
      category: _categories[_selectedCategory],
      merchant: _merchantController.text.trim().isEmpty
          ? null
          : _merchantController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      isReimbursable: _isReimburse,
      isPrivate: _isPrivate,
      transactionDate: _isEditing
          ? widget.editTransaction!.transactionDate
          : DateTime.now(),
    );

    final txProvider = context.read<TransactionProvider>();
    final bool ok;
    if (_isEditing) {
      ok = await txProvider.updateTransaction(widget.editTransaction!.id, data);
    } else {
      ok = await txProvider.createTransaction(data);
    }

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(txProvider.error ?? 'Gagal menyimpan transaksi'),
          backgroundColor: Colors.redAccent,
        ),
      );
      txProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = context.watch<TransactionProvider>().submitting;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            _isEditing ? 'Ubah Transaksi' : 'Tambah Pengeluaran',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                              fontFamily: 'DMSerifDisplay',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Amount display — tap to edit
                GestureDetector(
                  onTap: _showAmountDialog,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Rp',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade400,
                            fontFamily: 'DMSerifDisplay',
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formattedAmount,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: _rawAmount == 0
                                ? Colors.grey.shade300
                                : AppColors.textDark,
                            fontFamily: 'DMSerifDisplay',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.edit, size: 18, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // KATEGORI
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'KATEGORI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isActive = _selectedCategory == index;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
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
                            _categories[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isActive
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // MERCHANT / LOKASI
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MERCHANT / LOKASI',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                              letterSpacing: 1.0)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.storefront_outlined,
                                size: 18, color: Colors.grey.shade400),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _merchantController,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan nama merchant...',
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade400),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // CATATAN
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CATATAN',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                              letterSpacing: 1.0)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            hintText: 'Tambah catatan (opsional)...',
                            hintStyle:
                                TextStyle(color: Colors.grey.shade400),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // KONTEKS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KONTEKS',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                              letterSpacing: 1.0)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildContextChip('Personal', 0),
                          const SizedBox(width: 8),
                          _buildContextChip('Pasangan', 1),
                          const SizedBox(width: 8),
                          _buildContextChip('Tim', 2),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Privat & Reimburse toggles
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('PRIVAT',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5)),
                                  Text('Hanya saya',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500)),
                                ],
                              ),
                              Switch(
                                value: _isPrivate,
                                onChanged: (v) =>
                                    setState(() => _isPrivate = v),
                                activeTrackColor: AppColors.gold,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('REIMBURSE',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5)),
                                  Text('Klaim kantor',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500)),
                                ],
                              ),
                              Switch(
                                value: _isReimburse,
                                onChanged: (v) =>
                                    setState(() => _isReimburse = v),
                                activeTrackColor: AppColors.gold,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Simpan button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitting ? null : _save,
                      style: AppStyles.darkButton,
                      child: submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Simpan'),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContextChip(String label, int index) {
    final isActive = _selectedContext == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedContext = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.gold.withValues(alpha: 0.15)
                : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(14),
            border: isActive
                ? Border.all(color: AppColors.gold)
                : Border.all(color: Colors.transparent),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.gold : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
