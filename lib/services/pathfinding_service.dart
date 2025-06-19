// lib/services/pathfinding_service.dart
import 'dart:collection';
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
  }

  List<List<Positionnement>> findJourneys({
    required String startStation,
    required String endStation,
  }) {
    final List<List<Positionnement>> foundJourneys = [];
    final Queue<List<Positionnement>> queue = Queue();

    if (startStation == endStation) return [];

    _adjacencyMap[startStation]?.forEach((segment) {
      queue.add([segment]);
    });

    while (queue.isNotEmpty) {
      final currentPath = queue.removeFirst();
      final lastSegment = currentPath.last;

      if (foundJourneys.length >= 20) break;

      if (currentPath.length >= 4) {
         continue;
      }

      final visitedInPath = currentPath.map((p) => p.fromName).toSet();
      visitedInPath.add(lastSegment.toName);

      if (lastSegment.toName == endStation) {
        foundJourneys.add(currentPath);
        continue;
      }

      final nextSegments = _adjacencyMap[lastSegment.toName] ?? [];

      for (var nextSegment in nextSegments) {
        if (!visitedInPath.contains(nextSegment.toName)) {
          final newPath = List<Positionnement>.from(currentPath);
          newPath.add(nextSegment);
          queue.add(newPath);
        }
      }
    }

    foundJourneys.sort((a, b) => a.length.compareTo(b.length));

    return foundJourneys.take(5).toList();
  }
}