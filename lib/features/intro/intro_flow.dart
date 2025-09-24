import 'package:flutter/material.dart';

import 'package:happybday_song_app/features/birthday_song/birthday_song_page.dart';

class IntroFlow extends StatefulWidget {
  const IntroFlow({super.key});

  @override
  State<IntroFlow> createState() => _IntroFlowState();
}

class _IntroFlowState extends State<IntroFlow> {
  final PageController _pageController = PageController();
  final List<_IntroPageData> _pages = const [
    _IntroPageData(
      headline: 'HappyBday Song',
      description: 'İsme özel doğum günü melodisi saniyeler içinde.',
      bullets: [
        _IntroBullet(
          icon: Icons.celebration,
          text: 'İsim gir, sürpriz şarkıyı bul.',
        ),
        _IntroBullet(
          icon: Icons.play_circle,
          text: 'Video uygulama içinde oynar.',
        ),
        _IntroBullet(icon: Icons.share, text: 'Paylaş, tekrar çal.'),
      ],
      gradientColors: [Color(0xFFFDECF0), Color(0xFFF8F6F6)],
    ),
    _IntroPageData(
      headline: 'Kutlama Modu Açık',
      description: 'Trend isim önerileri ve mesaj taslakları tek ekranda.',
      bullets: [
        _IntroBullet(
          icon: Icons.auto_awesome,
          text: 'Özel tasarımlı kartlar ve animasyonlu arayüz.',
        ),
        _IntroBullet(
          icon: Icons.recommend,
          text: 'Tek dokunuşla önerilen isimleri dene.',
        ),
        _IntroBullet(
          icon: Icons.phone_iphone,
          text: 'Her ekranda kusursuz görünüm.',
        ),
      ],
      gradientColors: [Color(0xFFF5DEFF), Color(0xFFE4D7FF)],
    ),
    _IntroPageData(
      headline: 'Paylaş ve Sevindir',
      description: 'Şarkıyı bulduğun anda gönder veya kaydet.',
      bullets: [
        _IntroBullet(
          icon: Icons.favorite,
          text: 'Favorilere ekle, tekrar çalmak bir dokunuş.',
        ),
        _IntroBullet(
          icon: Icons.link,
          text: 'Bağlantı veya ekran görüntüsüyle sürprizi paylaş.',
        ),
        _IntroBullet(
          icon: Icons.shield,
          text: 'Güvenli arama ile kota dostu kullanım.',
        ),
      ],
      gradientColors: [Color(0xFFE2FFF7), Color(0xFFD3F4FF)],
    ),
  ];

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_currentPage == _pages.length - 1) {
      _goToApp();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToApp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const BirthdaySongPage(),
        transitionsBuilder:
            (_, animation, __, child) => FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: child,
            ),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder:
                    (context, index) => _IntroSlide(page: _pages[index]),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DotsIndicator(
                    pageCount: _pages.length,
                    currentIndex: _currentPage,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _onContinue,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Kutlamaya Başla'
                          : 'Devam',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _goToApp,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Geç'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroSlide extends StatelessWidget {
  const _IntroSlide({required this.page});

  final _IntroPageData page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: page.gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 36,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        page.headline,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF221015),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF5A4B52),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ...page.bullets.map(
                        (bullet) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0x33F47192),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  bullet.icon,
                                  color: const Color(0xFFF47192),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  bullet.text,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: const Color(0xFF38272F),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroPageData {
  const _IntroPageData({
    required this.headline,
    required this.description,
    required this.bullets,
    required this.gradientColors,
  });

  final String headline;
  final String description;
  final List<_IntroBullet> bullets;
  final List<Color> gradientColors;
}

class _IntroBullet {
  const _IntroBullet({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.pageCount, required this.currentIndex});

  final int pageCount;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: 8,
          width: isActive ? 20 : 8,
          decoration: BoxDecoration(
            color:
                isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}
