import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/context_provider.dart';
import 'home_tab.dart';
import '../analytics/analytics_page.dart';
import '../transaction/add_transaction_page.dart';
import '../profile/profile_page.dart';
import '../team/team_management_page.dart';
import '../transaction/recurring_page.dart';

class MainShell extends StatefulWidget {
  final String userName;

  const MainShell({super.key, required this.userName});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContextProvider>().fetchContexts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasTeam =
        context.watch<ContextProvider>().teamContext != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeTab(userName: widget.userName),
          const AnalyticsPage(),
          const SizedBox(), // placeholder for FAB
          hasTeam ? const TeamManagementPage() : const RecurringPage(),
          ProfilePage(userName: widget.userName),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AddTransactionPage(),
            );
          },
          backgroundColor: AppColors.darkButton,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 8,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.grid_view_rounded, 'Beranda', 0),
              _buildNavItem(Icons.bar_chart_rounded, 'Analitik', 1),
              const SizedBox(width: 48), // space for FAB
              hasTeam
                  ? _buildNavItem(Icons.groups_outlined, 'Tim', 3)
                  : _buildNavItem(Icons.repeat_outlined, 'Tagihan', 3),
              _buildNavItem(Icons.person_outline, 'Profil', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppColors.gold : Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.gold : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
