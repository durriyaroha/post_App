// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyBl0kveLsYAoICi6lfAvSZXeO3To83qZ9Q',
    appId: '1:413685675395:web:a88321365314c6d8be32b6',
    messagingSenderId: '413685675395',
    projectId: 'authentication-app-5500f',
    authDomain: 'authentication-app-5500f.firebaseapp.com',
    storageBucket: 'authentication-app-5500f.appspot.com',
    measurementId: 'G-Z5HJTQ5D6J',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWOLLC6Vw6U-oJ2HhteE9aaoCvCPYpnik',
    appId: '1:413685675395:android:8d55cad5bbd0eae3be32b6',
    messagingSenderId: '413685675395',
    projectId: 'authentication-app-5500f',
    storageBucket: 'authentication-app-5500f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBxRN7ij2dQlX5C0aFuU7Fh-nrVbjWkSh0',
    appId: '1:413685675395:ios:d08b9c55058923fbbe32b6',
    messagingSenderId: '413685675395',
    projectId: 'authentication-app-5500f',
    storageBucket: 'authentication-app-5500f.appspot.com',
    iosBundleId: 'com.example.postApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBxRN7ij2dQlX5C0aFuU7Fh-nrVbjWkSh0',
    appId: '1:413685675395:ios:d08b9c55058923fbbe32b6',
    messagingSenderId: '413685675395',
    projectId: 'authentication-app-5500f',
    storageBucket: 'authentication-app-5500f.appspot.com',
    iosBundleId: 'com.example.postApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBl0kveLsYAoICi6lfAvSZXeO3To83qZ9Q',
    appId: '1:413685675395:web:fbc391ccf76b74bdbe32b6',
    messagingSenderId: '413685675395',
    projectId: 'authentication-app-5500f',
    authDomain: 'authentication-app-5500f.firebaseapp.com',
    storageBucket: 'authentication-app-5500f.appspot.com',
    measurementId: 'G-P1F0BCD389',
  );
}
