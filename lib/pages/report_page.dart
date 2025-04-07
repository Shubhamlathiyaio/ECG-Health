import 'package:ecg_health/main.dart';
import 'package:ecg_health/pages/report_analysis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Mata/models/graph.dart';
import '../database/sql_database.dart';
import '../models/ecg_sql_models.dart';

class Report extends StatefulWidget {
  String dateTime;

  Report(this.dateTime);

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final dbHelper = DatabaseHelper.instance;
  List<EcgModel> information = [];
  List<EcgModel> GraphData = [];
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeLeft,
    ]);
    getSQL();
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      enableMouseWheelZooming: true,
      enableDoubleTapZooming: true,
      enableSelectionZooming: true,
      zoomMode: ZoomMode.x,
    );
  }

  //late ZoomPanBehavior _zoomPanBehavior;
  navPage() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
      builder: (context) {
        return const BottomNavPage();
      },
    ), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
        return navPage();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Report Page"),
          leading: IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (context) {
                    return const BottomNavPage();
                  },
                ), (route) => false);
              },
              icon: const Icon(Icons.arrow_back_rounded)),
        ),
        body: GraphData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          for (int i = 0; i < GraphData.length; i++) graph(i),
                          const SizedBox(height: 010),
                          Card(
                            child: ListTile(
                              title: Center(
                                child: Text('BPM = ${GraphData[0].bpm}',
                                    style: const TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                              subtitle: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                          'HAV = ${double.parse(GraphData[0].avh).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          'LAV = ${double.parse(GraphData[0].avl).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                          'QRS = ${double.parse(GraphData[0].qrs).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          'PQ = ${double.parse(GraphData[0].pq).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Text(
                                      'ST = ${double.parse(GraphData[0].st).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          for(final (index,e) in GraphData.indexed) InkWell(onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return ReportAnalysis(e);
                            },));
                          },child: Container(margin: EdgeInsets.all(10),color: Colors.black12,width: double.infinity,height: height/1.712,))
                        ],
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget graph(int ind) {
    EcgModel graphData = GraphData[ind];
    List<GraphSet> ecgData = GraphSet.ecgDecode(graphData.ecgList);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Card(
                margin: const EdgeInsets.only(right: 40, bottom: 5, top: 10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${graphData.v} Report",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                )),
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
                  dataSource: ecgData,
                  xValueMapper: (GraphSet gs, int index) => gs.x,
                  yValueMapper: (GraphSet gs, int index) => gs.y,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  getSQL() async {
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
            ))
        .toList();
    List<EcgModel> vs = [
      for (EcgModel e in information)
        if (e.dateTime == widget.dateTime) e
    ];

    for (EcgModel e in vs) {
      GraphData.add(e);
    }
    setState(() {});
  }
}