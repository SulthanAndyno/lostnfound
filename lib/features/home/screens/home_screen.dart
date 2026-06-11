import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/feature_menu_item.dart';
import '../../auth/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header Merah
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 20.0, bottom: 24.0),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'myu',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'HEI, Tel-Utizen 👋',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Masuk untuk akses semua fitur!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textDark,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Konten Putih
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fitur Aplikasi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 24),
                              GridView.count(
                                crossAxisCount: 3,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 20,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.85,
                                children: [
                                  FeatureMenuItem(title: 'MyTucTuc', icon: Icons.directions_car_outlined, iconColor: Colors.red[300]!),
                                  const FeatureMenuItem(title: 'Hotline Konseling\nDitmawa', icon: Icons.local_fire_department, iconColor: Colors.red),
                                  const FeatureMenuItem(title: 'Open Library', icon: Icons.menu_book, iconColor: Colors.orange),
                                  const FeatureMenuItem(title: 'Sirama Registrasi', icon: Icons.library_books, iconColor: Colors.red),
                                  const FeatureMenuItem(title: 'SIMKA', icon: Icons.assignment_ind, iconColor: Colors.red),
                                  const FeatureMenuItem(title: 'Merpati', icon: Icons.flight, iconColor: Colors.red),
                                  const FeatureMenuItem(title: 'SMB Telkom\nUniversity', icon: Icons.school_outlined, iconColor: Colors.red),
                                  const FeatureMenuItem(title: 'LMS IOS', icon: Icons.apple, iconColor: Colors.red),
                                  const FeatureMenuItem(title: 'LMS Android', icon: Icons.android, iconColor: Colors.red),
                                  const FeatureMenuItem(title: 'Service Desk', icon: Icons.support_agent, iconColor: Colors.red),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 8,
                          color: AppColors.backgroundGrey,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Berita Terbaru',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Lihat semua',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
