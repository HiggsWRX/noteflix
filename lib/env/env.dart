import 'package:envied/envied.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

part 'env.g.dart';

@Envied(path: kDebugMode ? '.env' : '.env.production')
abstract class Env {
  @EnviedField(varName: 'FIREBASE_PROJECT_ID')
  static const String firebaseProjectId = _Env.firebaseProjectId;

  @EnviedField(varName: 'FIREBASE_STORAGE_BUCKET')
  static const String firebaseStorageBucket = _Env.firebaseStorageBucket;

  @EnviedField(varName: 'FIREBASE_MESSAGING_SENDER_ID')
  static const String firebaseMessagingSenderId =
      _Env.firebaseMessagingSenderId;

  @EnviedField(varName: 'FIREBASE_ANDROID_API_KEY')
  static const String firebaseAndroidApiKey = _Env.firebaseAndroidApiKey;

  @EnviedField(varName: 'FIREBASE_ANDROID_APP_ID')
  static const String firebaseAndroidAppId = _Env.firebaseAndroidAppId;

  @EnviedField(varName: 'FIREBASE_IOS_API_KEY')
  static const String firebaseIOSApiKey = _Env.firebaseIOSApiKey;

  @EnviedField(varName: 'FIREBASE_IOS_APP_ID')
  static const String firebaseIOSAppId = _Env.firebaseIOSAppId;

  @EnviedField(varName: 'FIREBASE_IOS_CLIENT_ID')
  static const String firebaseIOSClientId = _Env.firebaseIOSClientId;

  @EnviedField(varName: 'FIREBASE_IOS_BUNDLE_ID')
  static const String firebaseIOSBundleId = _Env.firebaseIOSBundleId;
}
