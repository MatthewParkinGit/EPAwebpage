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
    apiKey: 'AIzaSyCefqzssvhkj-VYbbthKIolXQFUlKGD9Bk',
    appId: '1:63283006247:web:4d6d027179a023ed60f702',
    messagingSenderId: '63283006247',
    projectId: 'epawebpage',
    authDomain: 'epawebpage.firebaseapp.com',
    storageBucket: 'epawebpage.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBI4inX3bEL18dcvvC4j3w_cbENQMXurKg',
    appId: '1:63283006247:android:5bcbff64ee02c68660f702',
    messagingSenderId: '63283006247',
    projectId: 'epawebpage',
    storageBucket: 'epawebpage.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDnMR9ybQIUoQ7uUNi2nVwhkdILgEdfz-w',
    appId: '1:63283006247:ios:f46b85757d16210060f702',
    messagingSenderId: '63283006247',
    projectId: 'epawebpage',
    storageBucket: 'epawebpage.appspot.com',
    iosBundleId: 'com.example.mattyApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDnMR9ybQIUoQ7uUNi2nVwhkdILgEdfz-w',
    appId: '1:63283006247:ios:ee51b6a418d3c25e60f702',
    messagingSenderId: '63283006247',
    projectId: 'epawebpage',
    storageBucket: 'epawebpage.appspot.com',
    iosBundleId: 'com.example.mattyApp.RunnerTests',
  );
}