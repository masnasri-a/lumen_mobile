import 'package:dio/dio.dart';
import '../models/transaction_model.dart';
import 'api_client.dart';

class CreateTransactionData {
  final String contextId;
  final int amount;
  final String category;
  final String? merchant;
  final String? notes;
  final bool isReimbursable;
  final bool isPrivate;
  final DateTime transactionDate;

  const CreateTransactionData({
    required this.contextId,
    required this.amount,
    required this.category,
    this.merchant,
    this.notes,
    this.isReimbursable = false,
    this.isPrivate = false,
    required this.transactionDate,
  });

  Map<String, dynamic> toJson() => {
        'context_id': contextId,
        'amount': amount,
        'category': category,
        if (merchant?.isNotEmpty ?? false) 'merchant': merchant,
        if (notes?.isNotEmpty ?? false) 'notes': notes,
        'is_reimbursable': isReimbursable,
        'is_private': isPrivate,
        'transaction_date': transactionDate.toUtc().toIso8601String(),
      };
}

class TransactionService {
  final _dio = ApiClient.instance.dio;

  Future<List<TransactionModel>> list({
    String? contextId,
    String? category,
    bool? isReimbursable,
    String? reimbursementStatus,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final resp = await _dio.get('/transactions', queryParameters: {
        if (contextId != null) 'context_id': contextId,
        if (category != null) 'category': category,
        if (isReimbursable != null) 'is_reimbursable': isReimbursable.toString(),
        if (reimbursementStatus != null) 'reimbursement_status': reimbursementStatus,
        'limit': limit,
        'offset': offset,
      });
      final data = resp.data['data'] as List<dynamic>;
      return data
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<TransactionModel> create(CreateTransactionData data) async {
    try {
      final resp = await _dio.post('/transactions', data: data.toJson());
      return TransactionModel.fromJson(
          resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<TransactionModel> get(String id) async {
    try {
      final resp = await _dio.get('/transactions/$id');
      return TransactionModel.fromJson(
          resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<TransactionModel> update(String id, CreateTransactionData data) async {
    try {
      final resp = await _dio.put('/transactions/$id', data: data.toJson());
      return TransactionModel.fromJson(
          resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<TransactionModel> updateReimbursement(String id, String status) async {
    try {
      final resp = await _dio.patch('/transactions/$id/reimburse',
          data: {'status': status});
      return TransactionModel.fromJson(
          resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete('/transactions/$id');
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<List<ReimbursementSummaryItem>> reimbursementSummary({
    required String contextId,
  }) async {
    try {
      final resp = await _dio.get('/transactions/reimbursement-summary',
          queryParameters: {'context_id': contextId});
      final data = resp.data['data'] as List<dynamic>;
      return data
          .map((e) => ReimbursementSummaryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<List<CategorySummaryItem>> categorySummary({
    required String contextId,
    String? month,
  }) async {
    try {
      final resp =
          await _dio.get('/transactions/categories', queryParameters: {
        'context_id': contextId,
        'month': month,
      });
      final data = resp.data['data'] as List<dynamic>;
      return data
          .map((e) => CategorySummaryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<List<MonthlySummaryModel>> summary({
    required String contextId,
    int months = 6,
  }) async {
    try {
      final resp = await _dio.get('/transactions/summary', queryParameters: {
        'context_id': contextId,
        'months': months,
      });
      final data = resp.data['data'] as List<dynamic>;
      return data
          .map((e) => MonthlySummaryModel.fromJson(e as Map<String, dynamic>))
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
