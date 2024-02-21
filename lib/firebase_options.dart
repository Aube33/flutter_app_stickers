// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAnzFB2DXYBwQuPWhM4QwoGNsQHr8AVnTE',
    appId: '1:918458013291:web:5ab646e7cf1e2a1a88832e',
    messagingSenderId: '918458013291',
    projectId: 'stickerapp-b8dd7',
    authDomain: 'stickerapp-b8dd7.firebaseapp.com',
    storageBucket: 'stickerapp-b8dd7.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_2nZSO9SQ794YDAXPJ0fx82jKJbRtWnM',
    appId: '1:918458013291:android:dc19fd291fd0d94188832e',
    messagingSenderId: '918458013291',
    projectId: 'stickerapp-b8dd7',
    storageBucket: 'stickerapp-b8dd7.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBSU7jskADKS8j8Aj5pem10BztCmcmB7Wc',
    appId: '1:918458013291:ios:587cb9df6afe1e4388832e',
    messagingSenderId: '918458013291',
    projectId: 'stickerapp-b8dd7',
    storageBucket: 'stickerapp-b8dd7.appspot.com',
    iosClientId: '918458013291-8mpk6sjqngvno47epsvq5r26l9ldis6k.apps.googleusercontent.com',
    iosBundleId: 'com.example.stickershub',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBSU7jskADKS8j8Aj5pem10BztCmcmB7Wc',
    appId: '1:918458013291:ios:683d4f3c0939d08988832e',
    messagingSenderId: '918458013291',
    projectId: 'stickerapp-b8dd7',
    storageBucket: 'stickerapp-b8dd7.appspot.com',
    iosClientId: '918458013291-7102qnl968rnrkjvjnke4lgqikcpnef6.apps.googleusercontent.com',
    iosBundleId: 'com.example.stickershub.RunnerTests',
  );
}
