import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'numberAuth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sharePref();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text('ECG Health',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          )
        ],
      ),
    );
  }
  sharePref() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    bool isLogin = sharedPreferences.getBool('isLogin') ?? false;
    print("$isLogin");

    Timer(const Duration(seconds: 2), () {
      if (isLogin == true) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return const BottomNavPage();
          },
        ));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) {
            return const NumberAuth();
          },
        ));
      }
    });
  }
}
