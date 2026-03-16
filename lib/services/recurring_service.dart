import 'package:dio/dio.dart';
import 'api_client.dart';

class RecurringModel {
  final String id;
  final String contextId;
  final int amount;
  final String category;
  final String? merchant;
  final String? notes;
  final String interval; // daily/weekly/monthly/yearly
  final DateTime nextRun;
  final bool active;

  const RecurringModel({
    required this.id,
    required this.contextId,
    required this.amount,
    required this.category,
    this.merchant,
    this.notes,
    required this.interval,
    required this.nextRun,
    required this.active,
  });

  factory RecurringModel.fromJson(Map<String, dynamic> j) => RecurringModel(
        id: j['id'] as String,
        contextId: j['context_id'] as String,
        amount: j['amount'] as int,
        category: j['category'] as String,
        merchant: j['merchant'] as String?,
        notes: j['notes'] as String?,
        interval: j['interval'] as String,
        nextRun: DateTime.parse(j['next_run'] as String),
        active: j['active'] as bool,
      );

  String get formattedAmount {
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp ${buf.toString()}';
  }

  String get intervalLabel {
    switch (interval) {
      case 'daily':
        return 'Harian';
      case 'weekly':
        return 'Mingguan';
      case 'monthly':
        return 'Bulanan';
      case 'yearly':
        return 'Tahunan';
      default:
        return interval;
    }
  }

  String get nextRunFormatted {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${nextRun.day} ${months[nextRun.month - 1]} ${nextRun.year}';
  }
}

class RecurringService {
  final _dio = ApiClient.instance.dio;

  Future<List<RecurringModel>> list() async {
    try {
      final resp = await _dio.get('/recurring');
      final data = resp.data['data'] as List<dynamic>;
      return data
          .map((e) => RecurringModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<RecurringModel> create({
    required String contextId,
    required int amount,
    required String category,
    String? merchant,
    String? notes,
    required String interval,
    required DateTime nextRun,
  }) async {
    try {
      final resp = await _dio.post('/recurring', data: {
        'context_id': contextId,
        'amount': amount,
        'category': category,
        'merchant': merchant,
        'notes': notes,
        'interval': interval,
        'next_run': nextRun.toUtc().toIso8601String(),
        'is_reimbursable': false,
        'is_private': false,
      });
      return RecurringModel.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _dio.delete('/recurring/$id');
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
