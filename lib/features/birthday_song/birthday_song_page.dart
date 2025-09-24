import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:happybday_song_app/services/youtube_birthday_service.dart';

class BirthdaySongPage extends StatefulWidget {
  const BirthdaySongPage({super.key});

  @override
  State<BirthdaySongPage> createState() => _BirthdaySongPageState();
}

class _BirthdaySongPageState extends State<BirthdaySongPage> {
  final _nameController = TextEditingController();
  final _service = YoutubeBirthdayService();
  final List<String> _recentNames = [];
  final List<String> _suggestedNames = const ['Ada', 'Eylül', 'Atlas', 'Luna'];
  final Set<String> _favoriteNames = <String>{};

  YoutubePlayerController? _playerController;
  bool _isSearching = false;
  String? _errorMessage;
  int _currentTab = 0;
  String? _currentPlayingName;

  @override
  void dispose() {
    _nameController.dispose();
    _playerController?.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _onPlayPressed() async {
    FocusScope.of(context).unfocus();
    final enteredName = _nameController.text.trim();

    if (enteredName.isEmpty) {
      setState(() => _errorMessage = 'Lütfen bir isim yaz.');
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final videoId = await _service.findBirthdaySongVideoId(enteredName);
      if (!mounted) return;

      if (videoId == null) {
        final controller = _preparePlayerController(null);
        setState(() {
          _playerController = controller;
          _isSearching = false;
          _currentPlayingName = null;
          _errorMessage =
              'YouTube üzerinde "$enteredName" için uygun bir doğum günü şarkısı bulunamadı.';
        });
        return;
      }

      final controller = _preparePlayerController(videoId);
      setState(() {
        _playerController = controller;
        _isSearching = false;
        _currentPlayingName = enteredName;
        _rememberRecentName(enteredName);
      });
    } on MissingYoutubeApiKeyException {
      final controller = _preparePlayerController(null);
      setState(() {
        _playerController = controller;
        _isSearching = false;
        _currentPlayingName = null;
        _errorMessage =
            'YouTube API anahtarı bulunamadı. Uygulamayı "--dart-define=YOUTUBE_API_KEY=YOUR_KEY" ile başlatın.';
      });
    } on YoutubeApiException catch (error) {
      final controller = _preparePlayerController(null);
      setState(() {
        _playerController = controller;
        _isSearching = false;
        _currentPlayingName = null;
        _errorMessage =
            'YouTube isteği başarısız oldu (HTTP ${error.statusCode}). Lütfen tekrar deneyin.';
      });
    } catch (_) {
      final controller = _preparePlayerController(null);
      setState(() {
        _playerController = controller;
        _isSearching = false;
        _currentPlayingName = null;
        _errorMessage =
            'Şarkıyı bulurken bir sorun oluştu. İnternet bağlantınızı kontrol edip tekrar deneyin.';
      });
    }
  }

  void _rememberRecentName(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty) return;

    _recentNames.remove(normalized);
    _recentNames.insert(0, normalized);
    if (_recentNames.length > 6) {
      _recentNames.removeRange(6, _recentNames.length);
    }
  }

  void _onSuggestedNameTap(String name) {
    _nameController.text = name;
    _nameController.selection = TextSelection.fromPosition(
      TextPosition(offset: _nameController.text.length),
    );
    _onPlayPressed();
  }

  YoutubePlayerController? _preparePlayerController(String? videoId) {
    _playerController?.pause();
    _playerController?.dispose();
    _playerController = null;

    if (videoId == null || videoId.isEmpty) {
      return null;
    }

    return YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, enableCaption: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: _buildBottomNavigation(theme),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFDECF0), Color(0xFFF8F6F6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  _currentTab == 0
                      ? _buildHomeContent(theme)
                      : _buildFavoritesContent(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(ThemeData theme) {
    return SingleChildScrollView(
      key: const ValueKey('home'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Kimin için çalıyoruz?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF221015),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          _buildSearchCard(theme),
          const SizedBox(height: 28),
          _buildRecentNames(theme),
          const SizedBox(height: 24),
          _buildPlayerSection(theme),
          const SizedBox(height: 24),
          _buildTips(theme),
        ],
      ),
    );
  }

