// File generated based on firebase.json and google-services.json.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCgrvqZwFOEALcXdaipa1U7znupYAZUaUY',
    appId: '1:588767696668:android:26f2756e36ccd5b3970cd9',
    messagingSenderId: '588767696668',
    projectId: 'emptikko',
    databaseURL: 'https://emptikko-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'emptikko.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCgrvqZwFOEALcXdaipa1U7znupYAZUaUY',
    appId: '1:588767696668:web:6da29ba2284e2f49970cd9',
    messagingSenderId: '588767696668',
    projectId: 'emptikko',
    databaseURL: 'https://emptikko-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'emptikko.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCgrvqZwFOEALcXdaipa1U7znupYAZUaUY',
    appId: '1:588767696668:web:af3508233b2c6a61970cd9',
    messagingSenderId: '588767696668',
    projectId: 'emptikko',
    databaseURL: 'https://emptikko-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'emptikko.firebasestorage.app',
  );
}
