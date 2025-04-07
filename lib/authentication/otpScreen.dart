// ignore_for_file: must_be_immutable

import 'package:ecg_health/authentication/profilepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class OTPScreen extends StatefulWidget {
  String number;
  String verificationCode;

  OTPScreen({super.key, required this.number, required this.verificationCode});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String otpFill = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Verify your Number",
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          //"An OTP Code is sent to ${widget.number}",
                          "An OTP Code is sent to +919876543210",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        child: Lottie.asset("assets/otpanimation.json"),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Please Enter OTP Code",
                            style: TextStyle(color: Colors.orange),
                          ),
                          Text(
                            "00:29",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      OtpTextField(
                        numberOfFields: 6,
                        showFieldAsBox: true,
                        fieldWidth: 50,
                        fieldHeight: 50,
                        fillColor: const Color(0x00000000),
                        enabledBorderColor: const Color(0xff42abc1),
                        focusedBorderColor: const Color(0xff42abc1),
                        borderWidth: 2,
                        margin: const EdgeInsets.only(left: 2, right: 2),
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        obscureText: false,
                        cursorColor: const Color(0xff42abc1),
                        borderRadius: BorderRadius.circular(3),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 20,
                          color: Color(0xff000000),
                        ),
                        onCodeChanged: (String code) {},
                        onSubmit: (String verificationCode) {
                          otpFill = verificationCode;
                          codeSend(verificationCode);
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      InkWell(
                        onTap: () {
                          if (otpFill.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Enter OTP'),
                            ));
                          } else if (otpFill.length < 6) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Enter at least 6 characters'),
                            ));
                          } else {
                            codeSend(otpFill);
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xff42abc1),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5.0,
                                offset: Offset(0.0, 2.0),
                              ),
                            ],
                          ),
                          child: const Text(
                            "VERIFY",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  bool isLoading = false;

  codeSend(String otp) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      await FirebaseAuth.instance
          .signInWithCredential(PhoneAuthProvider.credential(
        verificationId: widget.verificationCode,
        smsCode: otp,
      ))
          .then((value) async {
        getData();
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("OTP invalid"),
            content: const Text("please enter correct OTP"),
            actions: [
              TextButton(
                onPressed: () {
                  otp = "";
                  Navigator.pop(context);
                },
                child: const Text("Ok"),
              ),
            ],
          );
        },
      );
    }
  }

  var temp;

  getData() {
    print('IN getData');
    DatabaseReference ref = FirebaseDatabase.instance.ref('users');
    ref.onValue.listen((DatabaseEvent event) async {
      //if (mounted) {
        setState(() {
          print('IN ref');
          temp = event.snapshot.child(widget.number).value;
          print("temp = $temp");
        });
      //}

      var sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString('Login_Number', widget.number);

      if (temp == null) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) {
            return ProfilePage(number: widget.number);
          },
        ), (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) {
            return const BottomNavPage();
          },
        ), (route) => false);
      }
    });
  }
}
