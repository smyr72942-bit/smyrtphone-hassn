import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {

  static FirebaseOptions get currentPlatform {

    switch (defaultTargetPlatform) {

      case TargetPlatform.android:

        return const FirebaseOptions(

          apiKey: 'AIzaSyBN_evInHcodta_Vc8sqfkeZVHS7qA8v2M',

          appId: '1:30599832939:android:a7feacef5c4e84e5d6d82e',

          messagingSenderId: '30599832939',

          projectId: 'fursak-68238',

          storageBucket: 'fursak-68238.appspot.com',

        );

      case TargetPlatform.iOS:

      case TargetPlatform.macOS:

        return const FirebaseOptions(

          apiKey: 'AIzaSyBN_evInHcodta_Vc8sqfkeZVHS7qA8v2M',

          appId: '1:30599832939:ios:a7feacef5c4e84e5d6d82e',

          messagingSenderId: '30599832939',

          projectId: 'fursak-68238',

          storageBucket: 'fursak-68238.appspot.com',

          iosBundleId: 'com.fursak.app',

        );

      default:

        throw UnsupportedError('Unsupported platform for Firebase initialization');

    }

  }

}