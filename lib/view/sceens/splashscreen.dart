
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    // Simulate app loading delay

    _navigateAfterDelay();

  }
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    final session = _supabase.auth.currentSession;
    final user = _supabase.auth.currentUser;

    if (session != null && user != null) {
      // ✅ المستخدم متسجل دخول
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // ❌ المستخدم مش متسجل
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- 1. Centered SONAA Logo Placeholder ---
            // In a real app, replace this with your actual SVG or PNG asset
            Image.asset(
              'assets/images/splash.png', // Replace with your logo path

              width: MediaQuery.of(context).size.width/1.15,

            ),

            Text(
              'المنصة الصناعية الاولي في العالم العربي والعالم',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),   Text(
              'The First Arab Global industrial platform',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 60),

            // --- 2. Clean Loading Indicator ---
            SpinKitFadingCube(
              size: 30,
              color:Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
      // --- 3. "Powered by SONAA" Footer ---
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 40.0),
        child: Text(
          'Powered by SONAA',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFFCCCCCC), // Light Gray
          ),
        ),
      ),
    );
  }
}