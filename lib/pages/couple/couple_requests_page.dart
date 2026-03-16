import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/context_provider.dart';
import '../../services/couple_invite_service.dart';

class CoupleRequestsPage extends StatefulWidget {
  const CoupleRequestsPage({super.key});

  @override
  State<CoupleRequestsPage> createState() => _CoupleRequestsPageState();
}

class _CoupleRequestsPageState extends State<CoupleRequestsPage> {
  final _service = CoupleInviteService();
  List<JoinRequest> _requests = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String? get _coupleContextId =>
      context.read<ContextProvider>().coupleContext?.id;

  Future<void> _load() async {
    final ctxId = _coupleContextId;
    if (ctxId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reqs = await _service.listJoinRequests(ctxId);
      if (mounted) setState(() => _requests = reqs);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handle(JoinRequest req, bool approve) async {
    final ctxId = _coupleContextId;
    if (ctxId == null) return;
    try {
      await _service.handleJoinRequest(
        contextId: ctxId,
        requestId: req.id,
        approve: approve,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(approve
            ? '${req.userName} berhasil disetujui'
            : 'Permintaan ditolak'),
        backgroundColor: approve ? Colors.green : Colors.red,
      ));
      // Refresh contexts so coupleContext member count updates
      await context.read<ContextProvider>().fetchContexts();
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Permintaan Bergabung',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textDark),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!,
                          style: TextStyle(color: Colors.grey.shade500)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _requests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 56, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada permintaan masuk',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bagikan kode undangan ke pasangan Anda',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _requests.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) => _buildCard(_requests[i]),
                      ),
                    ),
    );
  }

  Widget _buildCard(JoinRequest req) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFF0EAE0),
            child: Text(
              req.userName.isNotEmpty ? req.userName[0].toUpperCase() : '?',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req.userName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  req.userEmail,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(req.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              SizedBox(
                width: 80,
                child: ElevatedButton(
                  onPressed: () => _handle(req, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE879A0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Terima',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 80,
                child: OutlinedButton(
                  onPressed: () => _handle(req, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Tolak',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
