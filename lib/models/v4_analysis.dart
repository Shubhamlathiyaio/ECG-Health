import 'package:ecg_health/Mata/models/basic.dart';
import 'package:ecg_health/Mata/models/graph.dart';
import 'package:ecg_health/models/spike.dart';

class V4Analysis {
  GraphSet min = GraphSet(10000000.00, 10000000000.0);

  GraphSet max = GraphSet(0.0, 0.0);
  num average = 0;
  num dropDip = .75;
  num bpm = 0;
  num lastDropTime = 0.0;
  List<Spike> spikes = [];
  List<GraphSet> allData;
  List<double> analysisBpmList = [];
  bool isAnalysis = true;
  num pq = 0;
  num qrs = 0;
  num st = 0;
  num avgHigh = 0;
  num avgLow = 0;

  V4Analysis(this.allData) {
    min = allData.length > 1
        ? GraphSet.getMin(allData)
        : GraphSet(10000000.00, 10000000000.0);
    max = allData.length > 1 ? GraphSet.getMax(allData) : GraphSet(0.0, 0.0);
    average = GraphSet.getAvg(allData);
    // dropDip = .75;//min.y / 1.5;
    getSpikes();
    getOtherData();
  }

  getOtherData() {
    getBPM();
    pq = Basic.average([for (Spike e in spikes) e.pq]);
    qrs = Basic.average([for (Spike e in spikes) e.qrs]);
    st = Basic.average([for (Spike e in spikes) e.st]);
    avgHigh = GraphSet.getAvg([
      for (Spike e in spikes) GraphSet.getMax([e.p, e.q, e.r, e.s, e.t])
    ]);
    avgLow = GraphSet.getAvg([
      for (Spike e in spikes) GraphSet.getMin([e.p, e.q, e.r, e.s, e.t])
    ]);
    getAvgHigh(spikes);
  }

  getAvgHigh(List<Spike> list) {
    int start = 0;
    for (final (index, spike) in list.indexed) {}
  }

  getSpikes() {
    for (final (index, e) in allData.indexed) {
      if (e.y < dropDip && e.x - lastDropTime > 200) {
        // ⌄
        lastDropTime = e.x;
        if (index + 10 < allData.length && index > 25) {
          var drop = getSpike(index);
          if (drop != null) {
            spikes.add(drop);
          }
        }
      }
    }
  }

  getSpike(int dropPoint) {
    GraphSet S = allData[dropPoint];
    GraphSet R = GraphSet.getMax(allData.sublist(dropPoint-25,dropPoint));
    GraphSet Q = allData[allData.indexOf(R)-3];
    // print("9999999999999999999999999999999999999999999999999999999999999999999999999");
    // if(dropPoint+40 < allData.length) for(int i=dropPoint;i<dropPoint+40;i++) print("X = ${allData[i].x}\tY = ${allData[i].y}");
    if (allData.indexOf(S) < allData.length - 40 &&
        allData.length > 30 &&
        allData.indexOf(Q) > 20) {
      return Spike.froModel({
        "P": getP(allData.indexOf(Q)),
        "Q": Q,
        "R": allData[dropPoint],
        "S": S,
        "T": geT(allData.indexOf(S))
      });
    }
  }

  geT(int start) {
    List<GraphSet> list = allData.sublist(start, start + 40);
    GraphSet min = GraphSet.getMin(list);
    GraphSet max = GraphSet.getMax(list);
    num avg = GraphSet.getAvg(list);

    double avgSTtoMin = avg - min.y;
    double avgSTtoMax = max.y - avg;
    return avgSTtoMin > avgSTtoMax ? min : max;
  }

  getP(int end) {
    List<GraphSet> list = allData.sublist(end - 20, end);
    GraphSet min = GraphSet.getMin(list);
    GraphSet max = GraphSet.getMax(list);
    num avg = GraphSet.getAvg(list);

    double avgPQtoMin = avg - min.y;
    double avgPQtoMax = max.y - avg;
    return avgPQtoMin > avgPQtoMax ? min : max;
  }

  getBPM() {
    if (spikes.length > 1) {
      int r = spikes.length - 1;
      double timeDistance = spikes[r].r.x - spikes[r - 1].r.x;
      double distance = timeDistance / 200;
      if (distance > 0) {
        if (!isAnalysis) {
          bpm = (300 / distance).round();
        } else {
          analysisBpmList.add(300 / distance);
          double sum = 0;
          analysisBpmList.forEach((double element) {
            sum += element;
          });
          bpm = (sum / analysisBpmList.length).round();
        }
      }
      // print("BPM = $BPM");
      if (bpm < 45 || bpm > 200) {
        // print("1 = ${spikes[spikes.length - 2].r.x}");
        // print("2 = ${spikes[spikes.length - 1].r.x}");
      }
    }
  }

  getScore() {}
}