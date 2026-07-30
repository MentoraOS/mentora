import 'package:flutter/material.dart';

class NextSessionCard extends StatelessWidget {
  const NextSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Prochaine session",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    CircleAvatar(
                      backgroundColor: Colors.orangeAccent,
                      child: Icon(
                        Icons.video_camera_front,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "Leadership professionnel",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                const Text(
                  "Aujourd'hui • 14h00",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.play_arrow),
                    label: Text("Rejoindre la session"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
