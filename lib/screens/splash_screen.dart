import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'root_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RootShell()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 56),
                ),
                const SizedBox(height: 22),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, fontFamily: 'Inter'),
                    children: [
                      TextSpan(text: 'Drive', style: TextStyle(color: AppColors.textPrimary)),
                      TextSpan(text: 'Book', style: TextStyle(color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 28, height: 2, color: AppColors.primary.withValues(alpha: 0.4)),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 5, height: 5,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    ),
                    Container(width: 28, height: 2, color: AppColors.primary.withValues(alpha: 0.4)),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Daily Income & Expense\nTracker for Drivers',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14.5, height: 1.4),
                ),
              ],
            ),
          ),
          // Bottom wave
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: ClipPath(
              clipper: _WaveClipper(),
              child: Container(height: 160, color: AppColors.primary.withValues(alpha: 0.85)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.45);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.1, size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.7, size.width, size.height * 0.3);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
