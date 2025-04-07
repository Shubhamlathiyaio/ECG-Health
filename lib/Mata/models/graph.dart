class GraphSet {
  GraphSet(this.x, this.y);

  final double x;
  final double y;

  static getMin(List<GraphSet> list) {
    GraphSet min = list.first;
    for (GraphSet e in list) {
      if (min.y > e.y) min = e;
    }
    return min;
  }

  static getMax(List<GraphSet> list) {
    GraphSet max = list.first;
    for (GraphSet e in list) {
      if (max.y < e.y) max = e;
    }
    return max;
  }
  static getAvg(List<GraphSet> list) {
    num sum = 0;
    for (GraphSet e in list) {
      sum += e.y;
    }
    return sum / list.length;
  }

  static getIndex(List<GraphSet>list, var e)
  {
    if(e is GraphSet)  e = e.x;

  }
  static print(GraphSet e)
  {
    return "X = ${e.x}\tY = ${e.y}";
  }

  static String ecgEncode(List<GraphSet> list)
  {
    String ecgData='';
    for (GraphSet e in list) {
      ecgData += "${e.x},${e.y}#";
    }
    return ecgData;
  }

  static List<GraphSet> ecgDecode(String list) {
    List<GraphSet> ecgData = [];
    for (final (index, e) in list.split("#").indexed) {
      if (index < list.length) {
        List temp = e.split(",");
        if (temp[0] != "" && temp[1] != "") {
          ecgData.add(GraphSet(double.parse(temp[0]), double.parse(temp[1])));
        }
      }
    }
    return ecgData;
  }
}
