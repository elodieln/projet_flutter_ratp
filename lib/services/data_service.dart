// lib/services/data_service.dart
import 'dart:convert';
import 'dart:developer'; // <-- AJOUT 1/2 : Importer le service de log
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

    // log est comme un print, mais s'affiche joliment dans les DevTools
    log('Chargement initial des données terminé.'); // <-- AJOUT 2/2 : Nos points de contrôle
    log('Nombre total de lignes dans le JSON: ${data.length}');

    _allSegments = data
        .where((json) => json['from_type'] == 'stop_point' && json['to_type'] == 'stop_point')
        .map((json) => Positionnement.fromJson(json))
        .toList();
    
    log('Nombre de tronçons entre stations conservés: ${_allSegments.length}');

    final Set<String> names = {};
    for (var segment in _allSegments) {
      names.add(segment.fromName);
      names.add(segment.toName);
    }
    _stationNames = names.toList()..sort();
    log('Nombre de noms de stations uniques: ${_stationNames.length}');
  }

  List<Positionnement> get allSegments => _allSegments;
  List<String> get stationNames => _stationNames;
}