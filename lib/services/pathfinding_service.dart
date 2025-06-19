// lib/services/pathfinding_service.dart
import 'dart:collection';
import 'dart:developer'; // <-- AJOUT 1/3 : Importer le service de log
import 'package:flutter/foundation.dart';

import '../models/positionnement.dart';
import 'data_service.dart';

class PathfindingParams {
  final String startStation;
  final String endStation;
  PathfindingParams({required this.startStation, required this.endStation});
}

Future<List<List<Positionnement>>> findJourneysInIsolate(PathfindingParams params) async {
  final dataService = DataService();
  await dataService.loadData();
  final allSegments = dataService.allSegments;

  final pathfinder = PathfindingService(allSegments);
  return pathfinder.findJourneys(
    startStation: params.startStation,
    endStation: params.endStation,
  );
}

class PathfindingService {
  final List<Positionnement> allSegments;
  final Map<String, List<Positionnement>> _adjacencyMap = {};

  PathfindingService(this.allSegments) {
    _buildAdjacencyMap();
  }

  void _buildAdjacencyMap() {
    for (var segment in allSegments) {
      if (!_adjacencyMap.containsKey(segment.fromName)) {
        _adjacencyMap[segment.fromName] = [];
      }
      _adjacencyMap[segment.fromName]!.add(segment);
    }
    // <-- AJOUT 2/3 : Log après la construction de la map
    log('Construction de la carte des trajets terminée. ${_adjacencyMap.length} stations de départ répertoriées.');
  }

  List<List<Positionnement>> findJourneys({
    required String startStation,
    required String endStation,
  }) {
    // <-- AJOUT 3/3 : Logs au début et à la fin de la recherche
    log('Lancement de la recherche de "$startStation" à "$endStation".');
    if (!_adjacencyMap.containsKey(startStation)) {
      log('ERREUR CRITIQUE: La station de départ "$startStation" n\'existe pas comme point de départ dans nos données.');
      return [];
    }

    final List<List<Positionnement>> foundJourneys = [];
    final Queue<List<Positionnement>> queue = Queue();

    if (startStation == endStation) return [];

    _adjacencyMap[startStation]?.forEach((segment) {
      queue.add([segment]);
    });

    log('Nombre de trajets initiaux depuis le départ: ${queue.length}');

    while (queue.isNotEmpty) {
      if (foundJourneys.length >= 5) break;
      final currentPath = queue.removeFirst();
      final lastSegment = currentPath.last;
      if (currentPath.length >= 4) {
        continue;
      }
      if (lastSegment.toName == endStation) {
        foundJourneys.add(currentPath);
        continue;
      }
      final nextPossibleSegments = _adjacencyMap[lastSegment.toName] ?? [];
      for (var nextSegment in nextPossibleSegments) {
        if (currentPath.length > 1 && nextSegment.toName == currentPath[currentPath.length - 2].toName) {
          continue;
        }
        final newPath = List<Positionnement>.from(currentPath);
        newPath.add(nextSegment);
        queue.add(newPath);
      }
    }

    foundJourneys.sort((a, b) => a.length.compareTo(b.length));
    
    log('Recherche terminée. ${foundJourneys.length} trajets trouvés avant le filtrage final.');

    return foundJourneys.take(5).toList();
  }
}