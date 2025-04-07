import 'package:country_calling_code_picker/country.dart';
import 'package:country_calling_code_picker/country_code_picker.dart';
import 'package:country_calling_code_picker/functions.dart';
import 'package:ecg_health/authentication/otpScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NumberAuth extends StatefulWidget {
  const NumberAuth({super.key});

  @override
  State<NumberAuth> createState() => _NumberAuthState();
}

class _NumberAuthState extends State<NumberAuth> {
  Country? _selectedCountry;

  @override
  void initState() {
    initCountry();
    super.initState();
  }

  void initCountry() async {
    final list = await getCountries(context);
    Country country =
        list.where((element) => element.name == "India").toList().first;
    setState(() {
      _selectedCountry = country;
    });
  }

  TextEditingController number = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final country = _selectedCountry;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: SizedBox(
                    height: height / 1.1,
                    width: width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        const Text(
                          "Welcome to\nHealthCare",
                          style: TextStyle(
                              color: Color(0xff42abc1),
                              fontSize: 30,
                              fontWeight: FontWeight.w500),
                        ),
                        Container(
                          child: Lottie.asset("assets/medianimation.json",height: height/2.4),
                        ),
                        const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Please Enter Phone Number",
                              style: TextStyle(color: Colors.orange),
                            )),
                        SizedBox(
                          height: height / 60,
                        ),
                        country == null
                            ? Container()
                            : InkWell(
                                onTap: () {
                                  _onPressedShowDialog();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      country.flag,
                                      package: countryCodePackageName,
                                      width: width / 12,
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Text(
                                      '${country.name} (${country.countryCode})  ${country.callingCode} ',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const Icon(Icons.arrow_drop_down)
                                  ],
                                ),
                              ),
                        SizedBox(
                          height: height / 40,
                        ),
                        SizedBox(
                          // height: height / 14,
                          child: TextField(
                            controller: number,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            decoration: InputDecoration(
                                counter: const SizedBox(),
                                label: const Text(
                                  "Phone Number",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          ),
                        ),
                        SizedBox(
                          height: height / 60,
                        ),
                        InkWell(
                          onTap: () {
                            if (number.text.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Enter Mobile Number'),
                              ));
                            } else if (number.text.length < 10) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Enter at least 10 characters'),
                              ));
                            } else {
                              _verifyPhone();
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: width / 1.2,
                            height: height / 16,
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
                              "GET OTP",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading) ...[
            ModalBarrier(
              color: Colors.black.withOpacity(0.3),
              dismissible: false,
            ),
            const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool isLoading = false;
  String _verificationCode = '';

  _verifyPhone() async {
    print('12-=-=-=${number.text}');
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91${number.text}",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading = false;
          setState(() {});
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Firebase error"),
                content: Text("${e.message}"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Ok"),
                  ),
                ],
              );
            },
          );
        },
        codeSent: (String? verificationID, int? resendToken) {
          setState(
            () {
              _verificationCode = verificationID!;
              setState(() {
                isLoading = false;
              });

              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) {
                  return OTPScreen(
                      number: "+91${number.text}",
                      verificationCode: _verificationCode);
                },
              ), (route) => false);
            },
          );
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          _verificationCode = verificationID;
        },
        timeout: const Duration(seconds: 60),
      );
    } on FirebaseAuthException {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onPressedShowDialog() async {
    final country = await showCountryPickerDialog(
      context,
    );
    if (country != null) {
      setState(() {
        _selectedCountry = country;
      });
    }
  }
}
