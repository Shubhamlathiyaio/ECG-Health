import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vertical_weight_slider/vertical_weight_slider.dart';

class BodyMeasurement extends StatefulWidget {
  const BodyMeasurement({super.key});

  @override
  _BodyMeasurementState createState() => _BodyMeasurementState();
}

class _BodyMeasurementState extends State<BodyMeasurement> {
  // for weight piker
  late WeightSliderController _controller;
  double _weight = 30.0;

  @override
  void initState() {
    super.initState();
    _controller = WeightSliderController(
        initialWeight: _weight, minWeight: 0, interval: 0.1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //end weight piker

  //for height piker
  int selectedFeet = 5;
  int selectedInches = 8;

  //end height piker

  void selectWeight() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 50,
                alignment: Alignment.center,
                child: Text(
                  "${_weight.toStringAsFixed(1)} kg",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: VerticalWeightSlider(
                  haptic: Haptic.heavyImpact,
                  isVertical: false,
                  controller: _controller,
                  decoration: const PointerDecoration(
                    width: 130,
                    height: 3,
                    largeColor: Color(0xFF898989),
                    mediumColor: Color(0xFFC5C5C5),
                    smallColor: Color(0xFFF0F0F0),
                    gap: 30,
                  ),
                  onChanged: (double value) {
                    setState(() {
                      _weight = value;
                    });
                  },
                  indicator: Container(
                    height: 3,
                    width: 200,
                    alignment: Alignment.centerLeft,
                    color: Colors.red[300],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void selectHeight() {
    final screenSize = MediaQuery.of(context).size;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: screenSize.height * 0.4,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: screenSize.height * 0.3,
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        backgroundColor: Colors.white,
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            selectedFeet =
                                index + 3; // Height range from 3 to 7 feet
                          });
                        },
                        children: List<Widget>.generate(5, (int index) {
                          return Center(
                            child: Text('${index + 3} ft'),
                          );
                        }),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        backgroundColor: Colors.white,
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            selectedInches =
                                index; // Height range from 0 to 11 inches
                          });
                        },
                        children: List<Widget>.generate(12, (int index) {
                          return Center(
                            child: Text('$index in'),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                child: const Text('Done'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBloodGroupPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        // Get the screen size
        final screenSize = MediaQuery.of(context).size;

        return Container(
          height: screenSize.height * 0.4, // 40% of the screen height
          color: const Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              Container(
                height: screenSize.height * 0.3, // 30% of the screen height
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      selectedBloodGroup = bloodGroups[index];
                    });
                  },
                  children: bloodGroups.map((bloodGroup) {
                    return Center(
                      child: Text(bloodGroup),
                    );
                  }).toList(),
                ),
              ),
              CupertinoButton(
                child: const Text('Done'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }


  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  String selectedBloodGroup = 'A+';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Body Measurement"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              GestureDetector(
                  onTap: () {
                    selectWeight();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Weight',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(_weight.toString().substring(0, 4),
                              style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                          const Icon(Icons.keyboard_arrow_right_outlined)
                        ],
                      ),
                    ],
                  )),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  selectHeight();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Height',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("$selectedFeet'$selectedInches",
                            style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        const Icon(Icons.keyboard_arrow_right_outlined)
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  _showBloodGroupPicker();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Blood Group',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(selectedBloodGroup,
                            style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        const Icon(Icons.keyboard_arrow_right_outlined)
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
//
// class HeightPickerDemo extends StatefulWidget {
//   @override
//   _HeightPickerDemoState createState() => _HeightPickerDemoState();
// }
//
// class _HeightPickerDemoState extends State<HeightPickerDemo> {
//   int selectedFeet = 5;
//   int selectedInches = 8;
//
//   void _showHeightPicker() {
//     showCupertinoModalPopup(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           height: 270,
//           color: Colors.white,
//           child: Column(
//             children: [
//               Container(
//                 height: 200,
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: CupertinoPicker(
//                         backgroundColor: Colors.white,
//                         itemExtent: 32.0,
//                         onSelectedItemChanged: (int index) {
//                           setState(() {
//                             selectedFeet = index + 3; // Height range from 3 to 7 feet
//                           });
//                         },
//                         children: List<Widget>.generate(5, (int index) {
//                           return Center(
//                             child: Text('${index + 3} ft'),
//                           );
//                         }),
//                       ),
//                     ),
//                     Expanded(
//                       child: CupertinoPicker(
//                         backgroundColor: Colors.white,
//                         itemExtent: 32.0,
//                         onSelectedItemChanged: (int index) {
//                           setState(() {
//                             selectedInches = index; // Height range from 0 to 11 inches
//                           });
//                         },
//                         children: List<Widget>.generate(12, (int index) {
//                           return Center(
//                             child: Text('$index in'),
//                           );
//                         }),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               CupertinoButton(
//                 child: const Text('Done'),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Height Picker Demo'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'Selected Height:',
//               style: TextStyle(fontSize: 24),
//             ),
//             Text(
//               '$selectedFeet ft $selectedInches in',
//               style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _showHeightPicker,
//               child: const Text('Select Height'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