  Widget _buildFavoritesContent(ThemeData theme) {
    final favorites = _favoriteNames.toList()..sort();
    return SingleChildScrollView(
      key: const ValueKey('favorites'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favoriler',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF221015),
            ),
          ),
          const SizedBox(height: 16),
          if (favorites.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    color: Color(0xFFF47192),
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Henüz favori eklenmedi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3D2C33),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bir şarkıyı çaldıktan sonra “Favorilere ekle” butonuyla buraya kaydedebilirsin.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6F5E67),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children:
                  favorites.map((name) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          color: Colors.white.withOpacity(0.75),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0x33F47192),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Color(0xFFF47192),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF38272F),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _playFavorite(name),
                                child: const Text('Çal'),
                              ),
                              IconButton(
                                onPressed: () => _onFavoriteToggle(name),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'İsim yaz veya önerilerden seç',
                  prefixIcon: Icon(
                    Icons.music_note_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                onSubmitted: (_) => _onPlayPressed(),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    _suggestedNames.map((name) {
                      return ChoiceChip(
                        label: Text(name),
                        selected: false,
                        onSelected:
                            _isSearching
                                ? null
                                : (_) => _onSuggestedNameTap(name),
                        backgroundColor: const Color(0x33F47192),
                        labelStyle: const TextStyle(
                          color: Color(0xFFF47192),
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _isSearching ? null : _onPlayPressed,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  shadowColor: Colors.black12,
                ),
                child:
                    _isSearching
                        ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Şarkıyı Çal'),
              ),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child:
                    _errorMessage == null
                        ? const SizedBox.shrink()
                        : Container(
                          key: const ValueKey('error'),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
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

  Widget _buildRecentNames(ThemeData theme) {
    if (_recentNames.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Son aramalar',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'İsmi yazdıkça burada son aramalarını göreceksin.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6F5E67),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Son aramalar',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              _recentNames.map((name) {
                return FilterChip(
                  label: Text(name),
                  avatar: const Icon(
                    Icons.history,
                    size: 18,
                    color: Color(0xFF4A3C42),
                  ),
                  selected: false,
                  onSelected:
                      _isSearching ? null : (_) => _onSuggestedNameTap(name),
                  labelStyle: const TextStyle(
                    color: Color(0xFF4A3C42),
                    fontWeight: FontWeight.w600,
                  ),
                  shape: const StadiumBorder(),
                  backgroundColor: Colors.white.withOpacity(0.9),
                  side: BorderSide.none,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlayerSection(ThemeData theme) {
    final currentName = _currentPlayingName;
    final borderRadius = BorderRadius.circular(24);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: borderRadius,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child:
                _playerController == null
                    ? Container(
                      key: const ValueKey('placeholder'),
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8D7D9), Color(0xFFD6C6C9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                size: 42,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Şarkı burada belirecek',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : AspectRatio(
                      key: ValueKey(_playerController!.initialVideoId),
                      aspectRatio: 16 / 9,
                      child: YoutubePlayer(
                        controller: _playerController!,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: theme.colorScheme.primary,
                      ),
                    ),
          ),
        ),
        if (currentName != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextButton.icon(
              onPressed: () => _onFavoriteToggle(currentName),
              icon: Icon(
                _favoriteNames.contains(currentName)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: const Color(0xFFF47192),
              ),
              label: Text(
                _favoriteNames.contains(currentName)
                    ? 'Favorilerden çıkar'
                    : 'Favorilere ekle',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF38272F),
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                foregroundColor: const Color(0xFF38272F),
                backgroundColor: Colors.white.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTips(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x33F47192),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Color(0xFFF47192)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'İsme takma ad veya sevdiği müzik tarzını eklemek sonuçları zenginleştirir (ör. “Mert rock”).',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  void _onFavoriteToggle(String name) {
    setState(() {
      if (_favoriteNames.contains(name)) {
        _favoriteNames.remove(name);
      } else {
        _favoriteNames.add(name);
      }
    });

    if (!mounted) return;
    final added = _favoriteNames.contains(name);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added ? 'Favorilere eklendi: $name' : 'Favorilerden çıkarıldı: $name',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _playFavorite(String name) {
    setState(() {
      _currentTab = 0;
      _nameController.text = name;
    });
    _onPlayPressed();
  }

  Widget _buildBottomNavigation(ThemeData theme) {
    return BottomNavigationBar(
      currentIndex: _currentTab,
      onTap: (index) => setState(() => _currentTab = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoriler'),
      ],
    );
  }
}
