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
    apiKey: 'AIzaSyAjU8x7G4IuATd_n-pKt7lTkEjoMIlrMPI',
    appId: '1:733650897032:web:a9b86a40380d3e76dbb73d',
    messagingSenderId: '733650897032',
    projectId: 'poczatki-fb158',
    authDomain: 'poczatki-fb158.firebaseapp.com',
    storageBucket: 'poczatki-fb158.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCZdMgiu3t8MCxwH1wgb676ewOt3xikpOs',
    appId: '1:733650897032:android:6e021690c3bf7b20dbb73d',
    messagingSenderId: '733650897032',
    projectId: 'poczatki-fb158',
    storageBucket: 'poczatki-fb158.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDyeTpGdZ8WzmjHJPwaOLBYCeOV9ahA_-o',
    appId: '1:733650897032:ios:bf43b23a5321d6b1dbb73d',
    messagingSenderId: '733650897032',
    projectId: 'poczatki-fb158',
    storageBucket: 'poczatki-fb158.appspot.com',
    iosBundleId: 'com.example.ogloszenia',
  );
}
