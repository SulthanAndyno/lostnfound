import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/screens/login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isBiometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Akun',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.withOpacity(0.2),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          children: [
            // Profile Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryRed.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: Icon(Icons.person, size: 50, color: Colors.grey[400]),
                      // Placeholder if image exists
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SSO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '103062400XX',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mahasiswa',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Kartu Tanda Mahasiswa
            _buildMenuItem(
              icon: Icons.badge,
              title: 'Kartu Tanda Mahasiswa',
              trailing: const Icon(Icons.chevron_right, color: Colors.black87),
              onTap: () {},
            ),

            // Ubah Role Pengguna
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Ubah Role Pengguna',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Mahasiswa',
                    style: TextStyle(color: AppColors.primaryRed, fontSize: 12),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.black87),
                ],
              ),
              onTap: () {},
            ),

            // Login Biometrik
            _buildMenuItem(
              icon: Icons.document_scanner_outlined, // Placeholder icon
              title: 'Login Biometrik',
              trailing: Switch(
                value: _isBiometricEnabled,
                onChanged: (value) {
                  setState(() {
                    _isBiometricEnabled = value;
                  });
                },
                activeColor: AppColors.primaryRed,
              ),
            ),

            // Career Profilling
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'Career Profilling',
              iconColor: Colors.white,
              titleColor: Colors.white,
              backgroundColor: AppColors.primaryRed,
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {},
            ),

            // Logout
            _buildMenuItem(
              icon: Icons.login_outlined, // Icon mirip dengan di desain
              title: 'Logout',
              iconColor: AppColors.primaryRed,
              titleColor: AppColors.primaryRed,
              trailing: const Icon(Icons.chevron_right, color: AppColors.primaryRed),
              onTap: () {
                // Aksi Logout
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),

            const SizedBox(height: 40),
            const Text(
              'Versi2.0.7',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 100), // Spacer untuk area tertutup bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Widget trailing,
    Color iconColor = Colors.black87,
    Color titleColor = Colors.black87,
    Color backgroundColor = Colors.white,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
