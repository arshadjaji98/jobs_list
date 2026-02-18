import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    // Request notification permissions
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();
    print('🔔 Permission status: \\${settings.authorizationStatus}');

    // Get FCM token (for debugging)
    final fCMToken = await _firebaseMessaging.getToken(
      vapidKey:
          "BHKkQuXktZzJa8QQSfzYDLUTf195ZEo_SuqWC0UR50Qb6d8qYIrnZ8ZNitdarA7GfQZFx11DRwyPaY5oo2tTZ_8",
    );
    if (kDebugMode) {
      print('FCM Token: \\${fCMToken}');
    }

    // Subscribe to 'all' topic
    await _firebaseMessaging.subscribeToTopic('all');
    print('Subscribed to topic: all');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: \\${message.notification?.title}');
      // Optionally, show a local notification here using flutter_local_notifications
    });

    // Handle background & terminated state messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked!');
      // Optionally, navigate or show a dialog
    });
  }
}
