// lib/services/data_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/positionnement.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  List<Positionnement> _allSegments = [];
  List<String> _stationNames = [];

  Future<void> loadData() async {
    if (_allSegments.isNotEmpty) return;

    final String response = await rootBundle.loadString('asset/positionnement-dans-la-rame.json');
    final List<dynamic> data = await json.decode(response);

    // On filtre pour ne garder que les connexions entre stations (stop_point)
    _allSegments = data
        .where((json) => json['from_type'] == 'stop_point' && json['to_type'] == 'stop_point')
        .map((json) => Positionnement.fromJson(json))
        .toList();

    final Set<String> names = {};
    for (var segment in _allSegments) {
      names.add(segment.fromName);
      names.add(segment.toName);
    }
    _stationNames = names.toList()..sort();
  }

  List<Positionnement> get allSegments => _allSegments;
  List<String> get stationNames => _stationNames;
}