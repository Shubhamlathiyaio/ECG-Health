import 'package:ecg_health/pages/ecg_wifi.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:progress_stepper/progress_stepper.dart';

String V = 'V0';
List<Map<String, dynamic>> VsData=[];
class Steps extends StatefulWidget {
  String now;

  Steps(this.now);

  @override
  _StepsState createState() => _StepsState();
}

class _StepsState extends State<Steps> {
  int currentStep = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    V = "V${int.parse(V.split('')[1]) + 1}";
  }

  counter(){
    V = "V${int.parse(V.split('')[1]) + 1}";
    setState(() {
      currentStep++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Stepper Demo'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ProgressStepper(
              selectedTextStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              defaultTextStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              width: 340,
              height: 60,
              stepCount: 6,
              currentStep: currentStep,
              progressColor: Colors.green,
              color: Colors.blue,
              labels: List.generate(6, (index) => 'V ${index + 1}'),
              onClick: (index) {
                setState(() {
                  currentStep = index;
                });
              },
            ),
          ),
          Expanded(
              child: Lottie.asset('assets/Animation - 1721028473143.json')),
          ElevatedButton(
            onPressed: () async {
              String? callBack =
                  await Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return NetworkUtility(widget.now, V);
                },
              ));
              if ((callBack == null || callBack.isNotEmpty) &&
                  callBack == 'true') {
                counter();
              }
            },
            child: const Text('Next Step'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
