import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();
    print('🔔 Permission status: ${settings.authorizationStatus}');

    final fCMToken = await _firebaseMessaging.getToken(
      vapidKey:
          "BHKkQuXktZzJa8QQSfzYDLUTf195ZEo_SuqWC0UR50Qb6d8qYIrnZ8ZNitdarA7GfQZFx11DRwyPaY5oo2tTZ_8",
    );

    if (kDebugMode) {
      print('FCM Token: $fCMToken');
    }
  }
}
