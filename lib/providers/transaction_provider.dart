import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider extends ChangeNotifier {
  final _service = TransactionService();

  // Per-context caches — keyed by contextId
  final Map<String, List<TransactionModel>> _txByContext = {};
  final Map<String, List<MonthlySummaryModel>> _summaryByContext = {};
  List<CategorySummaryItem> _categories = [];

  // Active context id currently displayed
  String? _activeContextId;

  bool _loading = false;
  bool _submitting = false;
  String? _error;

  // ── Getters ──────────────────────────────────────────────────────────────

  /// Transactions for the currently active context.
  List<TransactionModel> get transactions =>
      _txByContext[_activeContextId] ?? [];

  /// Monthly summary for the currently active context.
  List<MonthlySummaryModel> get summary =>
      _summaryByContext[_activeContextId] ?? [];

  List<CategorySummaryItem> get categories => _categories;
  bool get loading => _loading;
  bool get submitting => _submitting;
  String? get error => _error;

  /// Transactions for a specific context (read-only, used by sub-pages).
  List<TransactionModel> transactionsFor(String contextId) =>
      _txByContext[contextId] ?? [];

  /// Monthly summary for a specific context.
  List<MonthlySummaryModel> summaryFor(String contextId) =>
      _summaryByContext[contextId] ?? [];

  // ── Computed totals ───────────────────────────────────────────────────────

  int monthTotalFor(String contextId) {
    final s = summaryFor(contextId);
    if (s.isEmpty) return 0;
    final key =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    for (final m in s) {
      if (m.month == key) return m.totalAmount;
    }
    return 0;
  }

  String formattedTotalFor(String contextId) {
    final total = monthTotalFor(contextId);
    if (total == 0) return 'Rp 0';
    final s = total.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp ${buf.toString()}';
  }

  // Legacy getters (used by analytics page — reads active context)
  int get currentMonthTotal =>
      _activeContextId != null ? monthTotalFor(_activeContextId!) : 0;

  String get currentMonthFormatted =>
      _activeContextId != null ? formattedTotalFor(_activeContextId!) : 'Rp 0';

  // ── Fetch ─────────────────────────────────────────────────────────────────

  Future<void> fetchTransactions({String? contextId}) async {
    _activeContextId = contextId;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final txs = await _service.list(contextId: contextId, limit: 30);
      if (contextId != null) {
        _txByContext[contextId] = txs;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSummary({required String contextId}) async {
    _activeContextId = contextId;
    try {
      final s = await _service.summary(contextId: contextId);
      _summaryByContext[contextId] = s;
      notifyListeners();
    } catch (_) {}
  }

  /// Clears all cached data (call on logout).
  void clearAll() {
    _txByContext.clear();
    _summaryByContext.clear();
    _categories = [];
    _activeContextId = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> createTransaction(CreateTransactionData data) async {
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      final tx = await _service.create(data);
      final ctxId = data.contextId;
      _txByContext[ctxId] = [tx, ...(_txByContext[ctxId] ?? [])];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateTransaction(String id, CreateTransactionData data) async {
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      final tx = await _service.update(id, data);
      for (final ctxId in _txByContext.keys) {
        final list = _txByContext[ctxId]!;
        final idx = list.indexWhere((t) => t.id == id);
        if (idx != -1) {
          _txByContext[ctxId] = [...list]..[idx] = tx;
          break;
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateReimbursement(String id, String status) async {
    try {
      final tx = await _service.updateReimbursement(id, status);
      for (final ctxId in _txByContext.keys) {
        final list = _txByContext[ctxId]!;
        final idx = list.indexWhere((t) => t.id == id);
        if (idx != -1) {
          _txByContext[ctxId] = [...list]..[idx] = tx;
          break;
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      await _service.delete(id);
      for (final ctxId in _txByContext.keys) {
        _txByContext[ctxId] =
            _txByContext[ctxId]!.where((t) => t.id != id).toList();
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchCategories({required String contextId, String? month}) async {
    try {
      _categories = await _service.categorySummary(contextId: contextId, month: month);
      notifyListeners();
    } catch (_) {}
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
