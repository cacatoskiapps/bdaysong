import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:happybday_song_app/config/app_config.dart';

class MissingYoutubeApiKeyException implements Exception {
  const MissingYoutubeApiKeyException();
}

class YoutubeApiException implements Exception {
  const YoutubeApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;
}

class YoutubeBirthdayService {
  YoutubeBirthdayService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String?> findBirthdaySongVideoId(String name) async {
    if (!AppConfig.hasYoutubeApiKey) {
      throw const MissingYoutubeApiKeyException();
    }

    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      return null;
    }

    final query = 'Happy birthday $normalizedName song';
    final uri = Uri.https('www.googleapis.com', '/youtube/v3/search', {
      'part': 'snippet',
      'q': query,
      'type': 'video',
      'maxResults': '5',
      'key': AppConfig.youtubeApiKey,
      'videoCategoryId': '10',
      'relevanceLanguage': 'tr',
      'safeSearch': 'moderate',
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw YoutubeApiException(response.statusCode, response.body);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['items'] as List<dynamic>?;
    if (items == null || items.isEmpty) {
      return null;
    }

    for (final item in items) {
      final map = item as Map<String, dynamic>;
      final id = map['id'] as Map<String, dynamic>?;
      if (id == null) continue;
      if (id['kind'] == 'youtube#video') {
        final videoId = id['videoId'] as String?;
        if (videoId != null && videoId.isNotEmpty) {
          return videoId;
        }
      }
    }

    return null;
  }

  void dispose() {
    _client.close();
  }
}
