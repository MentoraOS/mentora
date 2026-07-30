import 'package:flutter/material.dart';
import 'employee/widgets/employee_header.dart';
import '../../screens/enterprise/employee/widgets/today_sessions_card.dart';
import '../../screens/enterprise/employee/widgets/learning_progress_card.dart';
import '../../screens/enterprise/employee/widgets/quick_actions_card.dart';
import '../../screens/enterprise/employee/employee_notifications_screen.dart';
import '../../screens/enterprise/employee/widgets/next_session_card.dart';
import '../../screens/enterprise/employee/widgets/learning_path_card.dart';

class EmployeeDashboardScreen extends StatelessWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),

        centerTitle: true,

        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) => const EmployeeNotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),

          child: Column(
            children: [
              EmployeeHeader(),

              SizedBox(height: 16),

              NextSessionCard(),

              SizedBox(height: 16),

              TodaySessionsCard(),

              SizedBox(height: 16),

              LearningProgressCard(),

              SizedBox(height: 16),

              LearningPathCard(),

              SizedBox(height: 16),

              QuickActionsCard(),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
