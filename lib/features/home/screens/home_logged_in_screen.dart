import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../lost_and_found/screens/lost_and_found_screen.dart';
import '../../lost_and_found/services/lost_and_found_service.dart';

class HomeLoggedInScreen extends StatelessWidget {
  const HomeLoggedInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.backgroundGrey, // Warna dasar abu sangat terang
      body: Stack(
        children: [
          // Background Merah Melengkung di atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(
                    MediaQuery.of(context).size.width,
                    100,
                  ),
                ),
              ),
            ),
          ),

          // Konten Utama yang bisa di-scroll
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Header Profil (Foto, Nama, NIM)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey[400],
                            ),
                            // Jika ada gambar: Image.network('url_gambar', fit: BoxFit.cover)
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LostAndFoundService().activeUserName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mahasiswa .103062400XX',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Kartu Jadwal Kuliah (Sedang Berlangsung)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CBK2IAB3- INTERAKSI MANUSIA KOMPU...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryRed,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Sedang Berlangsung',
                                style: TextStyle(
                                  color: AppColors.primaryRed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildScheduleInfo(
                                  'Waktu',
                                  '07:30-10:30',
                                ),
                              ),
                              Expanded(
                                child: _buildScheduleInfo(
                                  'Ruangan',
                                  'RKB.KJ.04.003',
                                ),
                              ),
                              Expanded(
                                child: _buildScheduleInfo('Kode Dosen', 'ZII'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Fitur Aplikasi
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
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
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 8,
                          childAspectRatio:
                              0.7, // Disesuaikan agar teks tidak terpotong
                          children: [
                            _buildFeatureIcon(
                              'Pengembang an Karakter ...',
                              Icons.local_fire_department,
                              Colors.grey[800]!,
                            ),
                            _buildFeatureIcon(
                              'Survey',
                              Icons.fact_check_outlined,
                              AppColors.primaryRed,
                            ),
                            _buildFeatureIcon(
                              'Language Center',
                              Icons.school_outlined,
                              Colors.grey,
                            ),
                            _buildFeatureIcon(
                              'Pelaporan Kode Etik',
                              Icons.gavel,
                              Colors.grey[800]!,
                            ),
                            _buildFeatureIcon(
                              'Suara TelUtizen',
                              Icons.headset_mic_outlined,
                              AppColors.primaryRed,
                            ),
                            _buildFeatureIcon(
                              'Presensi Mahasiswa',
                              Icons.fingerprint,
                              AppColors.primaryRed,
                            ),
                            _buildFeatureIcon(
                              'Nilai Mahasiswa',
                              Icons.assignment_outlined,
                              AppColors.primaryRed,
                            ),
                            _buildFeatureIcon(
                              'Lainnya',
                              Icons.grid_view,
                              AppColors.primaryRed,
                              onTap: () => _showAppsBottomSheet(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Spacer Abu-abu
                  Container(height: 8, color: AppColors.backgroundGrey),

                  // Tel-U Event
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tel-U Event',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Placeholder Banner Event
                        Row(
                          children: [
                            Container(
                              width: 140,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(Icons.image, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 140,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 100,
                        ), // Ruang ekstra untuk bottom bar
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showAppsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Apps',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 4,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.7,
                  children: [
                    _buildFeatureIcon(
                      'Pengembangan Karakt...',
                      Icons.local_fire_department,
                      Colors.grey[800]!,
                    ),
                    _buildFeatureIcon(
                      'Survey',
                      Icons.fact_check_outlined,
                      AppColors.primaryRed,
                    ),
                    _buildFeatureIcon(
                      'Language Center',
                      Icons.school_outlined,
                      Colors.grey,
                    ),
                    _buildFeatureIcon(
                      'Pelaporan Kode Etik',
                      Icons.gavel,
                      Colors.grey[800]!,
                    ),
                    _buildFeatureIcon(
                      'Suara TelUtizen',
                      Icons.headset_mic_outlined,
                      AppColors.primaryRed,
                    ),
                    _buildFeatureIcon(
                      'Presensi Mahasiswa',
                      Icons.fingerprint,
                      AppColors.primaryRed,
                    ),
                    _buildFeatureIcon(
                      'Nilai Mahasiswa',
                      Icons.assignment_outlined,
                      AppColors.primaryRed,
                    ),
                    _buildFeatureIcon(
                      'Service Desk',
                      Icons.support_agent,
                      Colors.grey[800]!,
                    ),
                    _buildFeatureIcon(
                      'LMS Android',
                      Icons.android,
                      AppColors.primaryRed,
                    ),
                    _buildFeatureIcon(
                      'LMS IOS',
                      Icons.apple,
                      AppColors.primaryRed,
                    ),
                    _buildFeatureIcon(
                      'SMB Telkom University',
                      Icons.school_outlined,
                      Colors.red[300]!,
                    ),
                    _buildFeatureIcon(
                      'Merpati',
                      Icons.flight,
                      AppColors.primaryRed,
                    ),
                    _buildFeatureIcon(
                      'SIMKA',
                      Icons.assignment_ind,
                      Colors.grey[800]!,
                    ),
                    _buildFeatureIcon(
                      'Sirama Registrasi',
                      Icons.library_books,
                      AppColors.primaryRed,
                    ),
                    _buildFeatureIcon(
                      'Open Library',
                      Icons.menu_book,
                      Colors.orange,
                    ),
                    _buildFeatureIcon(
                      'Hotline Konseling ...',
                      Icons.local_fire_department,
                      Colors.grey[800]!,
                    ),
                    _buildFeatureIcon(
                      'MyTucTuc',
                      Icons.directions_car_outlined,
                      Colors.red[200]!,
                    ),
                    _buildFeatureIcon(
                      'Lost & Found',
                      Icons.work_outline,
                      AppColors.primaryRed,
                      onTap: () {
                        Navigator.pop(context); // Tutup bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LostAndFoundScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureIcon(
    String title,
    IconData icon,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 26)),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
