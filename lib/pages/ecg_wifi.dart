import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ecg_health/Mata/models/graph.dart';
import 'package:ecg_health/database/sql_database.dart';
import 'package:ecg_health/main.dart';
import 'package:ecg_health/models/v0/v0_analysis.dart';
import 'package:ecg_health/models/v1_analysis.dart';
import 'package:ecg_health/pages/dashboard.dart';
import 'package:ecg_health/pages/report_page.dart';
import 'package:ecg_health/pages/stepper.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:udp/udp.dart';
import '../models/v2_analysis.dart';
import '../models/v3_analysis.dart';
import '../models/v4_analysis.dart';
import '../models/v5_analysis.dart';
import '../models/v6_analysis.dart';

const NAMEOFWIFI = "HeartBeat";

class NetworkUtility extends StatefulWidget {
  String now;
  String position;

  NetworkUtility(this.now, this.position, {super.key});

  @override
  State<NetworkUtility> createState() => _NetworkUtilityState();
}

class _NetworkUtilityState extends State<NetworkUtility> {
  late Endpoint multicastEndpoint;
  List<GraphSet> allData = [];
  List<GraphSet> heartBit = [];
  String ecgData = "";
  dynamic analysedData;
  dynamic recordData;
  dynamic finalData;

  int startingIndex = 0;
  int endingIndex = 0;

