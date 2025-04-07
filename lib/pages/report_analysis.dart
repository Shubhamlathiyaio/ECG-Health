import 'package:ecg_health/models/ecg_sql_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../Mata/models/graph.dart';

class ReportAnalysis extends StatefulWidget {
  EcgModel e;
  ReportAnalysis(this.e, {super.key});

  @override
  State<ReportAnalysis> createState() => _ReportAnalysisState();
}

class _ReportAnalysisState extends State<ReportAnalysis> {
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeLeft,
    ]);
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      enableMouseWheelZooming: true,
      enableDoubleTapZooming: true,
      enableSelectionZooming: true,
      zoomMode: ZoomMode.x,
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(margin: EdgeInsets.symmetric(vertical: 20,horizontal: 15),color: Colors.cyan,height:height,width:width,child: Card(
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
                      "${widget.e.v} Report",
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
                    dataSource: GraphSet.ecgDecode(widget.e.ecgList),
                    xValueMapper: (GraphSet gs, int index) => gs.x,
                    yValueMapper: (GraphSet gs, int index) => gs.y,
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}