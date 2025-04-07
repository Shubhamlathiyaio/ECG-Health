// import 'package:ecg_health/service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
//
// DateTime scheduleTime = DateTime.now();
//
// class Notifications extends StatefulWidget {
//   const Notifications({super.key});
//
//   @override
//   State<Notifications> createState() => _NotificationsState();
// }
//
// class _NotificationsState extends State<Notifications> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notification'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextButton(
//               onPressed: () {
//                 DatePicker.showDateTimePicker(
//                   context,
//                   showTitleActions: true,
//                   onChanged: (date) => scheduleTime = date,
//                   onConfirm: (date) {},
//                 );
//               },
//               child: const Text(
//                 'Select Date Time',
//                 style: TextStyle(color: Colors.blue),
//               ),
//             ),
//             ElevatedButton(
//               child: const Text('Schedule notifications'),
//               onPressed: () {
//                 debugPrint('Notification Scheduled for $scheduleTime');
//                 NotificationService().scheduleNotification(
//                     title: 'Divol Tech',
//                     body: 'Save Water Drink Kingfisher',
//                     scheduledNotificationDateTime: scheduleTime);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:ecg_health/notifications/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<Map<String, dynamic>> notifications = [];

  void _scheduleNotifications() {
    NotificationService().scheduleMultipleNotifications(notifications);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(
      content: Text('Notification Send'),
    ));
  }

  void _addNotification() {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onChanged: (date) {},
      onConfirm: (date) {
        setState(() {
          notifications.add({
            'title': 'Divol Tech',
            'body': 'Save Water Drink Kingfisher',
            'scheduledNotificationDateTime': date,
          });
          print('notification :$notifications');
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  notifications.clear();
                });
              },
              icon: const Icon(Icons.co2_sharp))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _addNotification,
              child: const Text('Add Notification'),
            ),
            ElevatedButton(
              onPressed: _scheduleNotifications,
              child: const Text('Schedule All Notifications'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(notifications[index]['title']),
                    subtitle: Text(notifications[index]
                            ['scheduledNotificationDateTime']
                        .toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
