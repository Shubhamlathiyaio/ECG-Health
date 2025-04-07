// import '../../Mata/models/graph.dart';
//
// class Spike {
//   GraphSet p;
//   GraphSet q;
//   GraphSet r;
//   GraphSet s;
//   GraphSet t;
//   num pq=0;
//   num qrs=0;
//   num st=0;
//
//   Spike({required this.p, required this.q, required this.r, required this.s, required this.t})
//   {
//     pq=(q.x-p.x);
//     qrs=(s.x-q.x);
//     st=(t.x-s.x);
//   }
//
//   factory Spike.froModel(Map<String, dynamic> map) {
//     return Spike(p: map["P"], q: map["Q"], r: map["R"], s: map["S"], t: map["T"]);
//   }
//
//   Map<String, dynamic> toMap() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['P'] = p;
//     data['Q'] = q;
//     data['R'] = r;
//     data['S'] = s;
//     data['T'] = t;
//     return data;
//   }
// }
