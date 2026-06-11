import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/screens/main_screen.dart';

class LostAndFoundBottomBar extends StatelessWidget {
  final int activeIndex;
  final Function(int)? onTap;

  const LostAndFoundBottomBar({
    Key? key,
    this.activeIndex = 0,
    this.onTap,
  }) : super(key: key);

  void _handleTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }

    // Default synchronized flow navigation
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(
          initialIndex: index == 2 ? 0 : index,
          showScanOnLoad: index == 2,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(context, Icons.home, 'Beranda', activeIndex == 0, 0),
          _buildBottomNavItem(context, Icons.description_outlined, 'Timeline', activeIndex == 1, 1),
          
          // Scan Floating Circle Button
          GestureDetector(
            onTap: () => _handleTap(context, 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 2),
                const Text('Scan', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          
          _buildBottomNavItem(context, Icons.notifications_none, 'Notifikasi', activeIndex == 3, 3),
          _buildBottomNavItem(context, Icons.person_outline, 'Akun', activeIndex == 4, 4),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, IconData icon, String label, bool isActive, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _handleTap(context, index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppColors.primaryRed : Colors.grey, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppColors.primaryRed : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
