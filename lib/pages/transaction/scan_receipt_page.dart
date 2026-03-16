import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ScanReceiptPage extends StatelessWidget {
  const ScanReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.close, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                const Text('Batal',
                    style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'SCAN STRUK',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade800,
              ),
              child:
                  const Icon(Icons.flash_on, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Struk Terdeteksi badge
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Struk Terdeteksi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Camera viewfinder
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade800,
                ),
                child: Stack(
                  children: [
                    // Placeholder receipt area
                    Center(
                      child: Container(
                        width: 200,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long,
                                size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 8),
                            Text('Preview Struk',
                                style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    // Corner brackets
                    Positioned(
                      top: 16,
                      left: 16,
                      child: _buildCorner(true, true),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: _buildCorner(true, false),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: _buildCorner(false, true),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: _buildCorner(false, false),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom sheet with detected data
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            decoration: const BoxDecoration(
              color: Color(0xFF2C2C2C),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.receipt_long, size: 18, color: AppColors.gold),
                    const SizedBox(width: 8),
                    const Text(
                      'Data Terdeteksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MERCHANT',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold,
                                  letterSpacing: 1.0)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.storefront_outlined,
                                  size: 16, color: Colors.grey.shade400),
                              const SizedBox(width: 6),
                              const Text('Indomaret\nSudirman',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TANGGAL',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold,
                                  letterSpacing: 1.0)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today,
                                  size: 16, color: Colors.grey.shade400),
                              const SizedBox(width: 6),
                              const Text('14 Mar 2026',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KATEGORI',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gold,
                                letterSpacing: 1.0)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('BELANJA',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('TOTAL',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gold,
                                letterSpacing: 1.0)),
                        const SizedBox(height: 4),
                        const Text('Rp 87.500',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                                fontFamily: 'DMSerifDisplay')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: AppStyles.goldButton,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Simpan Transaksi'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return SizedBox(
      width: 32,
      height: 32,
      child: CustomPaint(
        painter: _CornerPainter(isTop: isTop, isLeft: isLeft),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  _CornerPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
