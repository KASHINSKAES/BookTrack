import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAT3nwoe2ZMG7JMpEtgDtq2q1rJ9nam0Fw",
    appId: "1:178335024089:android:bb1ca488b4b6ef0f37cfc8",
    messagingSenderId: "178335024089",
    projectId: "izla-a2a3d",
    storageBucket: "izla-a2a3d.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDEwuGeTPpoxkGDvmIQgqSgitL8L2MQG-Q",
    appId: "1:178335024089:ios:b0d1b990bd85d78b37cfc8",
    messagingSenderId: "178335024089",
    projectId: "izla-a2a3d",
    storageBucket: "izla-a2a3d.firebasestorage.app",
    iosBundleId: "YOUR_IOS_BUNDLE_ID",
  );

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyC3U262Pciu3HNyyAJtY3rky1pjW7RiHZE",
      authDomain: "izla-a2a3d.firebaseapp.com",
      projectId: "izla-a2a3d",
      storageBucket: "izla-a2a3d.firebasestorage.app",
      messagingSenderId: "178335024089",
      appId: "1:178335024089:web:c2f670b88742678937cfc8",
      measurementId: "G-S06XFDJ2TB");

  // Добавьте конфигурации для других платформ, если необходимо...
}
