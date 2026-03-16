import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'api_client.dart';

class ExportService {
  final _dio = ApiClient.instance.dio;

  /// Downloads CSV from backend and opens the system share sheet.
  /// Returns true on success, false on failure.
  Future<bool> exportAndShare({
    required String contextId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final resp = await _dio.get<String>(
        '/transactions/export',
        queryParameters: {
          'context_id': contextId,
          if (dateFrom != null)
            'date_from': dateFrom.toUtc().toIso8601String(),
          if (dateTo != null)
            'date_to': dateTo.toUtc().toIso8601String(),
        },
        options: Options(responseType: ResponseType.plain),
      );

      final csv = resp.data;
      if (csv == null || csv.isEmpty) return false;

      // Save to temp file
      final dir = await getTemporaryDirectory();
      final now = DateTime.now();
      final fileName =
          'lumen_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csv);

      // Share via system share sheet
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Lumen Transactions Export',
      );

      return true;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
