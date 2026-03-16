import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/context_provider.dart';
import 'team_setup_page.dart';
import 'onboarding_complete_page.dart';

class _CurrencyConfig {
  final String prefix;
  final String thousandSeparator;
  final String hint;

  const _CurrencyConfig(this.prefix, this.thousandSeparator, this.hint);
}

class _CurrencyInputFormatter extends TextInputFormatter {
  final String prefix;
  final String thousandSeparator;

  _CurrencyInputFormatter({
    required this.prefix,
    required this.thousandSeparator,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extract only digits from new value
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Format number with thousand separators
    final number = int.parse(digits);
    final formatted = _formatNumber(number);
    final text = '$prefix$formatted';

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(thousandSeparator);
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

class ProfileSetupPage extends StatefulWidget {
  final String name;
  final bool hasCouple;
  final bool hasTeam;

  const ProfileSetupPage({
    super.key,
    required this.name,
    this.hasCouple = false,
    this.hasTeam = false,
  });

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _nicknameController = TextEditingController();
  final _budgetController = TextEditingController();
  String _selectedCurrency = 'IDR - Rupiah Indonesia';
  String _selectedStartDate = 'Tanggal 1';

  static const Map<String, _CurrencyConfig> _currencyConfigs = {
    'IDR - Rupiah Indonesia': _CurrencyConfig('Rp. ', '.', 'Rp. 5.000.000'),
    'USD - US Dollar': _CurrencyConfig('\$ ', ',', '\$ 5,000'),
    'EUR - Euro': _CurrencyConfig('\u20AC ', '.', '\u20AC 5.000'),
    'SGD - Singapore Dollar': _CurrencyConfig('S\$ ', ',', 'S\$ 5,000'),
    'MYR - Malaysian Ringgit': _CurrencyConfig('RM ', ',', 'RM 5,000'),
  };

  _CurrencyConfig get _currentConfig =>
      _currencyConfigs[_selectedCurrency] ??
      const _CurrencyConfig('Rp. ', '.', 'Rp. 5.000.000');

  List<String> get _currencies => _currencyConfigs.keys.toList();

  final List<String> _startDates = [
    'Tanggal 1',
    'Tanggal 5',
    'Tanggal 10',
    'Tanggal 15',
    'Tanggal 20',
    'Tanggal 25',
  ];

  @override
  void dispose() {
    _nicknameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final displayName = _nicknameController.text.isNotEmpty
        ? _nicknameController.text
        : widget.name;

    final ctxProvider = context.read<ContextProvider>();

    // Always create personal context
    await ctxProvider.createContext(name: 'Akun Saya', type: 'personal');

    // Create couple context if selected
    if (widget.hasCouple) {
      await ctxProvider.createContext(name: 'Pasangan', type: 'couple');
    }

    if (!mounted) return;

    if (widget.hasTeam) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TeamSetupPage(name: displayName),
        ),
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => OnboardingCompletePage(name: displayName),
        ),
        (route) => false,
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
          'Setup Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(false),
                  const SizedBox(width: 8),
                  _buildDot(true),
                  const SizedBox(width: 8),
                  _buildDot(false),
                ],
              ),
              const SizedBox(height: 24),
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                      border: Border.all(color: AppColors.gold, width: 2),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Kenalkan dirimu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'DMSerifDisplay',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lengkapi profil Anda untuk mulai mengelola\nkeuangan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              // Nama Panggilan
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'NAMA PANGGILAN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nicknameController,
                decoration: AppStyles.inputDecoration(
                  hintText: 'Masukkan nama panggilan',
                ),
              ),
              const SizedBox(height: 20),
              // Mata Uang
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'MATA UANG',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCurrency,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: Colors.grey.shade400),
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency,
                            style: const TextStyle(fontSize: 15)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrency = value!;
                        _budgetController.clear();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Plan Budget
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'PLAN BUDGET',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s\$\u20ACa-zA-Z]')),
                  _CurrencyInputFormatter(
                    prefix: _currentConfig.prefix,
                    thousandSeparator: _currentConfig.thousandSeparator,
                  ),
                ],
                decoration: AppStyles.inputDecoration(
                  hintText: _currentConfig.hint,
                ),
              ),
              const SizedBox(height: 20),
              // Tanggal Mulai Periode
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'TANGGAL MULAI PERIODE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedStartDate,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: Colors.grey.shade400),
                    items: _startDates.map((date) {
                      return DropdownMenuItem(
                        value: date,
                        child:
                            Text(date, style: const TextStyle(fontSize: 15)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStartDate = value!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Periode laporan keuangan bulanan Anda akan dimulai dari\ntanggal ini.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Lanjutkan button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: AppStyles.goldButton,
                  child: const Text('Lanjutkan'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.gold : Colors.grey.shade300,
      ),
    );
  }
}
