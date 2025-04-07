import 'dart:core';
import 'dart:math';
import 'package:ecg_health/Mata/models/basic.dart';
import 'package:ecg_health/Mata/models/graph.dart';
import 'package:ecg_health/authentication/numberAuth.dart';
import 'package:ecg_health/pages/body_measur.dart';
import 'package:ecg_health/pages/edit_profile.dart';
import 'package:ecg_health/pages/report_page.dart';
import 'package:ecg_health/pages/stepper.dart';
import 'package:extended_dart/core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Mata/models/date_time.dart';
import '../database/sql_database.dart';
import '../models/ecg_sql_models.dart';
import 'ecg_wifi.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

List<EcgModel> data = [];
Map<String, Color> colors= {};
List<bool> reportB = [true, false];
String selectedDateString = '';

bool singleLead=false;
class _DashboardScreenState extends State<DashboardScreen> {
  final dbHelper = DatabaseHelper.instance;

  List<EcgModel> information = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSQL();
    sharePre();
    greetingMessage = getGreeting();
  }

  sharePre() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool('isLogin', true);
    number = sharedPreferences.getString("Login_Number") ?? '';
    getDataFromFirebase();
  }

  String number = '';
  final cyclingColor = Colors.cyan;
  final quickWorkoutColor = Colors.blue;
  final betweenSpace = 0.2;

  BarChartGroupData generateGroupData(int x, double quickWorkout) {
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: [
        BarChartRodData(
          toY: quickWorkout,
          color: quickWorkoutColor,
          width: 15,
        ),
      ],
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    String text;
    text = "hello";
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: const TextStyle(fontSize: 10)),
    );
  }

  List<GraphSet> ecgData = [];

  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
    setState(() {});
  }

  String greetingMessage = "";

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }


  @override
  Widget build(BuildContext context) {
    selectedDateString = _selectedDate.toString();
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('$greetingMessage,', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 17)),
            Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 22)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(children: [Text('Average this week', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700),),],),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset('assets/speedometer.svg', height: 20, color: Colors.black),
                                  const SizedBox(width: 4),
                                  const Text('115/78', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                                ],
                              ),
                              Text('mmHg', style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset('assets/heart.svg', height: 20, color: Colors.black),
                                  const SizedBox(width: 4),
                                  const Text('120', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text('bpm', style: TextStyle(color: Colors.grey.shade600),),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Your average blood pressure and pulse readings this week were great. Keep up the good work!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600),),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {leadPopup();},
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B84FE), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24),),
                            ),
                            child: const Text('Add new data', style: TextStyle(color: Colors.white),),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('EEEE, d MMM yyyy').format(DateTime.now()), style: TextStyle(color: Colors.grey.shade600),),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('115/78 mmHg', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(height: height / 4,
                        color: Colors.grey.shade200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            titlesData: const FlTitlesData(
                              leftTitles: AxisTitles(),
                              rightTitles: AxisTitles(),
                              topTitles: AxisTitles(),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  /*getTitlesWidget: bottomTitles,*/
                                  reservedSize: 30,
                                ),
                              ),
                            ),
                            barTouchData: BarTouchData(enabled: false),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                            barGroups: [
                              generateGroupData(0, 80/10,),
                              generateGroupData(1, 75/10,),
                              generateGroupData(2, 71/10,),
                              generateGroupData(3, 64/10,),
                              generateGroupData(4, 73/10,),
                              generateGroupData(5, 66/10,),
                              generateGroupData(6, 82/10,),
                            ],
                            maxY: 11 + (betweenSpace * 3),
                            extraLinesData: ExtraLinesData(
                              horizontalLines: [
                                HorizontalLine(y: (2 + 1.7 + 2.8 + 3.1 + 3.4 + 1.8 + 2) / 7, color: quickWorkoutColor, strokeWidth: 1, dashArray: [20, 4],),
                                HorizontalLine(y: ((2 + 1.7 + 2.8 + 3.1 + 3.4 + 1.8 + 2) / 7) + (3 + 5 + 3.1 + 4 + 3.3 + 5.6 + 3.2) / 7, color: cyclingColor, strokeWidth: 1, dashArray: [20, 4],),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ToggleButtons(
                hoverColor: Colors.transparent,
                isSelected: reportB,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < reportB.length; i++) {
                      reportB[i] = i == index;
                    }
                    counter = 0;
                    if (reportB[0]) {
                      setState(() {});
                    }
                    if (reportB[1]) {
                      _selectDate();
                    }
                  });
                },
                borderWidth: 0,
                renderBorder: true,
                borderRadius: BorderRadius.circular(20),
                borderColor: Colors.transparent,
                highlightColor: Colors.transparent,
                selectedBorderColor: Colors.transparent,
                fillColor: Colors.transparent,
                selectedColor: Colors.white,
                color: Colors.black,
                children: [
                  Container(
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: reportB[0] ? Colors.blue : Colors.transparent,
                      ),
                      child: const Center(
                        child: Text(
                          'Recent',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      )),
                  Container(
                    width: 150,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: reportB[1] ? Colors.blue : Colors.transparent,
                    ),
                    child: const Center(
                        child: Text(
                      'View More',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ReportCards()
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0B84FE)),
              accountName: Text(userName),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(backgroundImage: NetworkImage(photo),),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)), onTap: () {Navigator.pop(context);},
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) {return const EditProfile();},));
              },
            ),
            ListTile(
              leading: const Icon(Icons.scale),
              title: const Text("Body Measurement", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) {return const BodyMeasurement();},));
              },
            ),
            ListTile(
              leading: const Icon(Icons.sos),
              title: const Text("Emergency Contact", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18)), onTap: () {Navigator.pop(context);},),
            ListTile(
              leading: const Icon(Icons.logout,),
              title: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.red),),
              onTap: () {_showLogoutDialog();},
            ),
          ],
        ),
      ),
    );
  }

  leadPosition() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select V Position'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('select quick V lead Position', style: TextStyle(fontWeight: FontWeight.bold,),),
                ],
              ),
              for(int i in Basic.range(stop: 1))Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [for(int j in Basic.range(stop: 2))VButton((i*3)+j)],)
            ],
          ),
        );
      },
    );
  }

  Widget VButton(int n) {

    String V = "V${n + 1}";
    return TextButton(
      style: TextButton.styleFrom(backgroundColor: Colors.blue,),
      onPressed: () {
        singleLead=true;
        Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          print("singleLead = $singleLead");
          return NetworkUtility(DateTime.now().toString(),V);},));
      }, child: Text(V, style: const TextStyle(color: Colors.white),),
    );
  }

  leadPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Select lead'),
              Container(
                alignment: Alignment.topRight,
                child: TextButton(onPressed: () {Navigator.pop(context);},
                  child: const Text('Close', style: TextStyle(color: Colors.red),),
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('select quick lead or 12 lead', style: TextStyle(fontWeight: FontWeight.bold,),),
                ],
              ), SizedBox(height: 20),
            ],
          ),
          actions: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(style: TextButton.styleFrom(backgroundColor: Colors.blue,),
                  onPressed: () {Navigator.of(context).pop();leadPosition();
                  }, child: const Text('Quick Lead', style: TextStyle(color: Colors.white),),
                ),
                TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.blue,), onPressed: () {Navigator.of(context).pop();
                V = 'V0';
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return Steps(DateTime.now().toString());
                    },));},
                  child: const Text('12 Lead', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    Navigator.of(context).pop();
    showDialog(context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(child: const Text('Cancel'), onPressed: () {Navigator.of(context).pop();},),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                var sharedPreferences = await SharedPreferences.getInstance();
                await sharedPreferences.setBool('isLogin', false);
                await sharedPreferences.setString('Login_Number', '');
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {return const NumberAuth();},), (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  ValueNotifier<double>? valueNotifier;
  String email = '';
  String userName = '';
  String photo = '';

  getDataFromFirebase() {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('users/$number/Profile');
    ref.onValue.listen((DatabaseEvent event) async {
      if (mounted) {
        setState(() {
          email = event.snapshot.child('email').value.toString();
          userName = event.snapshot.child('userName').value.toString();
          photo = event.snapshot.child('imageUrl').value.toString();
        });
      }
    });
  }

  bool isLoading = false;
  bool b = true;

  getSQL() async {
    setState(() {isLoading = true;});
    List<dynamic> selectData = await dbHelper.deviceInformationSelect();
    information = selectData
        .map((val) => EcgModel(
              id: val['id'],
              bpm: val['bpm'],
              avh: val['avh'],
              avl: val['avl'],
              st: val['st'],
              qrs: val['qrs'],
              pq: val['pq'],
              ecgList: val['ecgList'],
              dateTime: val['dateTime'],
              v: val['V'],
            )).toList();

    setState(() {isLoading = false;});
    setDataAsUi();
    data = data.toSet().toList();
  }

  setDataAsUi() {
    data.clear();
    for (EcgModel e in information) {
      EcgModel m = EcgModel(id: e.id, bpm: e.bpm, avh: double.parse(e.avh).toStringAsFixed(2), avl: double.parse(e.avl).toStringAsFixed(2), st: e.st, qrs: e.qrs, pq: e.pq, ecgList: e.ecgList, dateTime: e.dateTime, v: e.v);

      data.add(m);
    }
  }
}

class ReportCards extends StatefulWidget {
  @override
  State<ReportCards> createState() => _ReportCardsState();
}

int counter = 0;

class _ReportCardsState extends State<ReportCards> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: (data!=[])
          ? Column(children: [
              for (Widget e in fullWidgets(context)) e,
            ])
          : const Center(
              child: Text('Empty Data',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
    );
  }

  List<Widget> widgets = [];

  List<Widget> fullWidgets(BuildContext context) {
    counter = 0;
    widgets = [];
    //should clicked on Recent[toggle]
    if (reportB[0]) {
      for (final (ind, e) in data.reversed.indexed) {//reversed for get newest data
        int i = data.length - 1 - ind;//make index revers
        if (i == data.length - 1 || getDateFormat(data[i + 1].dateTime) != getDateFormat(e.dateTime)) {
          widgets.add(dateCard(e.dateTime));
          int r=data.countIf((element) => element.dateTime==e.dateTime);
          if(r>1 && !colors.keys.toList().contains(e.dateTime)) colors.addAll({e.dateTime:getRandomColor()});
        }
        widgets.add(getCard(context, e));
        if (++counter > 9) break;
      }
    } else {
      widgets = [dateCard(selectedDateString)];
      for (EcgModel e in data) {
        if (getDateFormat(selectedDateString) == getDateFormat(e.dateTime)) {
          widgets.add(getCard(context, e));
        }
      }
    }
    return widgets;
  }
  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,                // Alpha channel (opacity)
      random.nextInt(256), // Red channel
      random.nextInt(256), // Green channel
      random.nextInt(256), // Blue channel
    );
  }

  String getDateFormat(String s)
  {
    DateTime dateTime = DateTime.parse(s);
    String date=DT.dateFormat.format(dateTime);
    return date;
  }
  String getTimeFormat(String s)
  {
    DateTime dateTime = DateTime.parse(s);
    String time=DT.timeFormat.format(dateTime);
    return time;
  }

  Widget dateCard(String e) {
    return Card(elevation: 15,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(getDateFormat(e),style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
      ),
    );
  }

  Widget getCard(BuildContext context, EcgModel e) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return Report(e.dateTime);
          },
        ));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(child: Text(e.v),),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("BPM: ${e.bpm}",style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold)),
                  Text("Ave. Height: ${e.avh}",style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold)),
                  Text("Ave. Low: ${e.avl}",style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${getTimeFormat(e.dateTime)}",style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold)),
                  const Text("Status",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}