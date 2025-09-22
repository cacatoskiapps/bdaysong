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
      appBar: AppBar(
        title: const Text('HappyBday Song'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Özel Doğum Günü Şarkısı',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'İsmi yaz, "Çal" tuşuna bas ve o kişiye özel doğum günü şarkısını birlikte seçelim.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'İsim',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _onPlayPressed(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isSearching ? null : _onPlayPressed,
                      child: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Çal'),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (_playerController != null) ...[
                      const SizedBox(height: 24),
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: YoutubePlayer(
                            key: ValueKey(_playerController!.initialVideoId),
                            controller: _playerController!,
                            showVideoProgressIndicator: true,
                            progressIndicatorColor:
                                theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
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
