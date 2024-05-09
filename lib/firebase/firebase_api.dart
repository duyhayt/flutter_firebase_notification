import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.max,
);

class FirebaseApi {
  final _messaging = FirebaseMessaging.instance;
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initialize notifications
  Future<void> initNotifications() async {
    /// Request permission
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    /// Fetch FCM Token
    final fcmToken = await _messaging.getToken();
    print(fcmToken);
  }

  /// Handle received messages
  Future<void> handleMessages() async {
    /// Received message foreground
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    /// Received message background
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? ios = message.notification?.apple;

      if (notification != null) {
        if (android != null) {
          {
            _flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(android: AndroidNotificationDetails(channel.id, channel.name, icon: '@mipmap/ic_launcher')),
            );
          }
        }
        if (ios != null) {
          {
            _flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              const NotificationDetails(iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true)),
            );
          }
        }
      }
    });
  }

  /// SETTING NOTIFITIONS
  Future<void> settingNotifications() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// SETTING NOTIFICATION OF PLUGIN FLUTTER_LOCAL_NOTIFICATION
    AndroidInitializationSettings initialzationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings initialzationSettingsIOS = const DarwinInitializationSettings();
    InitializationSettings(android: initialzationSettingsAndroid, iOS: initialzationSettingsIOS);
  }
}
