import 'package:flutter/foundation.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  final _service = BudgetService();

  BudgetModel? currentBudget;
  bool loading = false;
  String? error;

  Future<void> fetchBudget(String contextId) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final now = DateTime.now();
      final month =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';
      currentBudget = await _service.getBudget(contextId: contextId, month: month);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> setBudget(String contextId, int amount) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final now = DateTime.now();
      final month =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';
      currentBudget = await _service.setBudget(
        contextId: contextId,
        amount: amount,
        month: month,
      );
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
