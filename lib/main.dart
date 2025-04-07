import 'package:ecg_health/notifications/service.dart';
import 'package:ecg_health/pages/document_valt.dart';
import 'package:ecg_health/authentication/spalshscreen.dart';
import 'package:ecg_health/pages/dashboard.dart';
import 'package:ecg_health/pages/report.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationService().initNotification();
  tz.initializeTimeZones();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitUp,
  ]).then((value) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class BottomNavPage extends StatefulWidget {
  const BottomNavPage({super.key});

  @override
  _BottomNavPageState createState() => _BottomNavPageState();
}

class _BottomNavPageState extends State<BottomNavPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitUp,
    ]);
  }

  final List<Widget> _pages = [
    const DashboardScreen(),
    const ReportPage(),
    const DocumentVault(),
  ];
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/layout.svg',
                color: _selectedIndex == 0
                    ? const Color(0xFF0B84FE)
                    : Colors.black),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/heart-rate-monitor.svg',
                color: _selectedIndex == 1
                    ? const Color(0xFF0B84FE)
                    : Colors.black),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/folder.svg',
                color: _selectedIndex == 2
                    ? const Color(0xFF0B84FE)
                    : Colors.black),
            label: 'Notes',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0B84FE),
        onTap: _onItemTapped,
      ),
    );
  }
}
