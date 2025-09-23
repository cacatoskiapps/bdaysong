import 'package:flutter/material.dart';
import 'package:happybday_song_app/services/youtube_birthday_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class BirthdaySongPage extends StatefulWidget {
  const BirthdaySongPage({super.key});

  @override
  State<BirthdaySongPage> createState() => _BirthdaySongPageState();
}

class _BirthdaySongPageState extends State<BirthdaySongPage> {
  final _nameController = TextEditingController();
  final _service = YoutubeBirthdayService();

  YoutubePlayerController? _playerController;
  bool _isSearching = false;
  String? _errorMessage;

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
      setState(() {
        _errorMessage = 'Lütfen bir isim yaz.';
      });
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
          _errorMessage =
              'YouTube üzerinde "$enteredName" için uygun bir doğum günü şarkısı bulunamadı.';
        });
        return;
      }

      final controller = _preparePlayerController(videoId);
      setState(() {
        _playerController = controller;
        _isSearching = false;
      });
    } on MissingYoutubeApiKeyException {
      final controller = _preparePlayerController(null);
      setState(() {
        _playerController = controller;
        _isSearching = false;
        _errorMessage =
            'YouTube API anahtarı bulunamadı. Uygulamayı "--dart-define=YOUTUBE_API_KEY=YOUR_KEY" ile başlatın.';
      });
    } on YoutubeApiException catch (error) {
      final controller = _preparePlayerController(null);
      setState(() {
        _playerController = controller;
        _isSearching = false;
        _errorMessage =
            'YouTube isteği başarısız oldu (HTTP ${error.statusCode}). Lütfen tekrar deneyin.';
      });
    } catch (_) {
      final controller = _preparePlayerController(null);
      setState(() {
        _playerController = controller;
        _isSearching = false;
        _errorMessage =
            'Şarkıyı bulurken bir sorun oluştu. İnternet bağlantınızı kontrol edip tekrar deneyin.';
      });
    }
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
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('HappyBday Song'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFEFF7), Color(0xFFFFD8ED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: theme.colorScheme.primary
                                    .withOpacity(.2),
                                child: Icon(
                                  Icons.cake_rounded,
                                  size: 34,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kişiye Özel Şarkı',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Text(
                                      'Bir isim yaz, doğum günü büyüsünü başlat.',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Özel Doğum Günü Şarkısı',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'İsmi yaz, "Çal" tuşuna bas ve o kişiye özel doğum günü şarkısını birlikte seçelim.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _nameController,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: 'Kimin için çalalım?',
                              prefixIcon: Icon(
                                Icons.music_note_rounded,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            onSubmitted: (_) => _onPlayPressed(),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _isSearching ? null : _onPlayPressed,
                            icon:
                                _isSearching
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                    : const Icon(Icons.play_arrow_rounded),
                            label: Text(
                              _isSearching ? 'Aranıyor...' : 'Şarkıyı Çal',
                            ),
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child:
                                _errorMessage == null
                                    ? const SizedBox.shrink()
                                    : Container(
                                      key: const ValueKey('error'),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.errorContainer,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        _errorMessage!,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  theme
                                                      .colorScheme
                                                      .onErrorContainer,
                                            ),
                                      ),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child:
                          _playerController == null
                              ? Container(
                                key: const ValueKey('placeholder'),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.play_circle_fill_rounded,
                                      size: 64,
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.7),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Şarkı burada belirecek',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Doğum günü kutlamasına hazır olun! 🎉',
                                      style: theme.textTheme.bodySmall,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                              : AspectRatio(
                                key: ValueKey(
                                  _playerController!.initialVideoId,
                                ),
                                aspectRatio: 16 / 9,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: YoutubePlayer(
                                    controller: _playerController!,
                                    showVideoProgressIndicator: true,
                                    progressIndicatorColor:
                                        theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
