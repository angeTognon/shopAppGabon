import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _screens = [
    OnboardingData(
      title: 'Scannez et gagnez',
      description: 'Collectez des points pour chaque achat en scannant le QR code dans le commerce',
      image: 'assets/images/o1.jpg',
      icon: Icons.qr_code_scanner,
      color: const Color.fromARGB(255, 99, 159, 255),
    ),
    OnboardingData(
      title: 'Échangez vos points',
      description: 'Transformez vos points en récompenses exclusives et offres personnalisées',
      image: 'assets/images/o2.jpg',
      icon: Icons.card_giftcard,
      color: const Color(0xFF8B5CF6),
    ),
    OnboardingData(
      title: 'Montez de niveau',
      description: 'Plus vous achetez, plus vous débloquez d\'avantages et de récompenses premium',
      image: 'assets/images/o3.jpg',
      icon: Icons.star,
      color: const Color(0xFFF59E0B),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _screens[_currentPage].color,
              _screens[_currentPage].color.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: widget.onComplete,
                      child: const Text(
                        'Passer',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: "b",
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _screens.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_screens[index]);
                  },
                ),
              ),
              
              // Progress indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _screens.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentPage ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentPage 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              
              // Next button
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _screens.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        widget.onComplete();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == _screens.length - 1 ? 'Commencer' : 'Suivant',
                          style: const TextStyle(
                            fontSize: 14,
                  fontFamily: "r",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon and Image
          Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  data.icon,
                  size: 60,
                  color: Colors.white,
                ),
              ).animate().scale(delay: 200.ms, duration: 600.ms),
              
              const SizedBox(height: 20),
              
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  data.image,
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.width * 0.5,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.width * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        data.icon,
                        size: 60,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ).animate().slideY(delay: 400.ms, duration: 600.ms),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Text content
          Column(
            children: [
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: "b",
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
              
              const SizedBox(height: 16),
              
              Text(
                data.description,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: "r",
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
    required this.color,
  });
}