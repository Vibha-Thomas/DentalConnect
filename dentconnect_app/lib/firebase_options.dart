import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA99Vs71rHACQ1SHFwBL_KM5GRum3ODSsk',
    appId: '1:638565164190:android:07ff0ae59b010a6673478f',
    messagingSenderId: '638565164190',
    projectId: 'dentconnect-74549',
    storageBucket: 'dentconnect-74549.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD8ZyxI-45It85dTzhQcHiNakn255Bea7k',
    appId: '1:638565164190:ios:9caebc4dbf8ae11573478f',
    messagingSenderId: '638565164190',
    projectId: 'dentconnect-74549',
    storageBucket: 'dentconnect-74549.firebasestorage.app',
    iosClientId: '638565164190-gpe4fsm8ved2op1uftrtm0scpsst172c.apps.googleusercontent.com',
    iosBundleId: 'com.dentconnect.mobile',
  );
}
