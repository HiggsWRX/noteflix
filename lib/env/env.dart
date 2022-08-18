import 'package:envied/envied.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

part 'env.g.dart';

@Envied(path: kDebugMode ? '.env' : '.env.production')
abstract class Env {
  @EnviedField()
  static const String firebaseProjectId = 'noteflix-a';

  @EnviedField()
  static const String firebaseStorageBucket = 'noteflix-a.appspot.com';

  @EnviedField()
  static const String firebaseMessagingSenderId = '633209044494';

  @EnviedField()
  static const String firebaseAndroidApiKey =
      'AIzaSyA9g0T3oPpyb2PT0L2-s7eDvToACkbkAPs';

  @EnviedField()
  static const String firebaseAndroidAppId =
      '1:633209044494:android:bbd6469960e3496e8e065f';

  @EnviedField()
  static const String firebaseIOSApiKey =
      'AIzaSyA-pWQA54JoMJj6zAuYO-mjutxn2j8lM4Q';

  @EnviedField()
  static const String firebaseIOSAppId =
      '1:633209044494:ios:11f0af1e682bf2498e065f';

  @EnviedField()
  static const String firebaseIOSClientId =
      '633209044494-hlrorq6hpbmccre9paq6e9qq3tiek5gs.apps.googleusercontent.com';

  @EnviedField()
  static const String firebaseIOSBundleId = 'com.levelupknowledge.noteflix';
}
