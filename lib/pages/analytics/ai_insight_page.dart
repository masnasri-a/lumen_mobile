import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/ai_insight_model.dart';
import '../../providers/context_provider.dart';
import '../../services/ai_service.dart';

class AiInsightPage extends StatefulWidget {
  const AiInsightPage({super.key});

  @override
  State<AiInsightPage> createState() => _AiInsightPageState();
}

class _AiInsightPageState extends State<AiInsightPage> {
  final _aiService = AiService();
  AiInsightModel? _insight;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInsight());
  }

  Future<void> _loadInsight() async {
    final ctxProvider = context.read<ContextProvider>();
    final ctx = ctxProvider.personalContext ?? ctxProvider.contextForTab(0);
    if (ctx == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final insight = await _aiService.getInsight(contextId: ctx.id);
      if (mounted) setState(() => _insight = insight);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatGeneratedAt(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  Widget _buildRichText(String text) {
    final parts = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts.map((line) {
        final spans = <InlineSpan>[];
        final regex = RegExp(r'\*\*(.+?)\*\*');
        int last = 0;
        for (final match in regex.allMatches(line)) {
          if (match.start > last) {
            spans.add(TextSpan(
              text: line.substring(last, match.start),
              style: const TextStyle(fontSize: 14, height: 1.6),
            ));
          }
          spans.add(TextSpan(
            text: match.group(1),
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, height: 1.6),
          ));
          last = match.end;
        }
        if (last < line.length) {
          spans.add(TextSpan(
            text: line.substring(last),
            style: const TextStyle(fontSize: 14, height: 1.6),
          ));
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.textDark),
              children: spans,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.auto_awesome, color: Color(0xFFC5944A), size: 20),
            SizedBox(width: 8),
            Text('Lumen AI Insight'),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: RefreshIndicator(
        onRefresh: _loadInsight,
        color: AppColors.gold,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.gold))
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: _insight == null
                    ? _buildEmptyState()
                    : _buildInsightContent(),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.auto_awesome,
              size: 64, color: AppColors.gold),
          const SizedBox(height: 16),
          const Text(
            'Belum ada insight',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate insight AI berdasarkan\ndata transaksi Anda',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadInsight,
            style: AppStyles.goldButton,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Insight'),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightContent() {
    final insight = _insight!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cached badge
        if (insight.cached)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'dari cache hari ini',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        // Insight card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: AppColors.gold, width: 4),
            ),
          ),
          child: _buildRichText(insight.insight),
        ),
        const SizedBox(height: 16),
        // Generated at
        if (insight.generatedAt.isNotEmpty)
          Text(
            'Dibuat pada: ${_formatGeneratedAt(insight.generatedAt)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        const SizedBox(height: 20),
        // Regenerate button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _loadInsight,
            style: AppStyles.outlinedButton,
            icon: const Icon(Icons.refresh),
            label: const Text('Regenerate'),
          ),
        ),
        const SizedBox(height: 24),
        // Disclaimer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline,
                  size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Insight AI berdasarkan data transaksi Anda. Tidak merupakan saran keuangan profesional.',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
