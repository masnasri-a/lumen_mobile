import 'package:dio/dio.dart';
import '../models/ai_insight_model.dart';
import 'api_client.dart';

class AiService {
  final _dio = ApiClient.instance.dio;

  Future<AiInsightModel> getInsight({required String contextId}) async {
    try {
      final resp = await _dio.get('/insights',
          queryParameters: {'context_id': contextId});
      return AiInsightModel.fromJson(resp.data['data'] as Map<String, dynamic>);
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
