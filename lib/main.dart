import 'package:flutter/material.dart';
import 'features/home/screens/home_screen.dart';
import 'core/theme/app_colors.dart';

void main() {
  runApp(const MyTelUApp());
}

class MyTelUApp extends StatelessWidget {
  const MyTelUApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Tel U',
      theme: ThemeData(
        primaryColor: AppColors.primaryRed,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
