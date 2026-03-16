import 'package:dio/dio.dart';
import '../models/budget_model.dart';
import 'api_client.dart';

class BudgetService {
  final _dio = ApiClient.instance.dio;

  Future<BudgetModel> setBudget({
    required String contextId,
    required int amount,
    required String month,
  }) async {
    try {
      final resp = await _dio.post('/budgets', data: {
        'context_id': contextId,
        'amount': amount,
        'month': month,
      });
      return BudgetModel.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<BudgetModel?> getBudget({
    required String contextId,
    required String month,
  }) async {
    try {
      final resp = await _dio.get('/budgets', queryParameters: {
        'context_id': contextId,
        'month': month,
      });
      return BudgetModel.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _parseError(e);
    }
  }

  Future<List<BudgetModel>> getBudgetHistory({
    required String contextId,
    int months = 6,
  }) async {
    try {
      final resp = await _dio.get('/budgets/history', queryParameters: {
        'context_id': contextId,
        'months': months,
      });
      final data = resp.data['data'] as List<dynamic>;
      return data
          .map((e) => BudgetModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return data['error']?.toString() ??
          data['message']?.toString() ??
          'Terjadi kesalahan';
    }
    return 'Terjadi kesalahan, coba lagi';
  }
}
