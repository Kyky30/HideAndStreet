import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:ui'; // Import ajouté
import 'package:flutter/material.dart';


class NotificationManager {
  static void initialize() {
    AwesomeNotifications().initialize(
      'resource://drawable/app_icon',
      [
        NotificationChannel(
          channelKey: 'chat_channel',
          channelName: 'Chat Channel',
          channelDescription: 'Notifications for Chat',
          defaultColor: Colors.green, // Assurez-vous d'avoir importé Colors
          ledColor: Colors.green, // Assurez-vous d'avoir importé Colors
          enableVibration: true,
        ),
      ],
    );
  }

  static void showChatNotification(String title, String body) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch,
        channelKey: 'chat_channel',
        title: title,
        body: body,
      ),
    );
  }
}
