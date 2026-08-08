import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _leftGloveSlide;
  late Animation<Offset> _rightGloveSlide;
  late Animation<double> _fadeAnimation;
  
  bool _isOverlayVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _leftGloveSlide = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(-2.0, 0), end: const Offset(-0.1, 0))
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(-0.1, 0), end: const Offset(-2.0, 0))
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _rightGloveSlide = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(2.0, 0), end: const Offset(0.1, 0))
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0.1, 0), end: const Offset(2.0, 0))
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 40,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) async {
    if (index == widget.navigationShell.currentIndex) {
      widget.navigationShell.goBranch(
        index,
        initialLocation: true,
      );
      return;
    }

    setState(() {
      _isOverlayVisible = true;
    });

    _controller.forward(from: 0.0);

    // Wait for the impact moment
    await Future.delayed(const Duration(milliseconds: 150));

    if (mounted) {
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    }

    // Wait for animation to finish sliding away
    await Future.delayed(const Duration(milliseconds: 150));

    if (mounted) {
      setState(() {
        _isOverlayVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.navigationShell,
          
          if (_isOverlayVisible)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5), // slight dim for focus
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SlideTransition(
                            position: _leftGloveSlide,
                            child: Transform.rotate(
                              angle: 0.3,
                              child: const Icon(
                                Icons.sports_mma,
                                size: 120,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                          SlideTransition(
                            position: _rightGloveSlide,
                            child: Transform(
                              alignment: Alignment.center,
                              // Flip horizontally and rotate inwards
                              transform: Matrix4.rotationY(3.14159)..rotateZ(-0.3),
                              child: const Icon(
                                Icons.sports_mma,
                                size: 120,
                                color: Colors.tealAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'chatbot_fab',
        onPressed: () {
          context.push('/chatbot');
        },
        backgroundColor: Colors.tealAccent,
        elevation: 4,
        child: const Icon(Icons.smart_toy, color: Colors.black87),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_mma_outlined),
            selectedIcon: Icon(Icons.sports_mma),
            label: 'Antrenman',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Sayaç',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: 'Sıralama',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
