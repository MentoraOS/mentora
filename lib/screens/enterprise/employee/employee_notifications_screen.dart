import 'package:flutter/material.dart';

import 'widgets/notification_tile.dart';

class EmployeeNotificationsScreen extends StatelessWidget {
  const EmployeeNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff071B5B),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Notifications"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: const [
          Text(
            "Aujourd'hui",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 20),

          NotificationTile(
            icon: Icons.video_camera_front,
            color: Colors.green,
            title: "Session imminente",
            subtitle: "Leadership professionnel commence dans 30 minutes.",
            time: "Aujourd'hui",
          ),

          SizedBox(height: 14),

          NotificationTile(
            icon: Icons.school,
            color: Colors.orange,
            title: "Nouvelle formation",
            subtitle: "Finance avancée est disponible.",
            time: "Il y a 5 min",
          ),

          SizedBox(height: 30),

          Text(
            "Hier",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 14),

          NotificationTile(
            icon: Icons.workspace_premium,
            color: Colors.amber,
            title: "Certificat obtenu",
            subtitle: "Votre certificat Communication est prêt.",
            time: "Hier",
          ),
        ],
      ),
    );
  }
}
