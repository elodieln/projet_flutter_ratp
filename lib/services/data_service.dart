// lib/services/data_service.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:projet_ratp/models/positionnement.dart';

class DataService {
  Future<List<Positionnement>> loadData() async {
    try {
      final jsonString = await rootBundle.loadString('asset/positionnement-dans-la-rame.json');
      final List<dynamic> jsonResponse = json.decode(jsonString);
      return jsonResponse.map((data) => Positionnement.fromJson(data)).toList();
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      return [];
    }
  }
}