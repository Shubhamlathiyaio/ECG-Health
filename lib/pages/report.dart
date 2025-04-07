import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('ECG Report',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 70,
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Column(
                      children: [
                        Text('HAV',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0B84FE))),
                        SizedBox(
                          child: Text('56',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 70,
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Column(
                      children: [
                        Text('LAN',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0B84FE))),
                        SizedBox(
                          child: Text('22',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 70,
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Column(
                      children: [
                        Text('BPM',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0B84FE))),
                        SizedBox(
                          child: Text('120',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 70,
                    decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Column(
                      children: [
                        Text('MVS',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0B84FE))),
                        SizedBox(
                          child: Text('70',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Row(
                children: [
                  Text('Graphical Views:',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B84FE))),
                ],
              ),
              SfCircularChart(
                series: <CircularSeries>[
                  DoughnutSeries<ChartData, String>(
                    dataSource: data,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    startAngle: 270,
                    endAngle: 90,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      builder: (dynamic data, dynamic point, dynamic series,
                          int pointIndex, int seriesIndex) {
                        return Text(
                          '${data.x}: ${data.y}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
              const Row(
                children: [
                  Text('ECG Details:',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B84FE))),
                ],
              ),
              Row(
                children: [
                  Text(formattedDate,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 22)),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Text('Report:',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0B84FE))),
                ],
              ),
              const SizedBox(height: 5),
              const Text(
                  "Displays the metrics HAV (56), LAN (22), BPM (120), MVS (70), a graphical doughnut chart of these metrics, and the current date formatted as 'Monday, 1 Jan 2024'.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  String formattedDate = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());

  List<ChartData> data = [
    ChartData('HAV', 56),
    ChartData('LAN', 22),
    ChartData('BPM', 120),
    ChartData('MVS', 70),
  ];
}

class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final double y;
}