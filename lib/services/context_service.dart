import 'package:dio/dio.dart';
import '../models/finance_context_model.dart';
import 'api_client.dart';

class ContextService {
  final _dio = ApiClient.instance.dio;

  Future<List<FinanceContextModel>> list() async {
    try {
      final resp = await _dio.get('/contexts/');
      final data = resp.data['data'] as List<dynamic>;
      return data
          .map((e) => FinanceContextModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<FinanceContextModel> create({
    required String name,
    required String type, // personal/couple/team
  }) async {
    try {
      final resp = await _dio.post('/contexts/', data: {
        'name': name,
        'type': type,
      });
      return FinanceContextModel.fromJson(
          resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// Fetch the context of a specific type (personal/couple/team) for the
  /// authenticated user. Throws if not found (404).
  Future<FinanceContextModel> getByType(String type) async {
    try {
      final resp =
          await _dio.get('/contexts/by-type', queryParameters: {'type': type});
      return FinanceContextModel.fromJson(
          resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<FinanceContextModel> get(String id) async {
    try {
      final resp = await _dio.get('/contexts/$id');
      return FinanceContextModel.fromJson(
          resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<void> addMember({
    required String contextId,
    required String email,
    required String role, // owner/admin/member
  }) async {
    try {
      await _dio.post('/contexts/$contextId/members', data: {
        'email': email,
        'role': role,
      });
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