  // Duration when user click on startTime for analysing data
  sec10() async {
    // print("isAnalysis = ${analysedData!.isAnalysis}");
    startingIndex = allData.length - 1;
    await Future.delayed(const Duration(seconds: 2)).then(
      (value) {
        stopAnalysis = true;
        analysedData.isAnalysis = false;
        endingIndex = allData.length - 1;
        recordData = VSwitcher();
        Map<String,dynamic>
        m={
          'ecgData': GraphSet.ecgEncode(allData.sublist(startingIndex, endingIndex)),
          'finalData': finalData,
          'v': V
        };
        print("m['v'] = ${m['v']}");
        print("VsData.length = ${VsData.length}");
        VsData.add(m);
        print("singleLead = $singleLead");
        if(singleLead) {
          sqls(m['ecgData'], m['finalData'], m['v']);
          stopAnalysis=false;
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) {
              return Report(widget.now);
            },
          ));
        }
        else if (V == 'V6') {
          if(VsData.length==6 ) {
            for(Map<String,dynamic> e in VsData) sqls(e['ecgData'], e['finalData'], e['v']);
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) {
                return Report(widget.now);
              },
            ));
          } else {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("There is some problem${VsData.length}")));
          }

        } else {
          Navigator.pop(context, 'true');
        }
      },
    );
  }

  VSwitcher() {
    switch (V) {
      case "V0":
        return V0Analysis(heartBit);
      case "V1":
        return V1Analysis(heartBit);
      case "V2":
        return V2Analysis(heartBit);
      case "V3":
        return V3Analysis(heartBit);
      case "V4":
        return V4Analysis(heartBit);
      case "V5":
        return V5Analysis(heartBit);
      case "V6":
        return V6Analysis(heartBit);
    }
  }

  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    V = widget.position;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeLeft,
    ]);
    _zoomPanBehavior = ZoomPanBehavior(
        // Enables pinch zooming
        enablePinching: true);
    multicastEndpoint = Endpoint.multicast(
      InternetAddress('192.168.4.1'),
      port: const Port(5000),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      listenForMessages();
    });
    getNameOfWifi();
  }
  late Timer _timer;
  int _start = 10;
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }


  bool waitForStablingData = true;

  getDataFromNodeMCU() {
    var data = "Hello";
    var codec = const Utf8Codec();
    List<int> dataToSend = codec.encode(data);
    var addressesIListenFrom = InternetAddress.anyIPv4;
    int portIListenOn = 5000; //0 is random
    RawDatagramSocket.bind(addressesIListenFrom, portIListenOn)
        .then((RawDatagramSocket udpSocket) {
      udpSocket.forEach((RawSocketEvent event) async {
        if (event == RawSocketEvent.read) {
          Datagram? dg = udpSocket.receive();
          String rawData = utf8.decode(dg!.data);

          // For stabling data
          Future.delayed(const Duration(seconds: 5)).then(
            (value) {
              waitForStablingData = false;
            },
          );
          removeHalfData(rawData);
          analysedData = VSwitcher();
          finalData = recordData ?? analysedData;
          updateTheBPM();
        }
      });
      udpSocket.send(dataToSend, addressesIListenFrom, portIListenOn);
      print('Did send data on the stream..');
    });
  }

  removeHalfData(String rawData) {
    if (rawData != "Hello" && !waitForStablingData) {
      List data = rawData.split("/");
      double temp = 0.0;
      if (heartBit.length >= 2) temp = heartBit.last.x - heartBit.first.x;
      if (temp > 10000) heartBit.removeRange(0, heartBit.length ~/ 2);
      heartBit
          .add(GraphSet(double.parse(data[1]), double.parse(data[0]) / 6000));
      allData.add(heartBit.last);
      if (mounted) {
        setState(() {});
      }
    }
  }

  bool stopAnalysis = false;

  updateTheBPM() async {
    // print("!BPMFont = ${!BPMFont}\tisAnalysis = ${analysedData!.isAnalysis}");
    while (!stopAnalysis) {
      await Future.delayed(const Duration(milliseconds: 500)).then(
        (value) {
          UiBPM = analysedData.bpm;
        },
      );
    }
  }

  num UiBPM = 0;
  bool BPMFont = false;
  String wifiName = '';
  final info = NetworkInfo();

  getNameOfWifi() async {
    while (true) {
      final info = NetworkInfo();
      final demo = await info.getWifiName();
      // print("wifiName = $demo");
      wifiName = "HeartBeat"; //demo!.substring(1, demo.length - 1);
      // print("wifiName = $wifiName");
      Future.delayed(const Duration(milliseconds: 500)).then(
        (value) {
          if (mounted) {
            setState(() {});
          }
        },
      );
    }
  }

  navPage() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
      builder: (context) {
        return const BottomNavPage();
      },
    ), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return (wifiName != NAMEOFWIFI)
        ? WillPopScope(
            onWillPop: () {
              return navPage();
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text('ECG Graph'),
                leading: IconButton(
                    onPressed: () {
                      V = 'V0';
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (context) {
                          return const BottomNavPage();
                        },
                      ), (route) => false);
                    },
                    icon: const Icon(Icons.arrow_back_rounded)),
                actions: [Text(V)],
              ),
              body: const Center(
                  child: Text(
                "Please connect to HeartBeat WiFi from Setting > WiFi > HeartBeat",
                style: TextStyle(fontSize: 20),
              )),
            ),
          )
        : WillPopScope(
            onWillPop: () {
              return navPage();
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text('ECG Graph'),
                leading: IconButton(
                    onPressed: () {
                      V = 'V0';
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (context) {
                          return const BottomNavPage();
                          //return const DashboardScreen();
                        },
                      ), (route) => false);
                    },
                    icon: const Icon(Icons.arrow_back_rounded)),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Graph',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            V,
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                           Text(
                            '00:${_start.toString().padLeft(2, '0')}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SfCartesianChart(
                        zoomPanBehavior: _zoomPanBehavior,
                        primaryXAxis: NumericAxis(
                            plotBands: List.generate(
                              50,
                              (index) => PlotBand(
                                start: index.toDouble(),
                                end: (index + 1).toDouble(),
                                borderWidth: 1,
                                borderColor: Colors.red,
                              ),
                            ),
                            autoScrollingDelta: 3000,
                            majorGridLines: const MajorGridLines(
                              width: 1,
                              color: Colors.red,
                            ),
                            minorGridLines: const MinorGridLines(
                              width: 0.3,
                              color: Colors.red,
                              // dashArray: <double>[5,5]
                            ),
                            minorTicksPerInterval: 4),
                        primaryYAxis: const NumericAxis(
                            initialVisibleMinimum: 0,
                            autoScrollingDelta: 1000,
                            majorGridLines: MajorGridLines(
                              width: 1,
                              color: Colors.red,
                            ),
                            minorGridLines: MinorGridLines(
                              width: 0.3,
                              color: Colors.red,
                              // dashArray: <double>[5,5]
                            ),
                            minorTicksPerInterval: 4),
                        enableAxisAnimation: false,
                        series: <CartesianSeries<GraphSet, double>>[
                          LineSeries<GraphSet, double>(
                            animationDuration: 0,
                            dataSource: heartBit,
                            xValueMapper: (GraphSet sales, int index) =>
                                sales.x,
                            yValueMapper: (GraphSet sales, int index) =>
                                sales.y,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              dataSend("Divol_Tech");
                            },
                            child: const Text('Start'),
                          ),
                          ElevatedButton(
                              onPressed: () {
                                BPMFont = true;
                                if (finalData.isAnalysis) {
                                  sec10();
                                  startTimer();
                                } else {
                                  finalData.isAnalysis = false;
                                }
                              },
                              child: const Text("Recording"))
                        ],
                      ),
                      const SizedBox(height: 15),
                      finalData.bpm == 0
                          ? const CircularProgressIndicator()
                          : Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      'BPM = $UiBPM',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    Text(
                                      'PQ = ${(finalData.pq).round()}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      'Average High = ${(finalData.avgHigh).round()}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    Text(
                                      'QRS = ${(finalData.qrs).round()}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      'Average Low = ${(finalData.avgLow).round()}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    Text(
                                      'ST= ${(finalData.st).round()}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  final dbHelper = DatabaseHelper.instance;
  String formattedDate = '';


  sqls(String ecgData, var finalData,String v) async {
    await dbHelper.ecgInformation(
        finalData.bpm.toString(),
        finalData.avgHigh.toString(),
        finalData.avgLow.toString(),
        finalData.st.toString(),
        finalData.qrs.toString(),
        finalData.pq.toString(),
        ecgData,
        widget.now.toString(),
        v);
  }

  void dataSend(String message) async {
    var sender = await UDP.bind(Endpoint.any());
    var dataLength = await sender.send(message.codeUnits, multicastEndpoint);

    print('dataLength = $dataLength');
    stdout.write("$dataLength bytes sent.");

    sender.close();
  }

  void listenForMessages() async {
    getDataFromNodeMCU();
    var multicastEndpoint = Endpoint.multicast(InternetAddress("192.168.4.1"),
        port: const Port(5000));
    var receiver = await UDP.bind(multicastEndpoint);
    print('multicastEndpoint = $receiver');

    receiver.asStream().listen((datagram) {
      if (datagram != null) {
        var str = String.fromCharCodes(datagram.data);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(str),
        ));
        print('Received: $str');
      }
    });
  }
}
