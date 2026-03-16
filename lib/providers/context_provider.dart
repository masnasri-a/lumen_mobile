import 'package:flutter/foundation.dart';
import '../models/finance_context_model.dart';
import '../services/context_service.dart';

class ContextProvider extends ChangeNotifier {
  final _service = ContextService();

  List<FinanceContextModel> _contexts = [];
  bool _loading = false;
  String? _error;

  List<FinanceContextModel> get contexts => _contexts;
  bool get loading => _loading;
  String? get error => _error;

  FinanceContextModel? get personalContext =>
      _contexts.where((c) => c.isPersonal).firstOrNull;

  FinanceContextModel? get coupleContext =>
      _contexts.where((c) => c.isCouple).firstOrNull;

  FinanceContextModel? get teamContext =>
      _contexts.where((c) => c.isTeam).firstOrNull;

  // Return context by tab index: 0=personal, 1=couple, 2=team
  // Returns null if the user has no context of that type — never cross-pollinate data.
  FinanceContextModel? contextForTab(int index) {
    switch (index) {
      case 0:
        return personalContext;
      case 1:
        return coupleContext;
      case 2:
        return teamContext;
      default:
        return null;
    }
  }

  Future<void> fetchContexts() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _contexts = await _service.list();
      // Ensure personal context exists (safety net for legacy accounts)
      if (personalContext == null) {
        final personal = await _service.create(
          name: 'Akun Saya',
          type: 'personal',
        );
        _contexts = [..._contexts, personal];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<FinanceContextModel?> createContext({
    required String name,
    required String type,
  }) async {
    try {
      final ctx = await _service.create(name: name, type: type);
      _contexts.add(ctx);
      notifyListeners();
      return ctx;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<FinanceContextModel?> getContextWithMembers(String id) async {
    try {
      return await _service.get(id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> addMember({
    required String contextId,
    required String email,
    required String role,
  }) async {
    try {
      await _service.addMember(
          contextId: contextId, email: email, role: role);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
