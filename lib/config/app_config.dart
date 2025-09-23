class AppConfig {
  const AppConfig._();

  static const String youtubeApiKey = String.fromEnvironment(
    'YOUTUBE_API_KEY',
    defaultValue: '',
  );

  static bool get hasYoutubeApiKey => youtubeApiKey.isNotEmpty;
}
