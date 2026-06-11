import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'home_logged_in_screen.dart';
import '../../account/screens/account_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final bool showScanOnLoad;
  const MainScreen({Key? key, this.initialIndex = 0, this.showScanOnLoad = false}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const HomeLoggedInScreen(),
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timeline, size: 60, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Timeline Laporan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Di sini kamu bisa melihat aktivitas dan laporan lost & found terbaru dari seluruh civitas akademika.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(), // Placeholder for Scan
    const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 60, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Kotak Masuk Notifikasi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Belum ada notifikasi baru untuk saat ini. Kami akan mengabari kamu jika ada kecocokan laporan barang.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    ),
    const AccountScreen(), // Halaman Akun
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    if (widget.showScanOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showScanModal(context);
      });
    }
  }

  void _showScanModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Scan Presensi / QR',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Camera Scanning Frame Mockup
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryRed, width: 3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.qr_code_2, size: 140, color: Colors.white38),
                          // Scanning horizontal bar animation
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(seconds: 2),
                            builder: (context, value, child) {
                              return Positioned(
                                top: value * 210,
                                left: 5,
                                right: 5,
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryRed,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryRed.withOpacity(0.8),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Arahkan kamera ke QR Code di kelas\natau di gedung Telkom University',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScanModal(context),
        backgroundColor: AppColors.primaryRed,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Beranda', index: 0),
              _buildNavItem(icon: Icons.description_outlined, activeIcon: Icons.description, label: 'Timeline', index: 1),
              // Ruang kosong untuk tombol scan di tengah, ditambah teks Scan di bawahnya
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  SizedBox(height: 24), // Spacer for the FAB above
                  Text('Scan', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              _buildNavItem(icon: Icons.notifications_none, activeIcon: Icons.notifications, label: 'Notifikasi', index: 3),
              _buildNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Akun', index: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required IconData activeIcon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 3,
              width: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryRed : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primaryRed : Colors.grey,
              size: 26,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppColors.primaryRed : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4), // extra space at bottom
          ],
        ),
      ),
    );
  }
}
