import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'lost_and_found_main_screen.dart';

class LostAndFoundScreen extends StatelessWidget {
  const LostAndFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Merah Melengkung di atas
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: const BoxDecoration(
                color: AppColors.primaryRed,
                // Kita buat tidak usah terlalu melengkung karena tertutup kartu
              ),
            ),
          ),

          // Konten Utama (Kartu Besar)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 20.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBE3E1), // Warna krem/pink pucat mirip di gambar
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Lost & Found
                    const Text(
                      'Lost & Found',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Center Titles
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Pilih Kampus',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2D2323),
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Silakan pilih lokasi kampus Anda untuk\nmelihat daftar barang hilang atau\nmelaporkan temuan di area terdekat.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Grid Kampus
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.85,
                        children: [
                          _buildCampusCard(context, 'Bandung'),
                          _buildCampusCard(context, 'Jakarta'),
                          _buildCampusCard(context, 'Purwokerto'),
                          _buildCampusCard(context, 'Surabaya'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampusCard(BuildContext context, String cityName) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LostAndFoundMainScreen(campusName: cityName),
          ),
        );
      },
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gambar Kampus
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Image.asset(
                'assets/images/$cityName.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.blue[100],
                  child: const Icon(
                    Icons.location_city,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          // Info Kampus
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cityName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Pilih Lokasi',
                        style: TextStyle(
                          color: AppColors.primaryRed,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.primaryRed,
                        size: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
