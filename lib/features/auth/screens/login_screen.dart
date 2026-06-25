import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../lost_and_found/services/lost_and_found_service.dart';
import '../../home/screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan Password tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool loginSuccess = false;
    String matchedName = 'Budi';

    final Map<String, String> allowedUsers = {
      'user1': 'Budi',
      'user2': 'Siti',
      'user3': 'Rian',
      'user4': 'Adi',
      'user5': 'Eka',
      'user6': 'Mega',
    };

    final lowerUsername = username.toLowerCase();
    if (password == 'password123' && allowedUsers.containsKey(lowerUsername)) {
      loginSuccess = true;
      matchedName = allowedUsers[lowerUsername]!;
    } else if (password != 'password123') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password salah! Coba gunakan: password123'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username tidak terdaftar! Coba: user1 sampai user6'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (loginSuccess) {
      // Set active user di service
      LostAndFoundService().setActiveUser(matchedName);

      // Login Berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Berhasil! Selamat Datang, $matchedName.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } else {
      // Login Gagal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau Password salah!\nCoba: user1 atau user2 (Password: password123)'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Placeholder untuk Logo myU
              Row(
                children: [
                  Text(
                    'my',
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -2.0,
                    ),
                  ),
                  const Text(
                    'U',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -2.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Selamat Datang',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan Login Menggunakan akun iGracias yang sudah\nterdaftar, untuk akses penuh MyTelU Mobile.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Form Username
              const Text(
                'Username',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'SSO',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryRed),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Form Password
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'xxxxxxxx',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryRed),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Lupa Password
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Lupa Password?',
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Tombol Masuk
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Butuh bantuan ? ',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              InkWell(
                onTap: () {},
                child: Row(
                  children: const [
                    Text(
                      'Hubungi Service Desk ',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Icon(
                      Icons.support_agent,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
