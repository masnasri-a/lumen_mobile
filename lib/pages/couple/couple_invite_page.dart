import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/context_provider.dart';
import '../../services/couple_invite_service.dart';

class CoupleInvitePage extends StatefulWidget {
  const CoupleInvitePage({super.key});

  @override
  State<CoupleInvitePage> createState() => _CoupleInvitePageState();
}

class _CoupleInvitePageState extends State<CoupleInvitePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _service = CoupleInviteService();

  // Invite tab state
  CoupleInvite? _invite;
  bool _inviteLoading = false;
  String? _inviteError;

  // Apply tab state
  final List<TextEditingController> _codeCtrl =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeFocus = List.generate(6, (_) => FocusNode());
  bool _applyLoading = false;
  String? _applyError;
  bool _applySuccess = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadInvite();
  }

  @override
  void dispose() {
    _tab.dispose();
    for (final c in _codeCtrl) c.dispose();
    for (final f in _codeFocus) f.dispose();
    super.dispose();
  }

  String? get _coupleContextId =>
      context.read<ContextProvider>().coupleContext?.id;

  Future<void> _loadInvite() async {
    final ctxId = _coupleContextId;
    if (ctxId == null) return;
    setState(() => _inviteLoading = true);
    try {
      final inv = await _service.getInviteCode(ctxId);
      if (mounted) setState(() => _invite = inv);
    } catch (_) {
      // no active invite yet — that's fine
    } finally {
      if (mounted) setState(() => _inviteLoading = false);
    }
  }

  Future<void> _generateCode() async {
    final ctxId = _coupleContextId;
    if (ctxId == null) return;
    setState(() {
      _inviteLoading = true;
      _inviteError = null;
    });
    try {
      final inv = await _service.generateInviteCode(ctxId);
      if (mounted) setState(() => _invite = inv);
    } catch (e) {
      if (mounted) setState(() => _inviteError = e.toString());
    } finally {
      if (mounted) setState(() => _inviteLoading = false);
    }
  }

  Future<void> _applyCode() async {
    final code =
        _codeCtrl.map((c) => c.text.trim().toUpperCase()).join();
    if (code.length < 6) {
      setState(() => _applyError = 'Masukkan 6 karakter kode undangan');
      return;
    }
    setState(() {
      _applyLoading = true;
      _applyError = null;
      _applySuccess = false;
    });
    try {
      await _service.applyInviteCode(code);
      if (mounted) {
        setState(() => _applySuccess = true);
        for (final c in _codeCtrl) c.clear();
      }
    } catch (e) {
      if (mounted) setState(() => _applyError = e.toString());
    } finally {
      if (mounted) setState(() => _applyLoading = false);
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
          'Undang Pasangan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: Colors.grey.shade500,
          tabs: const [
            Tab(text: 'Bagikan Kode'),
            Tab(text: 'Masukkan Kode'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildShareTab(),
          _buildApplyTab(),
        ],
      ),
    );
  }

  Widget _buildShareTab() {
    final coupleCtx = context.watch<ContextProvider>().coupleContext;

    if (coupleCtx == null) {
      return Center(
        child: Text(
          'Anda belum memiliki akun Pasangan',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0EAE0),
            ),
            child: const Icon(Icons.favorite, size: 36, color: Color(0xFFE879A0)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Kode Undangan Pasangan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              fontFamily: 'DMSerifDisplay',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bagikan kode ini ke pasangan Anda.\nKode berlaku 7 hari.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 32),
          if (_inviteLoading)
            const CircularProgressIndicator(color: AppColors.gold)
          else if (_invite != null && !_invite!.isExpired)
            _buildCodeDisplay(_invite!.code)
          else
            _buildNoCodeState(),
          if (_inviteError != null) ...[
            const SizedBox(height: 12),
            Text(_inviteError!,
                style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          if (_invite != null && !_invite!.isExpired) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: _invite!.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Kode disalin ke clipboard')),
                      );
                    },
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    label: const Text('Salin Kode'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _inviteLoading ? null : _generateCode,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Buat Baru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCodeDisplay(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE879A0).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: code.split('').map((ch) {
              return Container(
                width: 44,
                height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F1E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  ch,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: 2,
                  ),
                ),
              );
            }).toList(),
          ),
          ),
          const SizedBox(height: 16),
          Text(
            'Berlaku hingga ${_formatDate(_invite!.expiresAt)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCodeState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.lock_outline, size: 40, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'Belum ada kode aktif',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Buat kode undangan untuk pasangan Anda',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _inviteLoading ? null : _generateCode,
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('Buat Kode Undangan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE879A0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0EAE0),
            ),
            child: const Icon(Icons.login_outlined, size: 36, color: AppColors.gold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Gabung Akun Pasangan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              fontFamily: 'DMSerifDisplay',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan kode undangan 6 karakter yang diberikan pasangan Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 32),
          if (_applySuccess)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Permintaan terkirim! Tunggu persetujuan dari pasangan Anda.',
                      style: TextStyle(
                          color: Colors.green.shade700, fontSize: 14),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                return SizedBox(
                  width: 48,
                  height: 56,
                  child: TextFormField(
                    controller: _codeCtrl[i],
                    focusNode: _codeFocus[i],
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: const Color(0xFFF5F1E8),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 5) {
                        _codeFocus[i + 1].requestFocus();
                      } else if (v.isEmpty && i > 0) {
                        _codeFocus[i - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            if (_applyError != null) ...[
              const SizedBox(height: 12),
              Text(_applyError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyLoading ? null : _applyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkButton,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _applyLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Kirim Permintaan',
                        style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
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
