import 'package:dio/dio.dart';
import 'api_client.dart';

class CoupleInvite {
  final String id;
  final String contextId;
  final String code;
  final DateTime expiresAt;

  const CoupleInvite({
    required this.id,
    required this.contextId,
    required this.code,
    required this.expiresAt,
  });

  factory CoupleInvite.fromJson(Map<String, dynamic> j) => CoupleInvite(
        id: j['id'] as String,
        contextId: j['context_id'] as String,
        code: j['code'] as String,
        expiresAt: DateTime.parse(j['expires_at'] as String),
      );

  bool get isExpired => expiresAt.isBefore(DateTime.now());
}

class JoinRequest {
  final String id;
  final String contextId;
  final String userId;
  final String userName;
  final String userEmail;
  final String status;
  final DateTime createdAt;

  const JoinRequest({
    required this.id,
    required this.contextId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.status,
    required this.createdAt,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> j) => JoinRequest(
        id: j['id'] as String,
        contextId: j['context_id'] as String,
        userId: j['user_id'] as String,
        userName: j['user_name'] as String? ?? '',
        userEmail: j['user_email'] as String? ?? '',
        status: j['status'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class CoupleInviteService {
  final _dio = ApiClient.instance.dio;

  Future<CoupleInvite> generateInviteCode(String contextId) async {
    try {
      final resp = await _dio.post('/contexts/$contextId/invite-code');
      return CoupleInvite.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<CoupleInvite?> getInviteCode(String contextId) async {
    try {
      final resp = await _dio.get('/contexts/$contextId/invite-code');
      return CoupleInvite.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _parseError(e);
    }
  }

  Future<JoinRequest> applyInviteCode(String code) async {
    try {
      final resp = await _dio.post('/contexts/join', data: {'code': code});
      return JoinRequest.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<List<JoinRequest>> listJoinRequests(String contextId) async {
    try {
      final resp = await _dio.get('/contexts/$contextId/join-requests');
      final data = resp.data['data'] as List<dynamic>;
      return data
          .map((e) => JoinRequest.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<void> handleJoinRequest({
    required String contextId,
    required String requestId,
    required bool approve,
  }) async {
    try {
      await _dio.patch('/contexts/$contextId/join-requests/$requestId',
          data: {'action': approve ? 'approve' : 'reject'});
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
