// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [] for use with your Firebase apps.
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAFNe4bfPzuMcBRRo7DgjghB_y5E50XAk4',
    appId: '1:1068549993078:web:8331b5411fc7a51f5de557',
    messagingSenderId: '1068549993078',
    projectId: 'logisset',
    authDomain: 'logisset.firebaseapp.com',
    storageBucket: 'logisset.appspot.com',
    measurementId: 'G-3J4PVLTVQ2',
    databaseURL: "https://logisset-default-rtdb.firebaseio.com/",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDloYenUEkgd2-NQ00n8_7VpeCSAaNv6xw',
    appId: '1:1068549993078:android:63409862a368afe65de557',
    messagingSenderId: '1068549993078',
    projectId: 'logisset',
    storageBucket: 'logisset.appspot.com',
  );
}
