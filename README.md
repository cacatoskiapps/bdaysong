# HappyBday Song App

HappyBday Song, kullanıcıdan isim alarak YouTube Data API üzerinden kişiye özel doğum günü şarkısını arayan ve uygulama içinde çalan basit bir Flutter uygulamasıdır.

## Özellikler
- `TextField` üzerinden isim girişi
- `Çal` butonu ile YouTube Data API v3 araması
- `youtube_player_flutter` paketiyle uygulama içi video oynatma
- YouTube API anahtarını `--dart-define` ile gizleyerek çalışma

## Gereksinimler
- Flutter SDK (>= 3.29.0)
- Android Studio ya da Xcode ile emülatör / cihaz kurulumu
- YouTube Data API v3 için API anahtarı

## Kurulum
```
flutter pub get
```

## Çalıştırma
API anahtarınızı ortam değişkeni olarak geçerek uygulamayı başlatın:
```
flutter run --dart-define=YOUTUBE_API_KEY=YOUR_API_KEY
```
Android, iOS ya da web hedeflerinden herhangi birine bağlanabilirsiniz.

## Test
```
flutter test
```

## Play Store’a Hazırlık
1. `android/app/src/main/AndroidManifest.xml` dosyasında internet izninin bulunduğunu doğrulayın (Flutter varsayılanı olarak eklenir).
2. Varsa özel ikon ve uygulama adını `android/app/src/main/res` klasörü ve `pubspec.yaml` üzerinden güncelleyin.
3. Sürüm kodu/sürüm numarasını `android/app/build.gradle` içinden ( `versionCode`, `versionName` ) hedef sürüme göre artırın.
4. Gerekli uygulama imza anahtarını oluşturup `key.properties` ile yapılandırın.
5. Yayına hazırlık için: `flutter build appbundle --dart-define=YOUTUBE_API_KEY=YOUR_API_KEY`
6. Üretilen `.aab` dosyasını Google Play Console’a yükleyin.

## Notlar
- YouTube API kota tüketimini kontrol edin; her arama kota harcar.
- Gerçek cihazlarda test ederek video oynatmanın çalıştığından emin olun.
- API anahtarınızı kaynak kodunda düz metin olarak saklamayın; CI/CD ortamlarında `--dart-define` kullanımına devam edin.
