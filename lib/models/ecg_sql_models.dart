import 'dart:convert';

class EcgModel {
  int id = 0;
  String bpm = '';
  String avh = '';
  String avl = '';
  String st = '';
  String qrs = '';
  String pq = '';
  String ecgList = '';
  String dateTime = '';
  String v = '';

  EcgModel({
    required this.id,
    required this.bpm,
    required this.avh,
    required this.avl,
    required this.st,
    required this.qrs,
    required this.pq,
    required this.ecgList,
    required this.dateTime,
    required this.v,
  });

  EcgModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bpm = json['bpm'];
    avh = json['avh'];
    avl = json['avl'];
    st = json['st'];
    qrs = json['qrs'];
    pq = json['pq'];
    ecgList = json['ecgList'];
    dateTime = json['dateTime'];
    v = json['V'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    //if (id != null) data['id'] = id;
    data['id'] = id;
    data['bpm'] = bpm;
    data['avh'] = avh;
    data['avl'] = avl;
    data['st'] = st;
    data['qrs'] = qrs;
    data['pq'] = pq;
    data['ecgList'] = ecgList;
    data['dateTime'] = dateTime;
    data['V'] = v;
    return data;
  }
}