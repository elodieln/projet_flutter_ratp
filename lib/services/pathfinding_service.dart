// lib/services/pathfinding_service.dart
import 'dart:collection';
import 'package:flutter/foundation.dart';

import '../models/positionnement.dart';
import 'data_service.dart';

// Les données passées à la fonction 'compute'
class PathfindingParams {
  final String startStation;
  final String endStation;

  PathfindingParams({required this.startStation, required this.endStation});
}

/// Ceci est une fonction de haut niveau (top-level), en dehors de toute classe.
/// C'est une exigence pour pouvoir l'utiliser avec `compute`.
/// `compute` exécute cette fonction dans un isolat séparé pour ne pas bloquer l'UI.
Future<List<List<Positionnement>>> findJourneysInIsolate(PathfindingParams params) async {
  // On recrée une instance du service de données dans l'isolat.
  final dataService = DataService();
  // On s'assure que les données sont chargées. Comme c'est un singleton,
  // les données déjà chargées au démarrage seront réutilisées.
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
  // Une map pour accéder rapidement aux correspondances depuis une station.
  // C'est beaucoup plus rapide que de chercher dans la liste à chaque fois.
  final Map<String, List<Positionnement>> _adjacencyMap = {};

  PathfindingService(this.allSegments) {
    _buildAdjacencyMap();
  }

  // Construit la map une seule fois pour optimiser les recherches.
  void _buildAdjacencyMap() {
    for (var segment in allSegments) {
      if (!_adjacencyMap.containsKey(segment.fromName)) {
        _adjacencyMap[segment.fromName] = [];
      }
      _adjacencyMap[segment.fromName]!.add(segment);
    }
  }

  /// Algorithme de recherche de chemin (BFS - Breadth-First Search)
  /// pour trouver les trajets avec le moins de correspondances.
  List<List<Positionnement>> findJourneys({
    required String startStation,
    required String endStation,
  }) {
    final List<List<Positionnement>> foundJourneys = [];
    // La file contient les chemins partiels à explorer.
    final Queue<List<Positionnement>> queue = Queue();
    // Un set pour éviter de passer plusieurs fois par la même station dans un chemin.
    final Set<String> visitedInPath = {};

    // Initialisation : on trouve tous les premiers tronçons possibles depuis le départ.
    _adjacencyMap[startStation]?.forEach((segment) {
      queue.add([segment]);
    });

    while (queue.isNotEmpty) {
      // On prend le premier chemin de la file.
      final currentPath = queue.removeFirst();
      final lastSegment = currentPath.last;

      // Si on est arrivé à destination
      if (lastSegment.toName == endStation) {
        foundJourneys.add(currentPath);
        // Si on a 5 trajets, on arrête pour ne pas calculer inutilement.
        if (foundJourneys.length >= 5) {
          break;
        }
        continue; // On passe au chemin suivant dans la file
      }

      // Limite le nombre de correspondances pour éviter des calculs infinis
      if (currentPath.length >= 4) {
         continue;
      }

      // On cherche les prochaines correspondances possibles
      final nextSegments = _adjacencyMap[lastSegment.toName] ?? [];

      visitedInPath.clear();
      for(var p in currentPath) {
         visitedInPath.add(p.fromName);
      }

      for (var nextSegment in nextSegments) {
        // Pour éviter les allers-retours (ex: A -> B -> A)
        if (!visitedInPath.contains(nextSegment.toName)) {
          final newPath = List<Positionnement>.from(currentPath);
          newPath.add(nextSegment);
          queue.add(newPath);
        }
      }
    }

    // On trie les résultats par nombre de correspondances (longueur du chemin)
    foundJourneys.sort((a, b) => a.length.compareTo(b.length));

    // On retourne les 5 meilleurs résultats au maximum 
    return foundJourneys.take(5).toList();
  }
}