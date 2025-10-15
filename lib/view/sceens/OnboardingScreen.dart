import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _currentPageValue = 0.0; // لتتبع موقع الصفحة بدقة

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Connect with a World of Buyers',
      'subtitle': 'Connect with buyers and sellers from around the world. Your marketplace, your rules.',
      'image': 'assets/images/buyers.jpg',
    },
    {
      'title': 'Global Marketplace',
      'subtitle': 'List your products and reach millions of potential customers across different countries.',
      'image': 'assets/images/marcket.jpg',
    },
    {
      'title': 'Easy Posting in Seconds',
      'subtitle': 'List your items quickly with high-quality photos and detailed descriptions.',
      'image': 'assets/images/esy.png',
    },
    {
      'title': 'Communicate Securely',
      'subtitle': 'Trade with confidence. We prioritize your safety with verified sellers and secure transactions.',
      'image': 'assets/images/scuert.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    // استماع لتغييرات الصفحة بشكل مستمر
    _pageController.addListener(() {
      setState(() {
        _currentPageValue = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. Page View (Illustrations & Text) ---
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Placeholder for Illustration
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F8FF),
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage(_onboardingData[index]['image']!),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                        // Headline
                        Text(
                          _onboardingData[index]['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Subtext
                        Text(
                          _onboardingData[index]['subtitle']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // --- 2. Animated Dots Indicator ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                      (index) => buildAnimatedDot(index, context),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- 3. Navigation Buttons ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip Button
                  TextButton(
                    onPressed: () {
                      // Navigate to Home or Login/Register screen
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),

                  // Next / Get Started Button
                  SizedBox(
                    height: 45,
                    child: FilledButton(
                      onPressed: () {
                        if (_currentPage < _onboardingData.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeIn,
                          );
                        } else {
                          // Last page: Navigate to Home or Login/Register screen
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: _currentPage == _onboardingData.length - 1 ? 25 : 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: _currentPage == _onboardingData.length - 1
                          ? const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.navigate_next, size: 25),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Animated Dot Indicator Builder - مع أنيميشن سلس
  Widget buildAnimatedDot(int index, BuildContext context) {
    // حساب المسافة من الصفحة الحالية
    double distance = (_currentPageValue - index).abs();

    // حساب العرض بناءً على المسافة
    double width;
    if (distance < 0.5) {
      // الـ dot النشط
      width = 30.0 - (distance * 48); // يتقلص تدريجياً
    } else if (distance < 1.5) {
      // الـ dots المجاورة
      width = 6.0 + ((1.5 - distance) * 8); // تكبر قليلاً عند الاقتراب
    } else {
      // باقي الـ dots
      width = 6.0;
    }

    // حساب الشفافية
    double opacity;
    if (distance < 0.5) {
      opacity = 1.0;
    } else if (distance < 1.5) {
      opacity = 0.6 + ((1.5 - distance) * 0.4);
    } else {
      opacity = 0.3;
    }

    // حساب الارتفاع (تأثير نبض خفيف)
    double height = distance < 0.5 ? 8.0 : 7.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(right: 6),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(opacity),
        borderRadius: BorderRadius.circular(4),

      ),
    );
  }
}