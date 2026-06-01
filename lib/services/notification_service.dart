import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  static final
  FlutterLocalNotificationsPlugin
  notificationsPlugin =

  FlutterLocalNotificationsPlugin();

  static Future<void>
  init() async {

    const AndroidInitializationSettings
    androidSettings =

    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings
    settings = InitializationSettings(

      android: androidSettings,
    );

    await notificationsPlugin
        .initialize(settings);
  }

  static Future<void>
  mostrarNotificacion({

    required String titulo,

    required String mensaje,

  }) async {

    const AndroidNotificationDetails
    androidDetails =

    AndroidNotificationDetails(

      'koko_channel',

      'Koko Studio',

      channelDescription:
      'Notificaciones de Koko Studio',

      importance:
      Importance.max,

      priority:
      Priority.high,
    );

    const NotificationDetails
    details = NotificationDetails(

      android: androidDetails,
    );

    await notificationsPlugin.show(

      0,

      titulo,

      mensaje,

      details,
    );
  }
}